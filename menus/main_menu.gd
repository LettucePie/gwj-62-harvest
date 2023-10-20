extends Control

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


func _on_play_pressed():
	play_manager.load_stage()


func _on_help_pressed():
#	$help_menu.show()
	$anim.play("show_help")
	$help_menu.current_page = 0
	$help_menu.load_page(0)


func _on_website_pressed():
	OS.shell_open("https://lettucepie.itch.io/gourd-rush")


func _on_credits_pressed():
	$credit.show()


func _on_quit_pressed():
	get_tree().quit()


func _on_help_menu_close_help():
#	$help_menu.hide()
	$anim.play_backwards("show_help")


func _on_close_credit_pressed():
	$credit.hide()
