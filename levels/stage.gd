extends Node2D

class_name Stage

@export var checkpoint : Node2D
@export var player_scene : PackedScene
@export var player_vis_scene : PackedScene
@export var launch_scene : PackedScene

var player : Player
var player_vis : Node2D
var launch : Launch
var travel : float
var score : int

var collected_items : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	var player_group = get_tree().get_nodes_in_group("player")
	if has_node("checkpoint"):
		checkpoint = get_node("checkpoint")
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
	player.connect("dead", player_dead)
	player.connect("collect", player_collect)
	player.startup(checkpoint.position)


func player_dead():
	print("Player Dead, resetting at checkpoint")
	player.position = checkpoint.position
	score = 0
	if collected_items.size() > 0:
		for item in collected_items:
			item.visible = true
	collected_items.clear()
	player.call_deferred("startup", checkpoint.position)


func player_collect(item):
	print("Player collected item: ", item)
	score += 10
	print("Score: ", score)
#	item.queue_free()
	item.visible = false
	collected_items.append(item)


func _process(delta):
	if player != null and checkpoint != null:
		travel = player.get_parent().to_global(player.position).x - checkpoint.position.x
