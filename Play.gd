extends Node

class_name Play

@export var stage_scene : PackedScene
@export var android_audio : AudioBusLayout

var main_menu : Control
var current_stage : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu = get_node("main_menu")


func load_stage():
	var new_scene = stage_scene.instantiate()
	remove_child(main_menu)
	add_child(new_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
