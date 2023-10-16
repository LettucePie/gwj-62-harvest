extends Path2D

class_name Launch


func _on_player_follow_launch_curve(new_curve):
	set_curve(new_curve)
	$preview.points = new_curve.get_baked_points()


func _on_player_follow_parent_launch(node):
	node.get_parent().remove_child(node)
	self.add_child(node)
