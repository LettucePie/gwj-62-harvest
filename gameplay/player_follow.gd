extends PathFollow2D

@export var GRAVITY = 9.8
@export var FRICTION = 0.8
@export var SPEED_MIN = 2.0
@export var SPEED_MAX = 20.0
@export var speed_damp : Curve ## Controls rate of deccelleration
@export var GRAV_FORCE_MIN = 0.05
@export var GRAV_FORCE_MAX = 0.5
@export var gravity_damp : Curve ## Controls influence of gravity at x speed (flight)

var direction : Vector2 = Vector2.ZERO
var speed : float = 0.0
var velocity : Vector2 = Vector2.ZERO
var status : String = "soaring"

var ramp_area : Area2D = null
var landing_progress = 0.0
var current_ramp : RampPath = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if ramp_area != null and current_ramp == null:
		current_ramp = ramp_area.get_parent().close_enough(self)
	if current_ramp != null:
		if current_ramp != get_parent():
			get_parent().remove_child(self)
			current_ramp.add_child(self)
			print("Reassigned Parent")
			progress = landing_progress
			$Sprite2D.position = Vector2(0, -14.5)
		riding(delta)
	else:
		soaring()


func riding(deltatime):
	if status != "riding":
		status = "riding"
	var prev_progress = clamp(progress - 2, 0.0, progress + 20)
	var prev_path_pos = current_ramp.curve.sample_baked(prev_progress)
	var current_path_pos = current_ramp.curve.sample_baked(progress)
#	print("Prev Pos: ", prev_path_pos, " Current Pos: ", current_path_pos)
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
	progress += speed
#	print("Speed: ", speed, " Direction: ", direction, " Angle: ", angle, " Vert_Intensity: ", vert_intensity)


func soaring():
	if status != "soaring":
		status = "soaring"
	if current_ramp != null:
		print("What on earth am I doing?")
	var speed_force = speed_damp.sample(
		(speed - SPEED_MIN) / (SPEED_MAX - SPEED_MIN)
	)
	var grav_force = lerp(
		GRAV_FORCE_MAX, ## Max amount of Gravity Force for slowest percent speed
		GRAV_FORCE_MIN, ## Min amount of force for greatest speed (achieving flight)
		gravity_damp.sample(speed_force)
	)
	direction = direction.slerp(Vector2.DOWN, grav_force).normalized()
	speed = clamp(lerp(speed, GRAVITY, grav_force), 4.0, GRAVITY)
	velocity = (velocity + (direction * speed)).clamp(Vector2.ONE * -20.0, Vector2.ONE * 20.0)
	print("Velocity: ", velocity, " direction: ", direction, " speed: ", speed)
	translate(velocity / 2)


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area:
		ramp_area = area


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area:
		ramp_area = null
