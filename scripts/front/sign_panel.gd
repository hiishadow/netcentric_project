extends Control

const node_type = "sign"

@export var sign: String
var zone = "number"

func _ready() -> void:
	match sign:
		"plus":
			%Label.text = "+"
		"minus":
			%Label.text = "-"
		"multiply":
			%Label.text = "×"
		"divide":
			%Label.text = "÷"
		_:
			%Label.text = ""

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if zone == "number":
			if %GameManager.modal_is_on: return
			%GameManager.calculate_sign_slot(self)

func _on_click_area_mouse_entered() -> void:
	if zone != "number": return
	modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	if zone != "number": return
	modulate.a = 1.0
