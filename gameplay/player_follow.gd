extends PathFollow2D

@export var PROGRESS_SPEED = 8.0

@export var BOOST_MULTIPLIER = 1.25
@export var BRAKE_MULTIPLIER = 0.6

var ramp_area : Area2D = null
var landing_progress : float = 0.0
var current_ramp : RampPath = null
var launched_ramps : Array = []
var status = "soaring"
var current_speed : float
var soar_arc : Curve2D
var soar_progress : float
var launch_speed : float = PROGRESS_SPEED


func _ready():
	var new_arc = Curve2D.new()
	new_arc.add_point(self.position)
	new_arc.add_point(self.position + Vector2(0, 600))
	soar_arc = new_arc


func _physics_process(delta):
	if ramp_area != null and current_ramp == null:
		current_ramp = ramp_area.get_parent().close_enough(self)
	if current_ramp != null and !launched_ramps.has(current_ramp):
		if current_ramp != get_parent():
			get_parent().remove_child(self)
			current_ramp.add_child(self)
			print("Reassigned Parent")
			progress = landing_progress
			$Sprite2D.position = Vector2(0, -14.5)
			print("RAMP: ", current_ramp)
		riding(delta)
	else:
		soaring(delta)


func riding(deltatime):
	if status != "riding":
		status = "riding"
	var prev_progress = clamp(progress - 2, 0.0, progress + 20)
	var prev_path_pos = current_ramp.curve.sample_baked(prev_progress)
	var current_path_pos = current_ramp.curve.sample_baked(progress)
	var boost = 1.0
	if Input.is_action_pressed("ui_up"):
		boost = BOOST_MULTIPLIER
	if Input.is_action_pressed("ui_down"):
		boost = BRAKE_MULTIPLIER
	current_speed = PROGRESS_SPEED * boost
	progress += current_speed
	predict_soar()
	if progress_ratio >= 0.98:
		launch()


func predict_soar():
	var ramp_end = current_ramp.get_ramp_final_position()
	var highest_point = ramp_end + (current_ramp.launch_vector * current_speed)
	var follow_point = highest_point \
		+ (current_ramp.launch_vector.rotated(deg_to_rad(30)) \
		* (current_speed * 0.66))
	var final_point = follow_point \
		+ (current_ramp.launch_vector.rotated(deg_to_rad(60)) \
		* (current_speed * 0.33))
	var new_arc = Curve2D.new()
	var coords = PackedVector2Array()
	for i in 7:
		coords.append(ramp_end.bezier_interpolate(highest_point, follow_point, final_point, float(i) / 7.0))
	new_arc.add_point(coords[0], Vector2.ZERO, coords[1])
	new_arc.add_point(coords[2], coords[1], coords[3])
	new_arc.add_point(coords[4], coords[3], coords[5])
	new_arc.add_point(coords[6], coords[5], Vector2.ZERO)
	soar_arc = new_arc
	current_ramp.draw_arc_prediction(new_arc.get_baked_points())


func launch():
	launched_ramps.append(current_ramp)
	current_ramp = null
	var stage_parent = get_parent().get_parent()
	get_parent().remove_child(self)
	stage_parent.add_child(self)
	$Sprite2D.position = Vector2.ZERO
	soar_progress = 0.0
	launch_speed = current_speed


func soaring(deltatime):
	if status != "soaring":
		status = "soaring"
	soar_progress += launch_speed
	var target_pos = soar_arc.sample_baked(soar_progress)
	translate(self.position.direction_to(target_pos) * launch_speed)


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area:
		ramp_area = area


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area:
		ramp_area = null
