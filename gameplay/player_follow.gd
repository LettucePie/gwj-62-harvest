extends PathFollow2D

@export var GRAVITY = 9.8
@export var FRICTION = 0.8
@export var SPEED_MIN = 2.0
@export var SPEED_MAX = 20.0
@export var speed_damp : Curve ## Controls rate of deccelleration
@export var gravity_damp : Curve ## Controls influence of gravity at x speed (flight)

@export var BOOST_MULTIPLIER = 1.25
@export var BRAKE_MULTIPLIER = 0.6

var direction : Vector2 = Vector2.ZERO
var speed : float = 0.0
var velocity : Vector2 = Vector2.ZERO
var status : String = "soaring"

var ramp_area : Area2D = null
var landing_progress = 0.0
var current_ramp : RampPath = null
var launched_ramps : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	direction = prev_path_pos.direction_to(current_path_pos).normalized()
	var angle = direction.angle()
	var vert_intensity = abs(angle) / abs(PI / 2.0)
	print(vert_intensity)
	if angle < 0.0 and angle > -PI / 2:
		## Going uphill, reduce speed
		speed = clamp(
			speed - (GRAVITY * vert_intensity) * deltatime,
			SPEED_MIN,
			SPEED_MAX
		)
	elif angle > 0.0:
		speed = clamp(
			speed + ((GRAVITY * FRICTION) * vert_intensity) * deltatime,
			SPEED_MIN,
			SPEED_MAX
		)
	var boost = 1.0
	if Input.is_action_pressed("ui_up"):
		boost = BOOST_MULTIPLIER
	if Input.is_action_pressed("ui_down"):
		boost = BRAKE_MULTIPLIER
	progress += (speed * boost)
	velocity = direction * speed
#	velocity = (velocity + (direction * speed)).clamp(Vector2.ONE * -20.0, Vector2.ONE * 20.0)
	if progress_ratio >= 0.98:
		launch()


func launch():
	launched_ramps.append(current_ramp)
	current_ramp = null
	var stage_parent = get_parent().get_parent()
	get_parent().remove_child(self)
	stage_parent.add_child(self)
	$Sprite2D.position = Vector2.ZERO


func soaring(deltatime):
	if status != "soaring":
		status = "soaring"
	direction = direction.slerp(Vector2.DOWN, deltatime * 2)
	speed = lerp(speed, GRAVITY, deltatime * 2)
	velocity.x = clamp(
		velocity.x - FRICTION , 
		SPEED_MIN, 
		SPEED_MAX)
	velocity = (velocity + (direction * speed)).clamp(Vector2.ONE * -20.0, Vector2.ONE * 20.0)
#	var speed_percent = velocity.x - SPEED_MIN / SPEED_MAX - SPEED_MIN
	translate(velocity / 2)


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area:
		ramp_area = area


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area:
		ramp_area = null
