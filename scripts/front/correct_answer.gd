extends Control

var client

func _ready() -> void:
	client = get_tree().root.get_child(0).get_node("Client")

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		%ModalTimer.stop()
		%GameManager.modal_time = 0
		%GameManager._on_modal_timer_timeout()

func _on_click_area_mouse_entered() -> void:
	%Close.modulate.a = 0.8

func _on_click_area_mouse_exited() -> void:
	%Close.modulate.a = 1.0
