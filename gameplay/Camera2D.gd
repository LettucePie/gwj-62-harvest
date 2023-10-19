extends Camera2D

@export var player : Player = null
@export var player_vis : Node2D = null
@export var zoom_curve : Curve
var found_ramps = []
var top_left : Vector2i
var bottom_right : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_tree().get_nodes_in_group("player")[0]
	if player_vis == null:
		player_vis = get_parent().get_node("player_visual")
	player.connect("landed", player_landed)
	get_viewport().connect("size_changed", framing)
	framing()


func framing():
	print("CameraFraming")
	var size = get_window().size
	bottom_right = size / 2
	top_left = bottom_right * -1.0


func _physics_process(delta):
	if player_vis != null:
		var player_pos = player.get_parent().to_global(player.position)
		var offset_pos = player_pos
		var offset_zoom = Vector2.ONE * 0.9
		if !player.finished:
			offset_pos.x += bottom_right.x * 0.5
			var upper_y = offset_pos.y + (top_left.y * 0.5)
			var lower_y = offset_pos.y + (bottom_right.y * 0.5)
			offset_pos.y = lerp(upper_y, lower_y, (player.vert_intensity + 1.0 / 2.0))
		## Scaling
		if player.status == "riding" and !player.finished:
			offset_zoom = Vector2.ONE * lerp(0.9, 0.5, zoom_curve.sample(player.progress_ratio))
		self.position = self.position.lerp(offset_pos, delta * 5)
		zoom = zoom.lerp(offset_zoom, delta * 3)
#		print(player.position, " | ", offset_pos)


func player_landed(ramp):
	if found_ramps.has(ramp):
		found_ramps.erase(ramp)
		if found_ramps.size() <= 0:
			print("Watching Player")
