extends Control

var index = 0
const color_pool = [
	Color(0.894, 0.533, 0.235),
	Color(0.882, 0.341, 0.302),
	Color(0.984, 0.918, 0.914),
	Color(0.53, 0.495, 0.493)
	]
var color = color_pool[0]

func _ready() -> void:
	index = 0


func _on_panel_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		index += 1
		color = color_pool[index % color_pool.size()]
		set_new()
		

func set_new():
	var new_sb = StyleBoxFlat.new()
	new_sb.bg_color = color
	var styleBox: StyleBoxFlat = get_node("Panel2").get_theme_stylebox("panel")
	styleBox.set("bg_color", color)
	get_node("Panel2").add_theme_stylebox_override("panel", styleBox)
	
	get_parent().get_node("Background").get_node("Panel").add_theme_stylebox_override("panel", styleBox)
