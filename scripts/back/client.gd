extends Node

class_name SocketClient

enum Message {
	setID,
	newUserConnected,
	userDisconnected,
	updateUserAttributes,
	updateLeaderBoard,
	sendTimeUsage,
	confirmConnection,
	requestSeed,
	setSeed,
	getUserCount,
	showModal
}

var game = preload("res://scenes/front/game.tscn")
var peer = WebSocketMultiplayerPeer.new()
var id = -1  # Initialize to -1 to check for unassigned ID
var player_attributes = {"name": "", "score": 0}  # Self attributes for the player


func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			#print(OS.get_process_id())
			print("Client received packet: " + str(data))
			
			match int(data.message):
				Message.confirmConnection:
					handleConfirmConnection()
				Message.setID:
					id = data.data
					print("Assigned ID: " + str(id))
					#FIXME
					#request for seed
					send_to_server({
						"message": Message.requestSeed,
						"client_id": id
					})
				Message.newUserConnected:
					print("User connected: " + str(data.data))
					handleNewUserConnected(data.data)
				Message.userDisconnected:
					print("User disconnected: " + str(data.data))
				Message.updateUserAttributes:
					print("Player attributes updated: " + str(data.data))
					handleUpdateUserAttributes(data.data)
				Message.setSeed:
					setSeed(data.data)
				Message.getUserCount:
					if data.data == 2:
						get_parent().get_node("Game").get_node("ReadyPanel").change()
					get_parent().get_node("Game").get_node("GameManager").display_player_count(data.data)
				Message.showModal:
					show_modal(data.data)
				_:
					print("Unknown message type")

func connectToServer(ip):
	var error = peer.create_client("ws://" + ip + ":8888")
	if error != OK:
		print("Error connecting to server: " + str(error))
	else:
		print("Started client")
		#wait for client to connect to server (poll to open) or 
		#just send to server and let it send back as packet and run on client that time
		await get_tree().create_timer(0.05).timeout
		var game_instant = game.instantiate()
		get_parent().add_child(game_instant)
		send_to_server({"message": Message.getUserCount,"client_id": id})
		send_to_server({"message": Message.showModal,"client_id": id})
		show_modal("Welcome")

func handleNewUserConnected(data) -> void:
	# pop up show new user connected
	pass

func handleUpdateUserAttributes(data)-> void:
	pass

func handleConfirmConnection():
	# close home page to start game page
	pass

func setSeed(seed):
	print(seed)
	get_parent().rng.seed = seed

func send_to_server(message):
	peer.get_peer(1).put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func assignPlayerName(name) -> void:
	if id != -1:
		player_attributes["name"] = name
		# Send player attributes to the server
		var message = {
			"message": Message.updateUserAttributes,
			"client_id" : id,
			"data": player_attributes
		}
		peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	else:
		print("Client ID not assigned yet.")
	
func show_modal(name):
	get_parent().get_node("Game").get_node(name).visible = true
