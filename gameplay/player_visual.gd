extends Node2D

@export var player : Player = null
var player_vis_point = null

func _ready():
	if player == null:
		player = get_tree().get_nodes_in_group("player")[0]
	player_vis_point = player.get_vis_point()
	position = player.get_parent().to_global(player.position)


func _physics_process(delta):
	if player_vis_point != null:
		var target = player.get_parent().to_global(player.position)
		var rot_vis_point = player_vis_point.position.rotated(player.rotation)
		position = position.lerp(target + rot_vis_point, 0.3)
