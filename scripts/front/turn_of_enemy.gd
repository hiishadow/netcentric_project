extends Control




func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		%ModalTimer.stop()
		%GameManager.modal_time = 0
		%GameManager._on_modal_timer_timeout()
		if %GameManager.your_turn:
			var client = get_tree().root.get_child(0).get_node("Client")
			client.send_to_server({
				"message": client.Message.closeModal, "client_id": client.id
			})

func _on_click_area_mouse_entered() -> void:
	%Close.modulate.a = 0.8
	pass # Replace with function body.


func _on_click_area_mouse_exited() -> void:
	%Close.modulate.a = 1.0
	pass # Replace with function body.
