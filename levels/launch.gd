extends Path2D

class_name Launch


func _ready():
	var player = get_tree().get_nodes_in_group("player")[0]
	if player != null:
		if !player.is_connected("launch_curve", _on_player_follow_launch_curve):
			player.connect("launch_curve", _on_player_follow_launch_curve)
		if !player.is_connected("parent_launch", _on_player_follow_parent_launch):
			player.connect("parent_launch", _on_player_follow_parent_launch)


func _on_player_follow_launch_curve(new_curve):
	set_curve(new_curve)
	$preview.points = new_curve.get_baked_points()


func _on_player_follow_parent_launch(node):
	node.get_parent().remove_child(node)
	self.add_child(node)
