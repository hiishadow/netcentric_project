extends Node

var is_server = false
var server = null
var client = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_as_server_pressed() -> void:
	%Opening.hide()
	%Server.startServer()
	is_server = true
	%Client.connectToServer("127.0.0.1")
	%Client.get_node("GameView").hide()



func _on_start_as_client_pressed() -> void:
	%Opening.hide()
	%Client.connectToServer("127.0.0.1")
	%Client.get_node("GameView").hide()
	
