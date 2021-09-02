extends Node

const MAX_PLAYERS = 4
var ip: String = "127.0.0.1" #localhost
var port: int = 25000 #@5000 is not taken, so let's use that.
var peer: NetworkedMultiplayerENet = null
var player: Dictionary = {}

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connect_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func startserver():
	if port >= 0 and port < 65536:
		print("Starting server....")
		peer = NetworkedMultiplayerENet.new()
		peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_FASTLZ
		peer.always_ordered = true
		if peer.create_server(port, MAX_PLAYERS) == OK:
			get_tree().set_network_peer(peer)
			print("Server started!")
		else:
			print("Unable to start server.")
			get_tree().quit()
	else:
		#Port is invalid
		print("Invalid port")
		get_tree().quit()

func startclient():
	#Check whether IP address and port is valid
	if ip.is_valid_ip_address() and (port >= 0 and port < 65536):
		print("Starting client....")
		peer = NetworkedMultiplayerENet.new()
		peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_FASTLZ
		peer.always_ordered = true
		if peer.create_client(ip, port) == OK:
			get_tree().set_network_peer(peer)
			print("Client started!")
	else:
		#IP or Port is invalid
		print("Invalid IP address or port")

#Called when a player connects
func _player_connected(id: int):
	if get_tree().is_network_server():
		#The server received connection from a client.
		print("Player with id ",id," connected")
		#Add player
		player[id] = [str("Nickname")]
		#Update the list of players in the game
		#updateplayer()
	else:
		#The client connected to the server. Duh.
		print("Player with id ",id," connected")

#Called when a player disconnects
func _player_disconnected(id: int):
	if get_tree().is_network_server():
		#One of the client disconnected, we should tell other clients about it.
		print("Player with id ",id," disconnected")
		if !player.erase(id):
			print("Player ",id," doesn't exist!")
		#Update the list of players in the game
		#updateplayer()
	else:
		#I think this means the server disconnected, e.g. Server closes
		print("Player with id ",id," disconnected")

func _connected():
	print("Connected to server.")
	#sendname(nickname)

func _connect_fail():
	get_tree().set_network_peer(null)
	print("Can't connect to server")

func _server_disconnected():
	print("Disconnected from server, sending back to main menu....")
	#get_tree().change_scene("res://MainMenu.tscn")
	get_tree().set_network_peer(null)
