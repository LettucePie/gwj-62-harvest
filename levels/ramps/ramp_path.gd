extends Path2D

class_name RampPath

var baked_points : PackedVector2Array = []
var baked_points_rounded : PackedVector2Array = []


func _ready():
	if self.curve != null:
		build_vis_poly()


func build_vis_poly():
	var size = curve.get_point_count()
	baked_points = curve.get_baked_points()
	var min_clamp = Vector2.ZERO
	var max_clamp = Vector2.ZERO
	for i in size:
		var point_pos = curve.get_point_position(i)
		if point_pos.x < min_clamp.x:
			min_clamp.x = point_pos.x - 5
		if point_pos.x > max_clamp.x:
			max_clamp.x = point_pos.x + 5
		if point_pos.y < min_clamp.y:
			min_clamp.y = point_pos.y - 5
		if point_pos.y > max_clamp.y:
			max_clamp.y = point_pos.y + 5
	baked_points_rounded.clear()
	var shape : PackedVector2Array = []
	shape.append(Vector2(min_clamp.x, max_clamp.y))
	for b in baked_points:
		shape.append(b)
		baked_points_rounded.append(b.round())
	shape.append(max_clamp)
	$vis.polygon = shape
	var area_shape_points = PackedVector2Array()
	area_shape_points.append(min_clamp)
	area_shape_points.append(Vector2(max_clamp.x, min_clamp.y))
	area_shape_points.append(max_clamp)
	area_shape_points.append(Vector2(min_clamp.x, max_clamp.y))
	var area_shape = ConvexPolygonShape2D.new()
	area_shape.points = area_shape_points
	$area/box.shape = area_shape


func close_enough(player : PathFollow2D):
	var player_pos = to_local(player.position)
	var closest_pos = curve.get_closest_point(player_pos)
	var dist = player_pos.distance_to(closest_pos)
	if dist < 25:
		return self
	else:
		return null
