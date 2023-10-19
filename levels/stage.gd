extends Node2D

class_name Stage

signal reset_stage()
signal finish_stage()

@export var stage_name : String = "Level"
@export var endless_mode : bool = false
@export var checkpoint : Node2D
@export var goal : Node2D
@export var player_scene : PackedScene
@export var player_vis_scene : PackedScene
@export var launch_scene : PackedScene

var player : Player
var player_vis : Node2D
var launch : Launch
var start_time : int
var travel : float
var travel_percent : float
var score : int
var finish : bool = false
var final_time : int

var collected_items : Array
var goal_post_pos : Vector2


func _ready():
	## Checking and Instantiating vital roles
	var player_group = get_tree().get_nodes_in_group("player")
	if has_node("checkpoint"):
		checkpoint = get_node("checkpoint")
	if has_node("finish_line"):
		goal = get_node("finish_line")
	if player_group.size() > 0:
		player = player_group[0]
	if player == null:
		var new_player = player_scene.instantiate()
		if checkpoint != null:
			new_player.position = checkpoint.position
		add_child(new_player)
		player = new_player
	elif checkpoint != null:
		player.position = checkpoint.position
	if has_node("launch"):
		launch = get_node("launch")
	else:
		var new_launch = launch_scene.instantiate()
		add_child(new_launch)
		launch = new_launch
	var player_vis_group = get_tree().get_nodes_in_group("player_visual")
	if player_vis_group.size() > 0:
		player_vis = player_vis_group[0]
	else:
		var new_vis = player_vis_scene.instantiate()
		add_child(new_vis)
		player_vis = new_vis
	goal_post_pos = goal.get_parent().to_global(goal.position)
	goal_post_pos += goal.curve.get_point_position(goal.curve.get_point_count() - 1)
	## Connection
	player.connect("dead", player_dead)
	player.connect("collect", player_collect)
	player.connect("goal_reached", player_finish)


func start_stage():
	start_time = Time.get_ticks_msec()
	player.startup(checkpoint.position)


func player_dead():
	print("Player Dead, resetting at checkpoint")
	if player.get_parent() != self:
		player.get_parent().remove_child(player)
		add_child(player)
	player.position = checkpoint.position
	score = 0
	if collected_items.size() > 0:
		for item in collected_items:
			item.visible = true
	collected_items.clear()
	player_vis._on_player_follow_slam()
	emit_signal("reset_stage")
#	start_time = Time.get_ticks_msec()
#	player.call_deferred("startup", checkpoint.position)


func player_collect(item):
	print("Player collected item: ", item)
	score += 10
	print("Score: ", score)
#	item.queue_free()
	item.visible = false
	collected_items.append(item)


func player_finish():
	print("Player Reached goal!")
	final_time = Time.get_ticks_msec() - start_time
	finish = true
	goal.get_node("goal_truck").close_bed()
	emit_signal("finish_stage")
#	player.process_mode = Node.PROCESS_MODE_DISABLED
	print("Final Time: ", final_time - start_time, " Final Score: ", score, " Distance Traveled: ", travel)


func _process(delta):
	if player != null and checkpoint != null and goal != null:
		var player_global_pos = player.get_parent().to_global(player.position)
		travel = player_global_pos.x - checkpoint.position.x
		travel_percent = travel / goal_post_pos.x - checkpoint.position.x
		if player_global_pos.x > goal_post_pos.x and !finish:
			if player_global_pos.y < goal_post_pos.y:
				print("Player Exceeded Goal!")
				player.get_parent().remove_child(player)
				goal.add_child(player)
				player.progress_ratio = 1.0
				player.goal_finish()
