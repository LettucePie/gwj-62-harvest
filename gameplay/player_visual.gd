extends Node2D

@export var player : Player = null
@export var speed_stage_anims : Array = ["speed_1", "speed_2", "speed_2", "speed_3", "speed_4"]
var player_vis_point = null
var anim : AnimationPlayer
var emission_stages = [4, 10, 20, 40, 60]

func _ready():
	anim = get_node("SubViewport/pumpkin/AnimationPlayer")
	if player == null:
		if get_tree().get_nodes_in_group("player").size() > 0:
			player = get_tree().get_nodes_in_group("player")[0]
	if player == null:
		self.queue_free()
	player_vis_point = player.get_vis_point()
	position = player.get_parent().to_global(player.position)
	if !player.is_connected("brakes", _on_player_follow_brakes):
		player.connect("brakes", _on_player_follow_brakes)
	if !player.is_connected("slam", _on_player_follow_slam):
		player.connect("slam", _on_player_follow_slam)
	if !player.is_connected("speed_stage_shift", _on_player_follow_speed_stage_shift):
		player.connect("speed_stage_shift", _on_player_follow_speed_stage_shift)
	if !player.is_connected("goal_reached", _on_player_follow_goal_reached):
		player.connect("goal_reached", _on_player_follow_goal_reached)


func _physics_process(delta):
	if player_vis_point != null:
		var target = player.get_parent().to_global(player.position)
		var rot_vis_point = player_vis_point.position.rotated(player.rotation)
		position = position.lerp(target + rot_vis_point, 0.3).round()
#	if $GPUParticles2D.emitting:
	$GPUParticles2D.rotation = player.rotation
	$GPUParticles2D.emitting = (player.status == "riding" and !player.finished)
	$GPUParticles2D.amount = emission_stages[player.speed_stage]


func _on_player_follow_brakes(tf):
	if player.status == "riding" and tf:
		anim.play("brake")


func _on_player_follow_slam():
	if player.status == "soaring":
		anim.play("slam")


func _on_player_follow_speed_stage_shift(stage):
	if player.status == "riding":
		anim.play(speed_stage_anims[stage])


func _on_player_follow_goal_reached():
	print("Goal Reached, Playing Slam")
	anim.play("slam")
