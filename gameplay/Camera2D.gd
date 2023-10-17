extends Camera2D

@export var player_vis : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if player_vis == null:
		player_vis = get_parent().get_node("player_visual")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player_vis != null:
		var offset_pos = player_vis.get_position()
		offset_pos += Vector2(100, -20)
		self.position = offset_pos
#	self.position = self.position.lerp(offset_pos, delta)
