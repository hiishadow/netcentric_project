extends Node



enum Message {
	setID,
	newUserConnected,
	userDisconnected,
	updateUserAttributes,
	updateLeaderBoard,
	sendTimeUsage,
	confirmConnection,
	sendSeed,
	getUserCount,
	showModal,
	getUserReadyCount,
	runningGame,
	closeModal,
	updateTimer
}

var rng = RandomNumberGenerator.new()
var peer = WebSocketMultiplayerPeer.new()
var clients = {}  # Dictionary to store each player's attributes by their ID
var ready_count = []
var time_usage = {}
var turn_index = 0
var equations = {}

func _ready() -> void:
	peer.connect("peer_connected",peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)

func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			var sender_id = data.client_id # Get the ID of the sender
			#print(OS.get_process_id())
			print("Server received from peer " + str(sender_id) + ": " + str(data))

			if data.has("message"):
				handle_message(data, sender_id)

func handle_message(data, sender_id):
	match int(data.message):
		Message.updateUserAttributes:
			# Update the user's attributes on the server
			if data.has("data") and sender_id in clients:
				clients[sender_id].attributes = data.data
				broadcast_to_all({"message": Message.updateUserAttributes, "data": clients[sender_id]})
		Message.getUserCount:
			broadcast_to_all({"message": Message.getUserCount, "data": clients.size()})
		Message.showModal:
			if clients.size() >= 2:
				broadcast_to_all({"message": Message.showModal,"data": "ViewRule"})
		Message.getUserReadyCount:
			if data.has("data"):
				if data.data == "add":
					ready_count.append(sender_id)
				elif data.data == "remove":
					ready_count.erase(sender_id)
			if ready_count.size() != clients.size():
				if ready_count.has(sender_id):
					send_to_client(sender_id, {"message": Message.getUserReadyCount, "data": "Wait"})
				elif !ready_count.has(sender_id):
					send_to_client(sender_id, {"message": Message.getUserReadyCount, "data": "Ready"})
			elif ready_count.size() == clients.size():
				runningGame()
				broadcast_to_all({"message": Message.getUserReadyCount, "data": "StartGame"})
		Message.sendTimeUsage:
			if data.has("data"):
				time_usage[sender_id] = data.data
				equations[sender_id] = data.equation
				#ssend to others
				for client_id in clients.keys():
					if client_id != clients.keys()[turn_index]:
						send_to_client(client_id, {"message": Message.sendTimeUsage, "data": data.data})
		Message.closeModal:
			for client_id in clients.keys():
				if client_id != clients.keys()[turn_index]:
					send_to_client(client_id, {"message": Message.closeModal})
		Message.updateTimer:
			for client_id in clients.keys():
				if client_id != clients.keys()[turn_index]:
					send_to_client(client_id, {"message": Message.updateTimer, "data": data.data})
		Message.runningGame:
			if data.data == "NextTurn":
				turn_index = (turn_index + 1) % clients.size()
				runningGame()
			elif data.data == "CalculateWinner":
				#TODO same time TIE
				var winner
				var min = 9999
				for i in time_usage.keys():
					if time_usage[i] <= min:
						min = time_usage[i]
						winner = i
				broadcast_to_all({"message": Message.runningGame, "data": "CalculateWinner", 
					"time_usage": time_usage,
					"winner": winner,
					"equations": equations
				})
				

func peer_connected(id):
	print("Peer Connected: " + str(id))
	clients[id] = {
		"id": id,
		"attributes": {"name": "Player" + str(id), "score": 0}  # Default attributes for the player
	}
	
	# Send the assigned ID back to the client
	var message = {
		"message": Message.setID,
		"data": id  # Send the ID to the client
	}
	send_to_client(id,message)
	
	# Notify all clients of the new connection
	broadcast_to_all({
		"message": Message.newUserConnected,
		"data": clients[id],
		"clients_num": clients.size()
	})

func peer_disconnected(id):
	print("Peer Disconnected: " + str(id))
	clients.erase(id)
	var message = {
		"message": Message.userDisconnected,
		"data": "User " + str(id) + " has disconnected."
	}
	broadcast_to_all(message)

func send_to_client(id, message):
	peer.get_peer(id).put_packet(JSON.stringify(message).to_utf8_buffer())

func broadcast_to_all(message):
	for client_id in clients.keys():
		send_to_client(client_id, message)

func startServer():
	var error = peer.create_server(8888)
	if error != OK:
		print("Error starting server: " + str(error))
	else:
		print("Started Server")

func runningGame():
	if turn_index == 0: #set new seed only first round
		rng.randomize()
		print("Seed: ", rng.seed)
		var used_num = []
		var j = 0
		while j < 5:
			var num = rng.randi_range(1, 9)
			if used_num.find(num) != - 1: continue
			used_num.append(num)
			j += 1
		used_num.sort()
		var target_num = rng.randi_range(1, 9)
		broadcast_to_all({"message": Message.sendSeed, "used_num": used_num, "target_num": target_num})
	
	var turn_name = clients[clients.keys()[turn_index]].attributes.name
	for client_id in clients.keys():
		if client_id == clients.keys()[turn_index]:
			send_to_client(client_id,{
				"message": Message.runningGame, 
				"data": "ShowModalAsTurn", 
				"turn_name": turn_name, 
				"turn_num": turn_index
			})
		elif client_id != clients.keys()[turn_index]:
			send_to_client(client_id,{
				"message": Message.runningGame, 
				"data": "ShowModal", 
				"turn_name": turn_name,
				"turn_num": turn_index
			})


func _on_start_server_pressed() -> void:
	startServer()
