extends Node

class_name SocketClient

enum Message {
	setID,
	newUserConnected,
	userDisconnected,
	updateUserAttributes,
	updateLeaderBoard,
	sendTimeUsage,
	sendDiffScore,
	confirmConnection,
	sendSeed,
	getUserCount,
	showModal,
	getUserReadyCount,
	runningGame,
	closeModal,
	updateTimer,
	forceClosed,
	resetGame,
	clientSurrender
}

var game = preload("res://scenes/front/game.tscn")
var peer = WebSocketMultiplayerPeer.new()
var id: int = -1  # Initialize to -1 to check for unassigned ID
var player_attributes = {"name": "", "score": 0}  # Self attributes for the player
var turn_num
var clients_num
var _name
var _avatar
var clients


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
				Message.newUserConnected:
					print("User connected: " + str(data.data))
					clients_num = data.clients_num
				Message.userDisconnected:
					print("User disconnected: " + str(data.data))
				Message.updateUserAttributes:
					print("Player attributes updated: " + str(data.data))
					if data.has("clients"):
						clients = data.clients
						if get_tree().root.get_node("main").is_server:
							#get_tree().root.get_node("main").get_node("Game").get_node("PlayerCount").visible = true
							get_tree().root.get_node("main").get_node("ServerWindow").get_node("PlayerCount").text = "PLAYERS ONLINE: " + str(clients.size())
					updateDisplay()
					get_parent().get_node("Game").get_node("GameManager").display_player_count(clients.size())
				Message.getUserCount:
					if data.data == 2:
						get_parent().get_node("Game").get_node("ReadyPanel").change()
				Message.showModal:
					show_modal(data.data)
				Message.getUserReadyCount:
					match data.data:
						"Wait":
							get_parent().get_node("Game").get_node("ViewRule").get_node("Label").text ="Waiting for \nanother player"
						"Ready":
							get_parent().get_node("Game").get_node("ViewRule").get_node("Label").text ="press ready\nwhen ready"
						"StartGame":
							get_parent().get_node("Game").get_node("ViewRule").hide()
							get_parent().get_node("Game").get_node("Surrender").disabled = false
				Message.runningGame:
					#do match on game_manger ccuz i lazy
					get_parent().get_node("Game").get_node("GameManager").runningGame(data)
					if data.has("turn_num"):
						turn_num = data.turn_num
				Message.sendTimeUsage:
					get_parent().get_node("Game").get_node("GameTimer").stop()
				Message.closeModal:
					get_parent().get_node("Game").get_node("ModalTimer").stop()
					get_parent().get_node("Game").get_node("GameManager").modal_time = 0
					get_parent().get_node("Game").get_node("GameManager")._on_modal_timer_timeout()
				Message.updateTimer:
					get_parent().get_node("Game").get_node(data.data).start()
				Message.sendSeed:
					get_parent().get_node("Game").get_node("GameManager").setSeed(data.used_num, data.target_num, data.seed_answer)
				Message.forceClosed:
					get_parent().get_node("Game").get_node("ModalTimer").stop()
					get_parent().get_node("Game").get_node("GameManager").modal_time = 5
					get_parent().get_node("Game").get_node("Winner").visible = false
					get_parent().get_node("Game").get_node("SurrenderModal").visible = false
				Message.resetGame:
					for i in clients.keys():
						clients[i].attributes.score = 0
					get_parent().get_node("Game").get_node("GameManager").resetGame()
				Message.clientSurrender:
					var gm = get_parent().get_node("Game")
					gm.get_node("GameManager").surrender(data.data)
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
		var game_instant = game.instantiate()
		get_parent().add_child(game_instant)
		await get_tree().create_timer(0.5).timeout
		
		
		send_to_server({"message": Message.getUserCount,"client_id": id})
		send_to_server({"message": Message.showModal,"client_id": id})
		assignPlayerName()
		get_parent().get_node("Game").get_node("Welcome").get_node("Label2").text = _name
		show_modal("Welcome")

func updateDisplay():
	var game = get_parent().get_node("Game")
	var menu = get_parent().get_node("MainMenu")
	if clients.size() == 1:
		game.get_node("P1Name").text = clients[str(id)].attributes.name
		var node_path = "AvatarChange/WhiteBox/bald" + str(clients[str(id)].attributes.avatar) + "/Panel"
		var stylebox = menu.get_node(node_path).get_theme_stylebox("panel", "Panel")
		game.get_node("P1Avatar").add_theme_stylebox_override("panel", stylebox)
		game.get_node("P1Score").get_node("Score").text = str(clients[str(id)].attributes.score)
	elif clients.size() == 2:
		var other_id
		for client_id in clients.keys():
			if client_id != str(id):
				other_id = client_id
		
		if game.get_node("P1Name").text != clients[str(id)].attributes.name:
			game.get_node("P1Name").text = clients[other_id].attributes.name
			var node_path = "AvatarChange/WhiteBox/bald" + str(clients[other_id].attributes.avatar) + "/Panel"
			var stylebox = menu.get_node(node_path).get_theme_stylebox("panel", "Panel")
			game.get_node("P1Avatar").add_theme_stylebox_override("panel", stylebox)
			game.get_node("P1Score").get_node("Score").text = str(clients[other_id].attributes.score)
			
			game.get_node("P2Name").text = clients[str(id)].attributes.name
			node_path = "AvatarChange/WhiteBox/bald" + str(clients[str(id)].attributes.avatar) + "/Panel"
			stylebox = menu.get_node(node_path).get_theme_stylebox("panel", "Panel")
			game.get_node("P2Avatar").add_theme_stylebox_override("panel", stylebox)
			game.get_node("P2Score").get_node("Score").text = str(clients[str(id)].attributes.score)
		else:
			game.get_node("P1Name").text = clients[str(id)].attributes.name
			var node_path = "AvatarChange/WhiteBox/bald" + str(clients[str(id)].attributes.avatar) + "/Panel"
			var stylebox = menu.get_node(node_path).get_theme_stylebox("panel", "Panel")
			game.get_node("P1Avatar").add_theme_stylebox_override("panel", stylebox)
			game.get_node("P1Score").get_node("Score").text = str(clients[str(id)].attributes.score)
			
			game.get_node("P2Name").text = clients[other_id].attributes.name
			node_path = "AvatarChange/WhiteBox/bald" + str(clients[other_id].attributes.avatar) + "/Panel"
			stylebox = menu.get_node(node_path).get_theme_stylebox("panel", "Panel")
			game.get_node("P2Avatar").add_theme_stylebox_override("panel", stylebox)
			game.get_node("P2Score").get_node("Score").text = str(clients[other_id].attributes.score)


func handleConfirmConnection():
	# close home page to start game page
	pass


func send_to_server(message):
	peer.get_peer(1).put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func assignPlayerName() -> void:
	if id != -1:
		_name = get_parent().get_node("MainMenu").get_node("MainBox").get_node("LineEdit").text
		_avatar = get_parent().get_node("MainMenu").get_node("AvatarChange").selected_avatar_number
		if _name == "":
			_name = str(id)
		player_attributes["name"] = _name
		player_attributes["avatar"] = _avatar
		# Send player attributes to the server
		var message = {
			"message": Message.updateUserAttributes,
			"client_id" : id,
			"data": player_attributes,
		}
		peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	else:
		print("Client ID not assigned yet.")
	
func show_modal(name):
	get_parent().get_node("Game").get_node(name).visible = true
	
func request_ready_count(data):
	send_to_server({"message": Message.getUserReadyCount, "client_id": id, "data": data})
