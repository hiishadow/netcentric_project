extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_click_area_2_mouse_entered() -> void:
	modulate.a = 0.8


func _on_click_area_2_mouse_exited() -> void:
	modulate.a = 1.0
