extends Node

const MAX_PLAYERS = 4
var ip: String = "127.0.0.1" #localhost
var port: int = 25000 #@5000 is not taken, so let's use that.
var peer: NetworkedMultiplayerENet = null
#The list of the players are tracked here.
var playerlist: Dictionary = {}

enum team {
	RED = 0
	BLUE = 1
}

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
		playerlist.clear()
		if peer.create_server(port, MAX_PLAYERS) == OK:
			get_tree().network_peer = peer
			print("Server started!")
			startgame()
		else:
			print("Unable to start server.")
			#get_tree().quit()
	else:
		#Port is invalid
		print("Invalid port")
		#get_tree().quit()

func startclient():
	#Check whether IP address and port is valid
	if ip.is_valid_ip_address() and (port >= 0 and port < 65536):
		print("Starting client....")
		peer = NetworkedMultiplayerENet.new()
		peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_FASTLZ
		peer.always_ordered = true
		playerlist.clear()
		if peer.create_client(ip, port) == OK:
			get_tree().set_network_peer(peer)
			print("Client started!")
	else:
		#IP or Port is invalid
		print("Invalid IP address or port")

func startgame():
	#Since there is no lobby, just start the game right away.
	#
	(get_tree().get_root().get_node("MainMenu") as Control).visible = false
	var level = load("res://scenes/Level.tscn")
	get_tree().get_root().add_child(level.instance())
	#Add self to the game...?
	addplayer(1)
	pass

#Updates the list of players in game....
remote func updateplayer(newplayerlist: Dictionary):
	#This is supposed to be a client-only function, since the server handles player updates internally
	assert(!get_tree().is_network_server())
	var car: PackedScene = load("res://scenes/Car.tscn")
	#Check for any added players in the player list
	for id in newplayerlist:
		#If a player has been added
		if !playerlist.has(id):
			var i: Spatial = car.instance()
			i.set_name(str(id))
			i.translation = Vector3(40,5,5)
			i.set_network_master(id)
			get_tree().get_root().get_node("Level").add_child(i)
			#Oh, and, if that's the client's car, set that car to the client.
			if get_tree().get_network_unique_id() == id:
				i.setcurrent()
	#Check for any removed players in the player list
	for id in playerlist:
		#If a new player has been removed
		if !newplayerlist.has(id):
			var i: Spatial = get_tree().get_root().get_node(str("Level/",id))
			get_tree().get_root().get_node("Level").remove_child(i)
			i.free()
	print("Player updated")

func addplayer(id):
	#Only the server can add player
	assert(get_tree().is_network_server())
	#Add a new player
	playerlist[id] = [str("Nickname")]
	#Add a car for the new player to use
	var car: PackedScene = load("res://scenes/Car.tscn")
	var i: Spatial = car.instance()
	i.set_name(str(id))
	i.translation = Vector3(40,5,5)
	i.set_network_master(id)
	get_tree().get_root().get_node("Level").add_child(i)
	if get_tree().get_network_unique_id() == id:
		i.setcurrent()
	#Tell all the other players of the changed player list
	for p in playerlist:
		if p != 1:
			rpc_id(p, "updateplayer",playerlist)

func removeplayer(id: int):
	#Only the server can remove player
	assert(get_tree().is_network_server())
	#Erase the player
	if !playerlist.erase(id):
		print("Player ",id," doesn't exist!")
	#Remove the car of the old player
	var i: Spatial = get_tree().get_root().get_node("Level").get_node(str(id))
	get_tree().get_root().get_node("Level").remove_child(i)
	i.free()
	#Tell all the other players of the changed player list
	for p in playerlist:
		if p != 1:
			rpc_id(p, "updateplayer",playerlist)

remote func sendtogame():
	#Make sure this function is only called by the client.
	assert(!get_tree().is_network_server())
	#Since there is no lobby, just go to the game right away.
	(get_tree().get_root().get_node("MainMenu") as Control).visible = false
	var level = load("res://scenes/Level.tscn")
	get_tree().get_root().add_child(level.instance())
	#And tell the server that we're in the game.
	rpc_id(1,"replysendtogame")

remote func replysendtogame():
	#Make sure this function is only called by the server.
	assert(get_tree().is_network_server())
	#Get the sender id
	var id = get_tree().get_rpc_sender_id()
	#Add player and assume they're not in
	addplayer(id)

#Called when a player connects
func _player_connected(id: int):
	if get_tree().is_network_server():
		#The server received connection from a client.
		print("Player with id ",id," connected")
		#Send the player straight into the game before adding the player
		rpc_id(id,"sendtogame")
	else:
		#The client connected to the server. Duh.
		print("Player with id ",id," connected")

#Called when a player disconnects
func _player_disconnected(id: int):
	if get_tree().is_network_server():
		#One of the client disconnected, we should tell other clients about it.
		print("Player with id ",id," disconnected")
		#Remove the player from list
		removeplayer(id)
	else:
		#I think this means the server disconnected, e.g. Server closes
		print("Player with id ",id," disconnected")

func _connected():
	print("Connected to server.")
	#sendname(nickname)

func _connect_fail():
	get_tree().network_peer = null
	print("Can't connect to server")

func _server_disconnected():
	print("Disconnected from server, sending back to main menu....")
	#Go back to main menu
	var level = (get_tree().get_root().get_node("Level") as Spatial)
	get_tree().get_root().remove_child(level)
	level.free()
	(get_tree().get_root().get_node("MainMenu") as Control).visible = true
	#Set network to null
	get_tree().network_peer = null
