extends Node

@onready var player = get_tree().get_nodes_in_group("player")[0]
#@onready var multiplayerRoot = get_tree().get_nodes_in_group("multiplayerRoot")[0]
var network : ENetMultiplayerPeer
var timer = 0
var multiplayerConnected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	network = ENetMultiplayerPeer.new()
	network.create_client("127.0.0.1", 2222)
	#multiplayer.connect("connection_failed",connectionFailed)
	#multiplayer.connect("connected_to_server", connectionSuccess)
	#multiplayer.connect("server_disconnected", serverDisconnected)
	#multiplayer.connect("peer_packet", packetRecieved)

	#connects
	multiplayer.multiplayer_peer = network


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayerConnected:
		var tmpar : Array = ['player', player.position, player.rotation, player.get_node("Camera3D").rotation]
		timer += delta
		if timer > 1/15:
			multiplayer.send_bytes(var_to_bytes(tmpar),get_multiplayer_authority())
			timer = 0


# MULTIPLAYER

#func startMultiplayer():
#	var network = MultiplayerAPI
#	network.create_client()

func connectionFailed(error):
	print('Error connecting to server:\n'+error)
func connectionSuccess():
	multiplayerConnected = true
#	var level = preload("res://testLevel.tscn")
#	var tmpar:Array = ["level",var_to_bytes_with_objects(level)]
	var tmpar : Array = ['player', player.position, player.rotation, player.get_node("Camera3D").rotation]
	multiplayer.send_bytes(var_to_bytes(tmpar),get_multiplayer_authority())
func serverDisconnected():
	multiplayerConnected = false

#func packetRecieved(id, bytes:PackedByteArray):
	#var tmp = bytes_to_var(bytes)
	#if tmp[0] == "playerSync":
		#for peer in tmp[1]:
			#if peer != str(multiplayer.get_unique_id()):
				#print(peer + " : " + str(tmp[1][peer]))
				#var peerNode = multiplayerRoot.get_node(str(peer))
				#peerNode.position = tmp[1][peer][0]
				#peerNode.rotation = tmp[1][peer][1]
	#elif tmp[0] == "spawnPlayer":
		#var tmpdata = tmp[1]
		#var tmpplayer = preload("res://remotePlayer.tscn").instantiate()
		#for peer in tmpdata:
			#if peer != str(multiplayer.get_unique_id()):
				#print(peer + " : " + str(tmpdata[peer]))
				#tmpplayer.name = str(peer)
				#tmpplayer.position = tmpdata[peer][0]
				#tmpplayer.rotation = tmpdata[peer][2]
				#multiplayerRoot.add_child(tmpplayer)
	#elif tmp[0] == "removePlayer":
		#multiplayerRoot.get_node(tmp[1]).queue_free()
