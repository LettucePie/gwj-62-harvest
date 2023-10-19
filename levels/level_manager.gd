extends Node

class_name Level

signal load_main()
signal load_next()

@export var stage : Stage
@export var gui : GUI

# Called when the node enters the scene tree for the first time.
func _ready():
	if stage == null or gui == null:
		print("FIX THIS ERROR")
	ready_play()


func ready_play():
	gui.ready_mode()


func start_play():
	gui.play_mode()
	stage.start_stage()


func finish_play():
	gui.result_mode()


func _on_gui_level_done():
	print("LEVEL DONE, emitting signal to PLAY")
	emit_signal("load_main")
