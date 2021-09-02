tool
extends Area

#onready var box = $CSGBox

func _process(delta):
	$CSGBox.rotate(Vector3(1, 0, 0), deg2rad(1))
	$CSGBox.rotate(Vector3(0, 1, 0), deg2rad(3))
	$CSGBox.rotate(Vector3(0, 0, 1), deg2rad(2))
