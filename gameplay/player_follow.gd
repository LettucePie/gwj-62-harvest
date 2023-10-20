extends PathFollow2D

class_name Player

signal landed(ramp)
signal launch_curve(curve)
signal parent_launch(node)
signal collect(pickup)
signal goal_reached()
signal dead()
## Animation Signals
signal speed_stage_shift(stage)
signal slam()
signal brakes(tf)

## Speed stages are the gameplay goal. Player can press the speed up and slow -\
## down buttons, this will change animation, and after filling a meter either -\
## downshift or upshift in speed stage.
@export var SPEED_STAGES : Array = [4.0, 8.0, 12.0, 16.0, 20.0]
@export var SOAR_STAGES : Array = [200.0, 400.0, 600.0, 800.0, 1000.0]
@export var slam_sfx : AudioStreamWAV
@export var soar_sfx : AudioStreamWAV
@export var soaring_damp : Curve
@export var ramp_accel : Curve

var ramp_area : Area2D = null
var landing_progress : float = 0.0
var current_ramp : RampPath = null
var current_paths : PackedInt32Array = [1]
var launched_ramps : Array = []
var status = "soaring"
var slammed : bool = false
var slam_delay : int
var braking : bool = false
var angle : float
var vert_intensity : float
var speed_stage : int = 1
var speed_shift : float = 0.0
#var soar_shift : float = 0.0
var soaring_arc : Curve2D
var soar_velocity : float = 0.0
var soar_death_set : bool
var soar_death_timer : int
var finished : bool = false


#func _ready():
#	call_deferred("startup")


func startup(checkpoint_pos):
	if get_parent() is Ramp or get_parent() is Launch:
		var stage_root = get_parent().get_parent()
		get_parent().remove_child(self)
		stage_root.add_child(self)
	var new_arc = Curve2D.new()
	new_arc.add_point(checkpoint_pos)
	new_arc.add_point(checkpoint_pos + Vector2(0, 600))
	soaring_arc = new_arc
	progress = 0.0
	launched_ramps.clear()
	speed_stage = 1
	speed_shift = 0
	current_paths.clear()
	current_paths.append(1)
#	soar_shift = 0
	slammed = false
	braking = false
	soar_death_set = false
	finished = false
	emit_signal("launch_curve", new_arc)
	emit_signal("parent_launch", self)


func _physics_process(delta):
	if !finished:
		if ramp_area != null and get_parent() != RampPath:
			current_ramp = ramp_area.get_parent().close_enough(self)
		if current_ramp != null and !launched_ramps.has(current_ramp):
			if current_ramp != get_parent():
				landing()
			riding(delta)
		elif get_parent() is Launch:
			if Input.is_action_just_pressed("slam") and !slammed:
				slam_down()
			soaring(delta)


func landing():
	$sfx.stop()
	print("Landing")
	current_ramp.adopt_player(self)
	progress = landing_progress
	if slammed:
		calculate_angle(current_ramp.curve)
		speed_shift = clamp(speed_shift + (3.5 * vert_intensity), 0.0, 4.0)
		print("Slam Bonus Speed of: ", speed_shift)
		slammed = false
		$sfx.stream = slam_sfx
		$sfx.volume_db = linear_to_db(0.5)
		$sfx.play()
	braking = false
	status = "riding"
	current_paths = current_ramp.layer_paths
	emit_signal("landed", current_ramp)
	emit_signal("speed_stage_shift", speed_stage)


func riding(deltatime):
	if status != "riding":
		status = "riding"
	calculate_angle(current_ramp.curve)
	## Had to multiply by 0.1 otherwise it works too fast... looks good though
	var speed_modif = ramp_accel.sample(abs(vert_intensity)) * 0.065
	if angle < -0.01:
		## Climbing
		speed_modif *= 0.75
	var revving = false
	var braking = false
	if Input.is_action_pressed("accelerate"):
		revving = true
		if braking:
			braking = false
			emit_signal("speed_stage_shift", speed_stage)
		speed_modif *= 2.0
	if Input.is_action_pressed("brake"):
		speed_modif *= -0.5
		revving = false
		if !braking:
			braking = true
			emit_signal("brakes", braking)
	elif Input.is_action_just_released("brake"):
		braking = false
		emit_signal("speed_stage_shift", speed_stage)
	if braking:
		speed_modif = clamp(speed_modif - 0.15, -2.0, -0.15)
	elif revving:
		speed_modif = clamp(speed_modif + 0.05, 0.05, 2.0)
	speed_shift = clamp(speed_shift + speed_modif, -4.1, 4.1)
	eval_speed()
	progress += SPEED_STAGES[speed_stage]
	if !current_ramp.finish:
		predict_soar()
	if progress_ratio >= 0.98:
		if current_ramp.finish:
			goal_finish()
		else:
			launch()


func calculate_angle(curve : Curve2D):
	var prev_progress = clamp(progress - 2, 0.0, progress + 20)
	var prev_path_pos = curve.sample_baked(prev_progress)
	var next_progress = clamp(progress + 2, progress, progress + 20)
	var next_path_pos = curve.sample_baked(next_progress)
	var direction = prev_path_pos.direction_to(next_path_pos)
	angle = direction.angle()
	vert_intensity = angle / abs(PI / 2.0)


func eval_speed():
	var applied_speed = SPEED_STAGES[speed_stage] + speed_shift
	if speed_stage < SPEED_STAGES.size() - 1:
		if applied_speed >= SPEED_STAGES[speed_stage + 1]:
			speed_stage += 1
			speed_shift = 0.0
			emit_signal("speed_stage_shift", speed_stage)
			print("Speed Shift Up ", speed_stage)
	if speed_stage > 0:
		if applied_speed <= SPEED_STAGES[speed_stage - 1]:
			speed_stage -= 1
			speed_shift = 0.0
			emit_signal("speed_stage_shift", speed_stage)
			print("Speed Shift Down ", speed_stage)
	

func predict_soar():
	var soar = SOAR_STAGES[speed_stage]
	var dir = current_ramp.launch_vector
	var point_a = current_ramp.get_ramp_final_position() + current_ramp.position
	var point_d = Vector2(point_a.x + soar, point_a.y)
	if dir.angle() > 0.01:
		## Drop off Ramp
		point_d = point_a + (dir * soar)
	var point_b = point_a + (dir * (soar * 0.66))
	var adjust_angle = dir.angle_to(
		point_a.direction_to(
			point_b.lerp(point_d, 0.5)
			)
		)
	var point_c = point_b + (dir.rotated(adjust_angle) * (soar * 0.33))
	var coords = PackedVector2Array()
	for i in 11:
		coords.append(
			point_a.bezier_interpolate(point_b, point_c, point_d, float(i) / 10.0)
		)
	## Add Plummet
	var final_strafe = point_d - point_c
	var point_e = point_d + final_strafe * 0.8
	var point_f = point_e + (Vector2.DOWN * final_strafe.length()) * 1.5
	for i in 11:
		coords.append(
			point_d.bezier_interpolate(point_e, point_e, point_f, float(i) / 10.0)
		)
	## Add Falling for a while
	for i in range(1, 6):
		coords.append(point_f + (Vector2.DOWN * 250 * i))
	var new_arc = Curve2D.new()
	var odd = true
	for c in coords.size():
		if odd:
			var center = coords[c]
			var in_dir = Vector2.ZERO
			var out_dir = Vector2.ZERO
			if c == 0 :
				## Beginning
				out_dir = center.lerp(coords[c + 1], 0.8) - center
			elif c == coords.size() - 1:
				## End
				in_dir = center.lerp(coords[c - 1], 0.8) - center
			else:
				in_dir = center.lerp(coords[c - 1], 0.8) - center
				out_dir = center.lerp(coords[c + 1], 0.8) - center
			new_arc.add_point(center, in_dir, out_dir)
			odd = false
		else:
			odd = true
	soaring_arc = new_arc
	emit_signal("launch_curve", new_arc)


func launch():
	print("Launching")
	launched_ramps.append(current_ramp)
	current_ramp = null
	progress = 0.0
	slammed = false
	soar_death_set = false
	braking = false
	emit_signal("speed_stage_shift", speed_stage)
	soar_velocity = 0.0
	emit_signal("parent_launch", self)
	current_ramp = null
	if !slammed:
		$sfx.stream = soar_sfx
		$sfx.volume_db = linear_to_db(0.2)
		$sfx.pitch_scale = 1.1
		$sfx.play()


func soaring(deltatime):
	if status != "soaring":
		status = "soaring"
	calculate_angle(get_parent().curve)
	var soaring_accel = soaring_damp.sample(abs(vert_intensity))
	var weighted_speed = SPEED_STAGES[speed_stage] * soaring_accel
	if angle > 0.01:
		## Add Gravity
		if soar_velocity <= 0.0:
			soar_velocity = weighted_speed
		soar_velocity += (9.8 * soaring_accel) * deltatime
		weighted_speed = clamp(soar_velocity, 0.0, 20.0)
	elif angle < -0.05:
		speed_shift = clamp(speed_shift - abs(vert_intensity) / 4, 0, 4.0)
	if vert_intensity == 0:
		weighted_speed = SPEED_STAGES[speed_stage]
	if !slammed or (slammed and Time.get_ticks_msec() > slam_delay):
		progress += weighted_speed
	$sfx.pitch_scale = lerp(1.1, 0.5, progress_ratio)
	$sfx.volume_db = linear_to_db(lerp(0.05, 0.0, progress_ratio + 0.5))
	if progress_ratio >= 1.0:
		var time = Time.get_ticks_msec()
		if !soar_death_set:
			soar_death_set = true
			soar_death_timer = time + 100
		elif soar_death_set and time >= soar_death_timer:
			emit_signal("dead")
			progress = 0.0
			finished = true


func slam_down():
	print("TODO Slam!")
	print("Add build up and release pressure")
	slammed = true
	slam_delay = Time.get_ticks_msec() + 300
	emit_signal("slam")
	var slam_arc = Curve2D.new()
	slam_arc.add_point(position)
	slam_arc.add_point(Vector2(position.x, position.y + 2000))
	emit_signal("launch_curve", slam_arc)
	progress = 1.0
	soaring_arc = slam_arc
	$sfx.stop()


func goal_finish():
	emit_signal("goal_reached")
	finished = true


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area and status == "soaring":
		if area.get_parent().has_paths(current_paths):
			ramp_area = area
			print("Ramp: ", area.get_parent().name, " Entered")
	if area.is_in_group("dead") and status == "soaring":
		print("Player touched deadzone")
		emit_signal("dead")
	if area.is_in_group("collect"):
		emit_signal("collect", area)
		$apple.play()


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area and status == "soaring":
		ramp_area = null
		print("Ramp: ", area.get_parent().name, " Left")


func get_vis_point():
	return $vis_point
