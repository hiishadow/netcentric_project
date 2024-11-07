extends Node

@export var ip_add: String = "127.0.0.1"
var is_server = false
var server = null
var client = null
var modal_is_on = false
var face_down_mode = false
var total_turn = 2
var server_window = preload("res://scenes/back/server_window.tscn")
var cli = preload("res://scenes/back/client.tscn")
var ser = preload("res://scenes/back/server.tscn")
var name1 = "Steve"
var name2 = "Alex"
var name_index = 0

func _ready():
	random_name()
	get_viewport().set_embedding_subwindows(false)

func _on_start_as_server_pressed() -> void:
	var d = server_window.instantiate()
	add_child(d)
	
	is_server = true
	get_node("Client").connectToServer(ip_add)


func _on_start_as_client_pressed() -> void:
	if modal_is_on: return
	
	if has_node("Server2"):
		get_node("Server2").name = "Server"
	if has_node("Client2"):
		get_node("Client2").name = "Client"
	
	get_node("Server").startServer()

func _on_quick_play_pressed() -> void:
	if modal_is_on: return
	
	if has_node("Server2"):
		get_node("Server2").name = "Server"
	if has_node("Client2"):
		get_node("Client2").name = "Client"
		
	var input_text = %LineEdit.text
	if input_text.is_valid_int() and int(input_text) > 0:
		total_turn = int(input_text)
	
	get_node("Client").connectToServer(ip_add)



func _on_face_down_toggled(toggled_on: bool) -> void:
	if toggled_on:
		face_down_mode = true
	else:
		face_down_mode = false

func backToMain():
	%HUD.hide()
	if self.has_node("ServerWindow"):
		get_node("ServerWindow").call_deferred("queue_free")
	get_node("Client").call_deferred("queue_free")
	if self.has_node("Server"):
		get_node("Server").call_deferred("queue_free")
	get_node("Game").call_deferred("queue_free")
	var a = cli.instantiate()
	var b = ser.instantiate()

	call_deferred("add_child", a, true)
	call_deferred("add_child", b, true)
	
	name_index = 0
	total_turn = 2
	is_server = false
	random_name()
	pass

func random_name():
	randomize()
	var names = [
		"James", "Mary", "John", "Patricia", "Robert", "Jennifer", 
		"Michael", "Linda", "William", "Elizabeth", "David", "Barbara", 
		"Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", 
		"Charles", "Steve"
	]
	names.shuffle()
	print(names)
	name1 = names[0]
	name2 = names[1]
