extends Node2D

var closed : bool = false


func _ready():
	closed = false
	$main.play("idle_open")
	$bed.play("idle")


func close_bed():
	print("Truck_Close_Bed Called")
	if !closed:
		$main.play("close")
		$bed.play("close")
		closed = true


func _on_main_animation_finished():
	if closed and $main.animation == "close":
		$main.play("idle_close")
		$bed.play("idle")
