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


func _on_gui_player_pause():
	print("Level Pausing the game")
	stage.process_mode = Node.PROCESS_MODE_DISABLED
	gui.pause_mode()


func _on_gui_player_resume():
	print("LEVEL: resuming game")
	stage.process_mode = Node.PROCESS_MODE_ALWAYS
	gui.play_mode()


func _on_gui_player_retry():
	stage.process_mode = Node.PROCESS_MODE_ALWAYS
	stage.player_dead()
#	gui.ready_mode()


func _on_gui_player_return():
	emit_signal("load_main")
