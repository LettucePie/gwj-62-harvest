extends Camera2D

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var offset_pos = player.get_position()
	offset_pos += Vector2(100, -20)
	self.position = offset_pos
#	self.position = self.position.lerp(offset_pos, delta)
