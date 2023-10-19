extends Control

class_name GUI

signal player_start()
signal level_done()

var stage : Stage
var player : Player

var playing : bool = false
var speedometer : Array = [10, 25, 45, 75, 100]

func _ready():
	$results_panel.hide()
	$ready_panel.hide()
	stage = get_tree().get_nodes_in_group("stage")[0]
	player = get_tree().get_nodes_in_group("player")[0]


func ready_mode():
	$Panel.hide()
	$TextureRect.hide()
	$results_panel.hide()
	$ready_panel.show()
	playing = false


func play_mode():
	$Panel.show()
	$TextureRect.show()
	$results_panel.hide()
	$ready_panel.hide()
	playing = true


func result_mode():
	$Panel.hide()
	$TextureRect.hide()
	$results_panel.show()
	$ready_panel.hide()
	playing = false
	display_results()


func _process(delta):
	if player != null and stage != null:
		update_labels()


func update_labels():
	if playing:
		$Panel/VBoxContainer/time_container/time.text = str(Time.get_ticks_msec() - stage.start_time)
		$Panel/VBoxContainer/score_container/score.text = str(stage.score)
		$TextureRect/speedometer.value = speedometer[player.speed_stage]
		$TextureRect/momentum.value = player.speed_shift


func display_results():
	$results_panel/VBoxContainer/time_container/time_result.text = str(stage.final_time)
	$results_panel/VBoxContainer/score_container/score_result.text = str(stage.score)
	$results_panel/VBoxContainer/travel_container/travel_result.text = str(stage.travel)


func _on_start_button_pressed():
	print("Start Button")
	emit_signal("player_start")
#	play_mode()


func _on_results_finish_pressed():
	print("Finish Button")
	emit_signal("level_done")
