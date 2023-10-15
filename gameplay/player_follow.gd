extends PathFollow2D

class_name Player

signal launch_curve(curve)
signal parent_launch(node)

## Speed stages are the gameplay goal. Player can press the speed up and slow -\
## down buttons, this will change animation, and after filling a meter either -\
## downshift or upshift in speed stage.
@export var SPEED_STAGES : Array = [4.0, 8.0, 12.0, 16.0]
@export var SOAR_STAGES : Array = [200.0, 400.0, 600.0, 800.0]

## Remove and replace with speed stages
@export var PROGRESS_SPEED = 8.0
@export var BOOST_MULTIPLIER = 1.25
@export var BRAKE_MULTIPLIER = 0.6

var ramp_area : Area2D = null
var landing_progress : float = 0.0
var current_ramp : RampPath = null
var launched_ramps : Array = []
var status = "soaring"
var current_speed : float
var speed_stage : int = 1
var launch_speed : float = PROGRESS_SPEED


func _ready():
	call_deferred("startup")


func startup():
	var new_arc = Curve2D.new()
	new_arc.add_point(self.position)
	new_arc.add_point(self.position + Vector2(0, 600))
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
			$Sprite2D.position = Vector2(0, -14.5)
			print("RAMP: ", current_ramp)
		riding(delta)
	elif get_parent() is Launch:
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
#	var coords = PackedVector2Array()
#	for i in 7:
#		coords.append(point_a.bezier_interpolate(point_b, point_c, point_d, float(i) / 7.0))
#	new_arc.add_point(coords[0], Vector2.ZERO, coords[0].direction_to(coords[1]))
#	new_arc.add_point(coords[2], coords[2].direction_to(coords[1]), coords[2].direction_to(coords[3]))
#	new_arc.add_point(coords[4], coords[4].direction_to(coords[3]), coords[4].direction_to(coords[5]))
#	new_arc.add_point(coords[6], coords[6].direction_to(coords[5]), Vector2.ZERO)
	for i in 10:
		new_arc.add_point(
			point_a.bezier_interpolate(point_b, point_c, point_d, float(i) / 9.0),
			Vector2.ZERO,
			Vector2.ZERO
		)
	emit_signal("launch_curve", new_arc)


func launch():
	launched_ramps.append(current_ramp)
	current_ramp = null
#	var stage_parent = get_parent().get_parent()
#	get_parent().remove_child(self)
#	stage_parent.add_child(self)
#	$Sprite2D.position = Vector2.ZERO
	launch_speed = current_speed
	progress = 0.0
	emit_signal("parent_launch", self)


func soaring(deltatime):
	if status != "soaring":
		status = "soaring"
#	print("Soaring")
	progress += launch_speed


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area:
		ramp_area = area


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area:
		ramp_area = null
