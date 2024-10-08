extends Control


func _on_click_area_gui_input(event: InputEvent) -> void:
	if %GameManager.modal_is_on: return
	if event is InputEventMouseButton and event.is_pressed():
		%GameManager.delete()

func _on_click_area_mouse_entered() -> void:
	if !%GameManager.can_delete: return
	modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	if !%GameManager.can_delete: return
	modulate.a = 1.0
