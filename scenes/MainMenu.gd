extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Host_pressed() -> void:
	Server.startserver()
	pass # Replace with function body.


func _on_Join_pressed() -> void:
	Server.startclient()
	pass # Replace with function body.


func _on_Start_pressed() -> void:
	Server.startgame()
	pass # Replace with function body.


func _on_Disconnect_pressed() -> void:
	(get_tree().network_peer as NetworkedMultiplayerENet).close_connection()
	get_tree().network_peer = null
	pass # Replace with function body.
