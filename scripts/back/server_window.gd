extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


func _on_reset_game_pressed() -> void:
	get_tree().root.get_node("main").get_node("Game").get_node("GameManager")._on_reset_game_pressed()
