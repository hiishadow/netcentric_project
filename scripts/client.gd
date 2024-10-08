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
	test
}

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
			print("Client received packet: " + str(data))
			
			match int(data.message):
				Message.confirmConnection:
					handleConfirmConnection()
				Message.setID:
					id = data.data
					print("Assigned ID: " + str(id))
				Message.newUserConnected:
					print("User connected: " + str(data.data))
					handleNewUserConnected(data.data)
				Message.userDisconnected:
					print("User disconnected: " + str(data.data))
				Message.updateUserAttributes:
					print("Player attributes updated: " + str(data.data))
					handleUpdateUserAttributes(data.data)
				_:
					print("Unknown message type")

func connectToServer(ip):
	var error = peer.create_client("ws://" + ip + ":8888")
	if error != OK:
		print("Error connecting to server: " + str(error))
	else:
		print("Started client")

func _on_start_client_pressed() -> void:
	connectToServer("127.0.0.1")

func handleNewUserConnected(data) -> void:
	# pop up show new user connected
	pass

func handleUpdateUserAttributes(data)-> void:
	pass

func handleConfirmConnection():
	# close home page to start game page
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
	
