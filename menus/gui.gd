extends Control

class_name GUI

signal button_sfx()

signal player_start()
signal player_pause()
signal player_resume()
signal player_retry()
signal player_return()
signal level_done()

var stage : Stage
var player : Player

var playing : bool = false
var speedometer : Array = [10, 25, 45, 75, 100]

func _ready():
	if get_parent() == get_tree():
		print("Alone")
	else:
		stage = get_tree().get_nodes_in_group("stage")[0]
		player = get_tree().get_nodes_in_group("player")[0]


func ready_mode():
	$pause_button.hide()
	$pause_panel.hide()
	$Panel.hide()
	$TextureRect.hide()
	$results_panel.hide()
	$ready_panel.show()
	playing = false
	$ready_panel/start_button.grab_focus()


func play_mode():
	$pause_button.show()
	$pause_panel.hide()
	$Panel.show()
	$TextureRect.show()
	$results_panel.hide()
	$ready_panel.hide()
	playing = true


func result_mode():
	$pause_button.hide()
	$pause_panel.hide()
	$Panel.hide()
	$TextureRect.hide()
	$results_panel.show()
	$ready_panel.hide()
	playing = false
	display_results()


func pause_mode():
	$pause_button.hide()
	$pause_panel.show()
	$Panel.hide()
	$TextureRect.hide()
	$results_panel.hide()
	$ready_panel.hide()
	playing = false
	$pause_panel/VBoxContainer/resume_pause.grab_focus()


func _process(delta):
	if player != null and stage != null:
		update_labels()
	if playing and Input.is_action_just_pressed("pause"):
		emit_signal("player_pause")


func time_from_msecs(msecs):
	var seconds = msecs / 1000
	var minutes = round(seconds / 60)
	return str(minutes) + ":" + str(seconds)


func update_labels():
	if playing:
		$Panel/VBoxContainer/time_container/time.text = time_from_msecs(Time.get_ticks_msec() - stage.start_time)
		$Panel/VBoxContainer/score_container/score.text = str(stage.score)
		$TextureRect/speedometer.value = speedometer[player.speed_stage]
		$TextureRect/momentum.value = player.speed_shift


func display_results():
	$results_panel/VBoxContainer/time_container/time_result.text = time_from_msecs(stage.final_time)
	$results_panel/VBoxContainer/score_container/score_result.text = str(stage.score)
	$results_panel/VBoxContainer/travel_container/travel_result.text = str(round(stage.travel) / 3) + "m"


func _on_start_button_pressed():
	emit_signal("button_sfx")
	print("Start Button")
	emit_signal("player_start")
#	play_mode()


func _on_results_finish_pressed():
	emit_signal("button_sfx")
	print("Finish Button")
	emit_signal("level_done")


func _on_pause_button_pressed():
	emit_signal("button_sfx")
	emit_signal("player_pause")


func _on_resume_pause_pressed():
	emit_signal("button_sfx")
	emit_signal("player_resume")


func _on_retry_pause_pressed():
	emit_signal("button_sfx")
	emit_signal("player_retry")


func _on_return_pause_pressed():
	emit_signal("button_sfx")
	emit_signal("player_return")


func _on_quit_pause_pressed():
	emit_signal("button_sfx")
	get_tree().quit()
