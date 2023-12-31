extends Path2D

class_name RampPath

@export var finish : bool = false
@export var layer_paths : PackedInt32Array = [1]

var baked_points : PackedVector2Array = []
var baked_points_rounded : PackedVector2Array = []
var launch_vector : Vector2 = Vector2.ZERO


func _ready():
	if self.curve != null:
		build_area_poly()
		find_launch_vector()
	if !is_in_group("ramp_path"):
		add_to_group("ramp_path")


func build_area_poly():
	var size = curve.get_point_count()
	baked_points = curve.get_baked_points()
	var min_clamp = Vector2.ZERO
	var max_clamp = Vector2.ZERO
	for i in size:
		var point_pos = curve.get_point_position(i)
		if point_pos.x < min_clamp.x:
			min_clamp.x = point_pos.x - 50
		if point_pos.x > max_clamp.x:
			max_clamp.x = point_pos.x + 50
		if point_pos.y < min_clamp.y:
			min_clamp.y = point_pos.y - 50
		if point_pos.y > max_clamp.y:
			max_clamp.y = point_pos.y + 50
	baked_points_rounded.clear()
	for b in baked_points:
		baked_points_rounded.append(b.round())
	var area_shape_points = PackedVector2Array()
	area_shape_points.append(min_clamp)
	area_shape_points.append(Vector2(max_clamp.x, min_clamp.y))
	area_shape_points.append(max_clamp)
	area_shape_points.append(Vector2(min_clamp.x, max_clamp.y))
	var area_shape = ConvexPolygonShape2D.new()
	area_shape.points = area_shape_points
	$area/box.shape = area_shape


func has_paths(paths):
	var valid = false
	for p in paths:
		for lp in layer_paths:
			if p == lp:
				valid = true
	return valid


func adopt_player(player : PathFollow2D):
	player.get_parent().remove_child(player)
	add_child(player)


func close_enough(player : PathFollow2D):
	var player_pos = to_local(player.position)
	var closest_pos = curve.get_closest_point(player_pos)
	var dist = player_pos.distance_to(closest_pos)
	if dist < 25:
		player.landing_progress = curve.get_closest_offset(closest_pos)
		return self
	else:
		return null


func find_launch_vector():
	var cap = baked_points.size() - 1
	var inner_point = baked_points[cap - 2]
	var end_point = baked_points[cap]
	launch_vector = inner_point.direction_to(end_point)


func get_ramp_start_position():
	return baked_points[0]


func get_ramp_final_position():
	return baked_points[baked_points.size() - 1]
