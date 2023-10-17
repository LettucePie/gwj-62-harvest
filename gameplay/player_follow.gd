extends PathFollow2D

class_name Player

signal launch_curve(curve)
signal parent_launch(node)

## Speed stages are the gameplay goal. Player can press the speed up and slow -\
## down buttons, this will change animation, and after filling a meter either -\
## downshift or upshift in speed stage.
@export var SPEED_STAGES : Array = [4.0, 8.0, 12.0, 16.0, 20.0]
@export var SOAR_STAGES : Array = [200.0, 400.0, 600.0, 800.0, 1000.0]
@export var soaring_damp : Curve
@export var ramp_accel : Curve

var ramp_area : Area2D = null
var landing_progress : float = 0.0
var current_ramp : RampPath = null
var launched_ramps : Array = []
var status = "soaring"
var angle : float
var vert_intensity : float
var speed_stage : int = 1
var speed_shift : float = 0.0
var soaring_arc : Curve2D
var soar_velocity : float = 0.0


func _ready():
	call_deferred("startup")


func startup():
	var new_arc = Curve2D.new()
	new_arc.add_point(self.position)
	new_arc.add_point(self.position + Vector2(0, 600))
	soaring_arc = new_arc
	emit_signal("launch_curve", new_arc)
	emit_signal("parent_launch", self)


func _physics_process(delta):
	if ramp_area != null and current_ramp == null:
		current_ramp = ramp_area.get_parent().close_enough(self)
	if current_ramp != null and !launched_ramps.has(current_ramp):
		if current_ramp != get_parent():
			landing()
		riding(delta)
	elif get_parent() is Launch:
		soaring(delta)


func landing():
	current_ramp.adopt_player(self)
	progress = landing_progress


func riding(deltatime):
	if status != "riding":
		status = "riding"
	calculate_angle()
	## Had to multiply by 0.1 otherwise it works too fast... looks good though
	var speed_modif = ramp_accel.sample(abs(vert_intensity)) * 0.1
	if angle < -0.01:
		## Climbing
		speed_modif *= 0.75
	var revving = true
	if Input.is_action_pressed("ui_up"):
		speed_modif *= 2.0
	if Input.is_action_pressed("ui_down"):
		speed_modif *= -0.5
		revving = false
	speed_shift += speed_modif
	eval_speed(revving)
	progress += SPEED_STAGES[speed_stage]
	predict_soar()
	if progress_ratio >= 0.98:
		launch()


func calculate_angle():
	if get_parent() is Path2D:
		var curve = get_parent().curve
		var prev_progress = clamp(progress - 2, 0.0, progress + 20)
		var prev_path_pos = curve.sample_baked(prev_progress)
		var next_progress = clamp(progress + 2, progress, progress + 20)
		var next_path_pos = curve.sample_baked(next_progress)
		var direction = prev_path_pos.direction_to(next_path_pos)
		angle = direction.angle()
		vert_intensity = angle / abs(PI / 2.0)


func eval_speed(revving_up : bool):
	var applied_speed = SPEED_STAGES[speed_stage] + speed_shift
	if revving_up and speed_stage < SPEED_STAGES.size() - 1:
		if applied_speed >= SPEED_STAGES[speed_stage + 1]:
			speed_stage += 1
			speed_shift = 0.0
	elif !revving_up and speed_stage > 1:
		if applied_speed <= SPEED_STAGES[speed_stage - 1]:
			speed_stage -=1
			speed_shift = 0.0
	

func predict_soar():
	var soar = SOAR_STAGES[speed_stage]
	var dir = current_ramp.launch_vector
	var point_a = current_ramp.get_ramp_final_position() + current_ramp.position
	var point_d = Vector2(point_a.x + soar, point_a.y)
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
	for i in range(1, 5):
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
	launched_ramps.append(current_ramp)
	current_ramp = null
	progress = 0.0
	soar_velocity = 0.0
	emit_signal("parent_launch", self)


func soaring(deltatime):
	if status != "soaring":
		status = "soaring"
	calculate_angle()
	var soaring_accel = soaring_damp.sample(abs(vert_intensity))
	var weighted_speed = SPEED_STAGES[speed_stage] * soaring_accel
	if angle > 0.01:
		## Add Gravity
		if soar_velocity <= 0.0:
			soar_velocity = weighted_speed
		soar_velocity += (9.8 * soaring_accel) * deltatime
		weighted_speed = clamp(soar_velocity, 0.0, 20.0)
	if vert_intensity == 0:
		weighted_speed = SPEED_STAGES[speed_stage]
	progress += weighted_speed


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area:
		ramp_area = area


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area:
		ramp_area = null


func get_vis_point():
	return $vis_point
