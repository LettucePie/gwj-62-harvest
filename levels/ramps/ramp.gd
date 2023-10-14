extends StaticBody2D

class_name Ramp

var ramp_curve : Curve2D
var baked_points : PackedVector2Array = []
var baked_points_rounded : PackedVector2Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if $path.curve != null:
		build_coll_poly($path.curve)


func build_coll_poly(curve : Curve2D):
	ramp_curve = curve
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
	$col.polygon = shape
	$vis.polygon = shape


func _process(delta):
	pass


func return_next_step(player_pos : Vector2, previous_index : int):
	var local_pos = to_local(player_pos)
#	print("local_pos: ", local_pos)
	var closest_pos = ramp_curve.get_closest_point(local_pos).round()
	var closest_idx = previous_index
	if baked_points_rounded.has(closest_pos):
		closest_idx = baked_points_rounded.find(closest_pos)
	closest_idx = clamp(closest_idx + 1, 0, baked_points.size() - 1)
	var next_dir = local_pos.direction_to(baked_points[closest_idx])
	var stick = true
	if closest_idx > (baked_points.size() - 15):
		stick = false
		print("End of Ramp")
	return [stick, next_dir, closest_idx]
