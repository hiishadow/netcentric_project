extends Node

var is_server = false
var server = null
var client = null


func _on_start_as_server_pressed() -> void:
	%Opening.hide()
	%Server.startServer()
	%HUD.get_node("header").text = "SERVER" + str(OS.get_process_id())
	is_server = true
	%Client.connectToServer("127.0.0.1")


func _on_start_as_client_pressed() -> void:
	%Opening.hide()
	%HUD.get_node("header").text = "CLIENT" + str(OS.get_process_id())
	%Client.connectToServer("127.0.0.1")
	%Server.queue_free()
