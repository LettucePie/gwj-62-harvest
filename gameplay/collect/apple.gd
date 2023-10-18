extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("glitter")
	$AnimatedSprite2D.speed_scale = randf_range(0.8, 1.2)
