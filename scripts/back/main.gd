extends Node

var is_server = false
var server = null
var client = null


func _on_start_as_server_pressed() -> void:
	%BecomeHost.hide()
	%JoinAsClient.hide()
	%Server.startServer()
	%HUD.get_node("header").text = "SERVER" + str(OS.get_process_id())
	is_server = true
	#%Client.connectToServer("26.26.253.235")
	%Client.connectToServer("127.0.0.1")



func _on_start_as_client_pressed() -> void:
	%BecomeHost.hide()
	%JoinAsClient.hide()
	
	%HUD.get_node("header").text = "CLIENT" + str(OS.get_process_id())
	#%Client.connectToServer("26.26.253.235")
	%Client.connectToServer("127.0.0.1")
	%Server.queue_free()


func _on_quick_play_pressed() -> void:
	#fix when show to teacher
	var be_server = true
	if be_server:
		_on_start_as_server_pressed()
	else:
		_on_start_as_client_pressed()
