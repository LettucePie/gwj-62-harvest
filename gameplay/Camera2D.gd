extends Camera2D

@export var player : Player = null
@export var player_vis : Node2D = null
var watching_gap : bool = false
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
	$lookahead.position = Vector2(bottom_right.x, 0.0)


func _physics_process(delta):
	if player_vis != null:
		var player_pos = player.get_parent().to_global(player.position)
		var offset_pos = player_pos
		var offset_zoom = Vector2.ONE
		if watching_gap:
			var ramp_center = Vector2.ZERO
			for ramp in found_ramps:
				ramp_center += ramp.position
			ramp_center.x = ramp_center.x / found_ramps.size()
			ramp_center.y = ramp_center.y / found_ramps.size()
			offset_pos = offset_pos.lerp(ramp_center, 0.5)
			## Scaling
			var boundary_magnitude = (bottom_right * 2).length()
			var dist = player_pos.distance_to(ramp_center)
			if dist > boundary_magnitude:
				offset_zoom = Vector2.ONE * 0.5
		else:
			offset_pos.x += bottom_right.x * 0.5
			var upper_y = offset_pos.y + (top_left.y * 0.5)
			var lower_y = offset_pos.y + (bottom_right.y * 0.5)
			offset_pos.y = lerp(upper_y, lower_y, (player.vert_intensity + 1.0 / 2.0))
		self.position = self.position.lerp(offset_pos, 0.15)
		zoom = zoom.lerp(offset_zoom, 0.15)
#		print(player.position, " | ", offset_pos)


func _on_lookahead_area_entered(area):
	if area.is_in_group("ramp") and !found_ramps.has(area.get_parent()):
		found_ramps.append(area.get_parent())
		print("Watching Gap")
		watching_gap = true


func _on_lookahead_area_exited(area):
	if found_ramps.has(area.get_parent()):
		found_ramps.erase(area.get_parent())
		if found_ramps.size() <= 0:
			print("Watching Player")
			watching_gap = false


func player_landed(ramp):
	if found_ramps.has(ramp):
		found_ramps.erase(ramp)
		if found_ramps.size() <= 0:
			print("Watching Player")
			watching_gap = false
