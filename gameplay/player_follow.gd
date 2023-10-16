extends PathFollow2D

class_name Player

signal launch_curve(curve)
signal parent_launch(node)

## Speed stages are the gameplay goal. Player can press the speed up and slow -\
## down buttons, this will change animation, and after filling a meter either -\
## downshift or upshift in speed stage.
@export var SPEED_STAGES : Array = [4.0, 8.0, 12.0, 16.0]
@export var SOAR_STAGES : Array = [200.0, 400.0, 600.0, 800.0]

var ramp_area : Area2D = null
var landing_progress : float = 0.0
var current_ramp : RampPath = null
var launched_ramps : Array = []
var status = "soaring"
var angle : float
var vert_intensity : float
var speed_stage : int = 1
var soaring_arc : Curve2D


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
			get_parent().remove_child(self)
			current_ramp.add_child(self)
			print("Reassigned Parent")
			progress = landing_progress
			print("RAMP: ", current_ramp)
		riding(delta)
	elif get_parent() is Launch:
		soaring(delta)


func riding(deltatime):
	if status != "riding":
		status = "riding"
	calculate_angle()
	if Input.is_action_just_pressed("ui_up"):
		speed_stage = clamp(speed_stage + 1, 0, 3)
	if Input.is_action_just_pressed("ui_down"):
		speed_stage = clamp(speed_stage - 1, 0, 3)
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
		vert_intensity = abs(angle) / abs(PI / 2.0)


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
	var new_arc = Curve2D.new()
	for i in 10:
		new_arc.add_point(
			point_a.bezier_interpolate(point_b, point_c, point_d, float(i) / 9.0),
			Vector2.ZERO,
			Vector2.ZERO
		)
	soaring_arc = new_arc
	emit_signal("launch_curve", new_arc)


func launch():
	launched_ramps.append(current_ramp)
	current_ramp = null
	progress = 0.0
	emit_signal("parent_launch", self)


func soaring(deltatime):
	if status != "soaring":
		status = "soaring"
	calculate_angle()
	var weighted_speed = SPEED_STAGES[speed_stage] * vert_intensity
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
