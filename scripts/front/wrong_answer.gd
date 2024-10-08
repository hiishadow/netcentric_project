extends Control


func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		self.visible = false
		%GameManager.modal_is_on = false

func _on_click_area_mouse_entered() -> void:
	%Close.modulate.a = 0.8

func _on_click_area_mouse_exited() -> void:
	%Close.modulate.a = 1.0
