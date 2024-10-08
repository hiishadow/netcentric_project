extends Control

const node_type = "card"

@export var number: int
var holder_position: int
var zone = "number"

func set_label():
	%Label.text = str(number)

func _on_click_area_gui_input(event: InputEvent) -> void:
	if %GameManager.modal_is_on: return
	if event is InputEventMouseButton and event.is_pressed():
		%GameManager.calculate_card_slot(self)

func _on_click_area_mouse_entered() -> void:
	if zone != "number": return
	modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	if zone != "number": return
	modulate.a = 1.0
