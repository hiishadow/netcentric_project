extends Control



func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		get_tree().root.get_child(0).get_node("Game").get_node("RulePage").visible = true
		


func _on_click_area_mouse_entered() -> void:
	%Close.modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	%Close.modulate.a = 1.0
