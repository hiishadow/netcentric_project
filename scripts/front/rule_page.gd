extends Control

var from_welcome = false

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		self.hide()
		if from_welcome:
			get_tree().root.get_child(0).get_node("Game").get_node("Welcome").visible = true
			from_welcome = false

func _on_click_area_mouse_entered() -> void:
	%Panel2.modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	%Panel2.modulate.a = 1.0
