extends RigidBody2D

@export var hold_mass : float = 10000.0
@export var release_mass : float = 1.0

var sticky_ramp : Ramp
var ramp_step : Array = [true, Vector2.ZERO, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if sticky_ramp != null:
		ramp_step = sticky_ramp.return_next_step(self.position, ramp_step[2])
		if ramp_step[0]:
			print("Pressing against ramp")
#				mass = 1.0
			apply_central_force(ramp_step[1] * 500)
	if Input.is_action_pressed("ui_accept"):
		apply_torque(20000.0)


func _on_body_entered(body):
	if body.is_in_group("ramp") and sticky_ramp != body:
		print("Sticking to ramp: ", body)
		sticky_ramp = body
#		mass = 0.1
