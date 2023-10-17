extends Control

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		update_labels()

func update_labels():
	$Panel/VBoxContainer/status_container/status.text = str(player.status)
	$Panel/VBoxContainer/angle_container/angle.text = str(rad_to_deg(player.angle))
	$Panel/VBoxContainer/vert_container/vert.text = str(player.vert_intensity)
	$Panel/VBoxContainer/speed_shift/speed.text = str(player.speed_shift)
	$Panel/VBoxContainer/speed_stage/stage.text = str(player.speed_stage)
