extends RigidBody2D

@export var sticky = false

var sticky_ramp : Ramp
var ramp_step : Array = [true, Vector2.ZERO, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	modulate = Color.WHITE
	if sticky and $ray.is_colliding():
		if $ray.get_collider().is_in_group("ramp"):
			var point = $ray.get_collision_point()
			if point.y > position.y:
				print(point.y, " | ", position.y)
				point.y = lerp(point.y, position.y, 0.5)
				modulate = Color.RED
				apply_central_force(self.position.direction_to(point) * 100)
#	if sticky_ramp != null and sticky:
#		ramp_step = sticky_ramp.return_next_step(self.position, ramp_step[2])
#		if ramp_step[0]:
#			print("Pressing against ramp")
#			apply_central_force(ramp_step[1] * 500)
	if Input.is_action_pressed("ui_accept"):
		apply_torque(20000.0)
	else:
		apply_torque(1000.0)


func _on_body_entered(body):
	if body.is_in_group("ramp") and sticky_ramp != body:
		print("Sticking to ramp: ", body)
		sticky_ramp = body
