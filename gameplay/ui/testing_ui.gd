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
