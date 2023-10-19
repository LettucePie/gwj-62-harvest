extends Control

signal close_help()

@export var page_titles : PackedStringArray
@export var page_infos : PackedStringArray

var current_page : int = 0


func _ready():
	page_infos[1] = "ACCELERATE : UP or W Key; UP on the D-Pad or Joystick; A on Xbox, and B on Nintendo\n\nBRAKE: DOWN or S Key; DOWN on the Dpad or Joystick; B on Xbox, and A on Nintendo."
	button_validation()


func load_page(num):
	$Panel/VBoxContainer/page_title.text = page_titles[num]
	$Panel/VBoxContainer/info.text = page_infos[num]
	button_validation()


func button_validation():
	var left_visible = true
	var right_visible = true
	var done_visible = false
	if current_page <= 0:
		left_visible = false
	if current_page == page_titles.size() - 1:
		right_visible = false
		done_visible = true
	$Panel/VBoxContainer/controls/left.visible = left_visible
	$Panel/VBoxContainer/controls/right.visible = right_visible
	$Panel/VBoxContainer/controls/done.visible = done_visible
	if done_visible:
		$Panel/VBoxContainer/controls/done.grab_focus()


func _on_left_pressed():
	if current_page > 0:
		current_page -= 1
		load_page(current_page)


func _on_right_pressed():
	if current_page < page_titles.size():
		current_page += 1
		load_page(current_page)


func _on_done_pressed():
	emit_signal("close_help")


func _on_visibility_changed():
	if visible:
		$Panel/VBoxContainer/controls/right.grab_focus
