extends Control

var play_manager : Play

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is Play:
		play_manager = get_parent()
	if OS.has_feature("web"):
		$VBoxContainer/quit.hide()
	$help_menu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	play_manager.load_stage()


func _on_help_pressed():
	$help_menu.show()
	$help_menu.current_page = 0
	$help_menu.load_page(0)


func _on_website_pressed():
	pass # Replace with function body.


func _on_credits_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()


func _on_help_menu_close_help():
	$help_menu.hide()
