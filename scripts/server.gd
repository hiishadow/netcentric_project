extends Node

enum Message {
	setID,
	newUserConnected,
	userDisconnected,
	updateUserAttributes,
	updateLeaderBoard,
	sendTimeUsage,
	confirmConnection,
	test
}

var peer = WebSocketMultiplayerPeer.new()
var clients = {}  # Dictionary to store each player's attributes by their ID

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
			print("Server received from peer " + str(sender_id) + ": " + str(data))

			if data.has("message"):
				handle_message(data, sender_id)

func handle_message(data, sender_id):
	match data.message:
		Message.updateUserAttributes:
			# Update the user's attributes on the server
			if data.has("data") and sender_id in clients:
				clients[sender_id].attributes = data.data
				broadcast_to_all({"message": Message.updateUserAttributes, "data": clients[sender_id]})
		# Add more cases as needed

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
		"data": clients[id]
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

func _on_start_server_pressed() -> void:
	startServer()
