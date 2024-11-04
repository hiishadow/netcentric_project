extends Node



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
	resetGame
}

var rng = RandomNumberGenerator.new()
var peer = WebSocketMultiplayerPeer.new()
var clients = {}  # Dictionary to store each player's attributes by their ID
var ready_count = []
var time_usage = {}
var turn_index = 0
var equations = {}
var diff_score = {}
var used_num = []
var target_num = 0
var used_pool = []
var seed_answer = ""

func _ready() -> void:
	rng.randomize()
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
				handle_message(data, int(sender_id))

func handle_message(data, sender_id):
	match int(data.message):
		Message.updateUserAttributes:
			# Update the user's attributes on the server
			if data.has("data"):
				clients[sender_id].attributes = data.data
				broadcast_to_all({"message": Message.updateUserAttributes, "data": clients[sender_id], "clients": clients})
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
		Message.sendDiffScore:
			if data.has("data"):
				diff_score[sender_id] = data.data
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
			elif data.data == "NextRound":
				turn_index = 0
				for client_id in clients.keys():
					if client_id != sender_id:
						send_to_client(client_id, {"message": Message.forceClosed})
				runningGame()
			elif data.data == "CalculateWinner":
				var winner
				var min = 9999
				for i in time_usage.keys():
					if time_usage[i] <= min:
						min = time_usage[i]
						winner = i
				
				if time_usage[time_usage.keys()[0]] == 999 and time_usage[time_usage.keys()[1]] == 999:
					if diff_score[time_usage.keys()[0]] == 999 and diff_score[time_usage.keys()[1]] == 999:
						broadcast_to_all({"message": Message.runningGame, "data": "CalculateWinner", 
							"time_usage": time_usage,
							"winner": "NO WINNER",
							"equations": equations,
							"clients": clients,
						})
					elif diff_score[time_usage.keys()[0]] == diff_score[time_usage.keys()[1]]:
						print("XXXXXXXX")
						broadcast_to_all({"message": Message.runningGame, "data": "CalculateWinner", 
							"time_usage": time_usage,
							"winner": "tie",
							"equations": equations,
							"clients": clients
						})
					else:
						#closest winner
						var closest_winner
						var closest_min = 999
						for j in diff_score.keys():
							if diff_score[j] < closest_min:
								closest_min = diff_score[j]
								closest_winner = j
						broadcast_to_all({"message": Message.runningGame, "data": "CalculateWinner", 
							"time_usage": time_usage,
							"winner": clients[int(closest_winner)].attributes.name,
							"equations": equations,
							"clients": clients,
							"closest": true
						})
						clients[int(closest_winner)].attributes.score += 1
						broadcast_to_all({
							"message": Message.updateUserAttributes,
							"data": "updateScore",
							"clients": clients
						})
				elif time_usage[time_usage.keys()[0]] == time_usage[time_usage.keys()[1]]:
					broadcast_to_all({"message": Message.runningGame, "data": "CalculateWinner", 
						"time_usage": time_usage,
						"winner": "tie",
						"equations": equations,
						"clients": clients
					})
				elif time_usage[time_usage.keys()[0]] != time_usage[time_usage.keys()[1]]:
					broadcast_to_all({"message": Message.runningGame, "data": "CalculateWinner", 
						"time_usage": time_usage,
						"winner": clients[int(winner)].attributes.name,
						"equations": equations,
						"clients": clients
					})
					clients[int(winner)].attributes.score += 1
					broadcast_to_all({
						"message": Message.updateUserAttributes,
						"data": "updateScore",
						"clients": clients
					})
				time_usage = {}
				equations = {}
		Message.resetGame:
			ready_count = []
			time_usage = {}
			turn_index = 0
			equations = {}
			used_num = []
			target_num = 0
			used_pool = []
			seed_answer = ""
			for i in clients.keys():
				clients[i].attributes.score = 0
			broadcast_to_all({"message": Message.resetGame})

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
		"clients_num": clients.size(),
	})

func peer_disconnected(id):
	print("Peer Disconnected: " + str(id))
	clients.erase(id)
	var message = {
		"message": Message.userDisconnected,
		"data": "User " + str(id) + " has disconnected."
	}
	broadcast_to_all(message)
	get_tree().root.get_node("main").get_node("ServerWindow").get_node("PlayerCount").text = "PLAYERS ONLINE: " + str(clients.size())

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
		#rng.randomize()
		#rng.seed = 3672018741301020184
		#print("Seed: ", rng.seed)
		#var used_num = []
		#var j = 0
		#while j < 5:
		#	var num = rng.randi_range(1, 9)
		#	if used_num.find(num) != - 1: continue
		#	used_num.append(num)
		#	j += 1
		#used_num.sort()
		#var target_num = rng.randi_range(1, 9)
		
		random_from_pool()
		broadcast_to_all({"message": Message.sendSeed, "used_num": used_num, "target_num": target_num, "seed_answer": seed_answer})
	
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

func random_from_pool():
	used_num = []
	target_num = 0
	var pool = [
		[1,3,4,5,6,7],#3+4-7+6-5
		[2,1,4,5,6,8],#8/4-1+6-5
		[3,1,2,3,5,7],#7-5+3-2x1
		[4,1,2,3,6,8],#8-6-2+1+3
		[5,2,3,5,7,8],#7-3-8/2+5
		[6,1,2,3,5,7],#7-1+2+3-5
		[7,1,2,4,7,8],#8-2x4x1+7
		[8,2,4,5,6,9],#2+6+9-4-5
		[9,5,6,7,8,9] #9+5+8-6-7
		]
	
	var pool_answer = [
		"3+4-7+6-5",
		"8/4-1+6-5",
		"7-5+3-2x1",
		"8-6-2+1+3",
		"7-3-8/2+5",
		"7-1+2+3-5",
		"8-2x4x1+7",
		"2+6+9-4-5",
		"9+5+8-6-7"
	]
	
	var arr = pool[rng.randi_range(0, pool.size() -1)]
	while used_pool.find(arr) != -1:
		arr = pool[rng.randi_range(0, pool.size() -1)]
	target_num = arr[0]
	for i in arr.size():
		if i != 0:
			used_num.append(arr[i])
	used_num.sort()
	used_pool.append(arr)
	print("seed_pool:", pool.find(arr))
	seed_answer = pool_answer[pool.find(arr)]
	print(seed_answer)

func _on_start_server_pressed() -> void:
	startServer()
