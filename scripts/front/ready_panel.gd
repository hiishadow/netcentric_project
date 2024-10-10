extends Control

var is_ready: bool = false
var two_player: bool = false


func _on_click_area_gui_input(event: InputEvent) -> void:
	if !two_player: return
	if event is InputEventMouseButton and event.is_pressed():
		if !is_ready:
			$Label.text = "CANCEL\nREADY"
			var new_sb = StyleBoxFlat.new()
			new_sb.bg_color = Color(0.714, 0.714, 0.714)
			var styleBox: StyleBoxFlat = $Panel2.get_theme_stylebox("panel")
			styleBox.set("bg_color", Color(0.714, 0.714, 0.714))
			$Panel2.add_theme_stylebox_override("panel", styleBox)
			is_ready = true
			
			get_tree().root.get_child(0).get_node("Client").request_ready_count("add")
		else:
			$Label.text = "READY"
			var new_sb = StyleBoxFlat.new()
			new_sb.bg_color = Color(0.882, 0.341, 0.302)
			var styleBox: StyleBoxFlat = $Panel2.get_theme_stylebox("panel")
			styleBox.set("bg_color", Color(0.882, 0.341, 0.302))
			$Panel2.add_theme_stylebox_override("panel", styleBox)
			is_ready = false
			
			get_tree().root.get_child(0).get_node("Client").request_ready_count("remove")

func _on_click_area_mouse_entered() -> void:
	if !two_player: return
	modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
	if !two_player: return
	modulate.a = 1.0

func change():
	two_player = true
	var new_sb = StyleBoxFlat.new()
	new_sb.bg_color = Color(0.882, 0.341, 0.302)
	var styleBox: StyleBoxFlat = $Panel2.get_theme_stylebox("panel")
	styleBox.set("bg_color", Color(0.882, 0.341, 0.302))
	$Panel2.add_theme_stylebox_override("panel", styleBox)
