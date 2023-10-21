extends Control

signal button_sfx()

var play_manager : Play

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is Play:
		play_manager = get_parent()
	if OS.has_feature("web"):
		$VBoxContainer/website.hide()
		$VBoxContainer/quit.hide()
	hide_all()
	$VBoxContainer/play.grab_focus()


func hide_all():
	$help_menu.hide()
	$credit.hide()
	$level_select.hide()


func _on_play_pressed():
	emit_signal("button_sfx")
	$title.hide()
	$VBoxContainer.hide()
	$level_select.show()


func _on_close_level_select_pressed():
	emit_signal("button_sfx")
	$title.show()
	$VBoxContainer.show()
	$level_select.hide()


func level_selected(num : int):
	emit_signal("button_sfx")
	print("Level Selected: ", num)
	play_manager.load_stage(num)


func _on_help_pressed():
	emit_signal("button_sfx")
#	$help_menu.show()
	$anim.play("show_help")
	$help_menu.current_page = 0
	$help_menu.load_page(0)


func _on_website_pressed():
	emit_signal("button_sfx")
	OS.shell_open("https://lettucepie.itch.io/gourd-rush")


func _on_credits_pressed():
	emit_signal("button_sfx")
	$credit.show()


func _on_quit_pressed():
	emit_signal("button_sfx")
	get_tree().quit()


func _on_help_menu_close_help():
	emit_signal("button_sfx")
#	$help_menu.hide()
	$anim.play_backwards("show_help")


func _on_close_credit_pressed():
	emit_signal("button_sfx")
	$credit.hide()


func _on_help_menu_button_sfx():
	print("ignore?")
#	emit_signal("button_sfx")
