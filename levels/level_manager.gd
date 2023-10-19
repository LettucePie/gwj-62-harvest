extends Node

class_name Level

@export var stage : Stage
@export var gui : GUI

# Called when the node enters the scene tree for the first time.
func _ready():
	if stage == null or gui == null:
		print("FIX THIS ERROR")
	ready_play()


func ready_play():
	gui.ready_mode()
#	stage.player_dead()


func start_play():
	gui.play_mode()
	stage.start_stage()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
