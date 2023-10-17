extends Camera2D

@export var player_vis : Node2D = null
var watching_gap : bool = false
var found_ramps = []

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


func _on_lookahead_area_entered(area):
	if area.is_in_group("ramp") and !found_ramps.has(area):
		found_ramps.append(area)
		print("Ramp Found Ahead: ", area.get_parent().name)


func rescale_camera():
	print("TODO: Rescale camera to fit players current ramp and all ramps in found_ramps")
	print("Clear found_ramps when player lands")
	print("Smooth Lerped transitions")
