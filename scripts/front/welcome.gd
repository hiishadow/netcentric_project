extends Node




func _on_click_area_gui_input(event: InputEvent) -> void:
	#Close
	if event is InputEventMouseButton and event.is_pressed():
		self.visible = false



func _on_click_area_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		self.visible = false
		get_tree().root.get_child(0).get_node("Game").get_node("RulePage").visible = true
		get_tree().root.get_child(0).get_node("Game").get_node("RulePage").from_welcome = true
		


func _on_click_area_mouse_entered() -> void:
	%Close.modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	%Close.modulate.a = 1.0


func _on_click_area_2_mouse_entered() -> void:
	%Rules.modulate.a = 0.8


func _on_click_area_2_mouse_exited() -> void:
	%Rules.modulate.a = 1.0
