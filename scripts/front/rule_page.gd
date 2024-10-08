extends Control


func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		print("huh")

func _on_click_area_mouse_entered() -> void:
	%Panel2.modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	%Panel2.modulate.a = 1.0
