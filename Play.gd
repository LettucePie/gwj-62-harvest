extends Node

class_name Play

@export var level_scenes : Array
#@export var level_1 : PackedScene
#@export var level_2 : PackedScene
@export var android_audio : AudioBusLayout

var main_menu : Control
var current_stage : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu = get_node("main_menu")


func load_stage(num):
	var new_scene = level_scenes[num].instantiate()
	remove_child(main_menu)
	add_child(new_scene)
	current_stage = new_scene
	if new_scene.has_signal("load_main"):
		print("Connected Level to Play")
		new_scene.connect("load_main", load_menu)
	else:
		print("Couldn't connect Level to Play... uh oh")


func load_menu():
	print("Load Menu called")
	if current_stage != null:
		current_stage.queue_free()
		current_stage = null
		add_child(main_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
