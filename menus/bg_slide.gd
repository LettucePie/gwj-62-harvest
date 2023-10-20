extends TextureRect

var start_pos : Vector2
var target_pos : Vector2
var target_rot : float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	target_pos = start_pos + random_vec()
	pivot_offset = size / 2


func random_vec():
	return Vector2(randf_range(-45, 45), randf_range(-45, 45))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotation == target_rot or abs(abs(rotation) - abs(target_rot)) < 0.01:
		target_rot = rotation + randf_range(PI * -0.2, PI * 0.2)
	else:
		rotation = lerp_angle(rotation, target_rot, delta)
	if position == target_pos or position.distance_to(target_pos) < 1:
		target_pos = start_pos + random_vec()
	else:
		position = position.lerp(target_pos, delta)


func _on_resized():
	pivot_offset = size / 2
