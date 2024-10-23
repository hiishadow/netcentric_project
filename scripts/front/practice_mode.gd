extends Control

var practice_game = preload("res://scenes/front/practice_game.tscn")


func _on_click_area_gui_input(event: InputEvent) -> void:
	if get_parent().modal_is_on: return
	if event is InputEventMouseButton and event.is_pressed():
		print("Enter Practice Mode")
		var game_instant = practice_game.instantiate()
		get_parent().add_child(game_instant)
		


func _on_click_area_mouse_entered() -> void:
	if get_parent().modal_is_on: return
	modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	if get_parent().modal_is_on: return
	modulate.a = 1.0
