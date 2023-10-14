extends PathFollow2D

@export var GRAVITY = 9.8
@export var SPEED_MIN = 4.0
@export var SPEED_MAX = 20.0
@export var speed_damp : Curve ## Controls rate of deccelleration
@export var GRAV_FORCE_MIN = 0.05
@export var GRAV_FORCE_MAX = 0.5
@export var gravity_damp : Curve ## Controls influence of gravity at x speed (flight)

var direction : Vector2 = Vector2.ZERO
var speed : float = 0.0
var velocity : Vector2 = Vector2.ZERO

var ramp_area : Area2D = null
var current_ramp : RampPath = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if ramp_area != null:
		current_ramp = ramp_area.get_parent().close_enough(self)
	if current_ramp != null:
		riding()
	else:
		soaring()
	speed = clamp(speed, SPEED_MIN, SPEED_MAX)
	direction = direction.normalized()
#	velocity += direction * speed
	velocity = (velocity + (direction * speed)).clamp(Vector2.ONE * -20.0, Vector2.ONE * 20.0)
	print("Velocity: ", velocity, " direction: ", direction, " speed: ", speed)
	translate(velocity / 2)


func riding():
	print("Riding")
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	speed = 0.0


func soaring():
	print("Soaring")
	var speed_force = speed_damp.sample(
		(speed - SPEED_MIN) / (SPEED_MAX - SPEED_MIN)
	)
	var grav_force = lerp(
		GRAV_FORCE_MAX, ## Max amount of Gravity Force for slowest percent speed
		GRAV_FORCE_MIN, ## Min amount of force for greatest speed (achieving flight)
		gravity_damp.sample(speed_force)
	)
	direction = direction.slerp(Vector2.DOWN, grav_force)
	speed = clamp(lerp(speed, GRAVITY, grav_force), 4.0, GRAVITY)
	## or ?
#	speed = GRAVITY


func _on_area_2d_area_entered(area):
	if area.is_in_group("ramp") and ramp_area != area:
		ramp_area = area


func _on_area_2d_area_exited(area):
	if area.is_in_group("ramp") and ramp_area == area:
		ramp_area = null
