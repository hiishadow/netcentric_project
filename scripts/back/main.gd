extends Node

const ip_add: String = "127.0.0.1"
var is_server = false
var server = null
var client = null
var modal_is_on = false
var face_down_mode = false
var total_turn = 3
var server_window = preload("res://scenes/back/server_window.tscn")

func _ready():
	get_viewport().set_embedding_subwindows(false)

func _on_start_as_server_pressed() -> void:
	if modal_is_on: return
	var d = server_window.instantiate()
	add_child(d)
	
	%BecomeHost.hide()
	%JoinAsClient.hide()
	%Server.startServer()
	%HUD.get_node("header").text = "SERVER" + str(OS.get_process_id())
	is_server = true
	
	var input_text = %LineEdit.text
	if input_text.is_valid_int() and int(input_text) > 0:
		total_turn = int(input_text)
	else:
		total_turn = 3
	
	#%Client.connectToServer("26.26.253.235")
	%Client.connectToServer(ip_add)



func _on_start_as_client_pressed() -> void:
	if modal_is_on: return
	%BecomeHost.hide()
	%JoinAsClient.hide()
	
	%HUD.get_node("header").text = "CLIENT" + str(OS.get_process_id())

	#%Client.connectToServer("26.26.253.235")
	%Client.connectToServer(ip_add)
	if has_node("Server"):
		%Server.queue_free()


func _on_quick_play_pressed() -> void:
	if modal_is_on: return
	#FIXME fix when show to teacher
	var be_server = true
	if be_server:
		_on_start_as_server_pressed()
	else:
		_on_start_as_client_pressed()




func _on_face_down_toggled(toggled_on: bool) -> void:
	if toggled_on:
		face_down_mode = true
	else:
		face_down_mode = false
