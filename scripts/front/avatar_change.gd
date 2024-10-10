extends Control

var selected_avatar=null
var selected_texture
@onready var main_avatar = $"../MainBox/AvatarContainer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CloseAvatarMenu.pressed.connect(func():
		$".".visible=false
		)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald/Panel
	
func _on_click_area_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald2/Panel
	
func _on_click_area_3_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald3/Panel

func _on_click_area_4_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald4/Panel

func _on_click_area_5_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald5/Panel

func _on_click_area_6_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald6/Panel

func _on_click_area_7_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald7/Panel

func _on_click_area_8_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald8/Panel

func _on_click_area_9_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald9/Panel

func _on_click_area_10_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		selected_avatar=$WhiteBox/bald10/Panel


func _on_confirm_pressed() -> void:
	if selected_avatar != null:
		# Change the avatar's texture based on the selected avatar's StyleBoxTexture
		selected_texture = selected_avatar.get_theme_stylebox("panel", "Panel")
		main_avatar.add_theme_stylebox_override("panel", selected_texture)
		$".".visible = false  # Hide the character selection screen
	else:
		# If no avatar is selected, apply a default texture from another panel
		var default_texture = $WhiteBox/bald/Panel.get_theme_stylebox("panel", "Panel")
		selected_texture = default_texture
		main_avatar.add_theme_stylebox_override("panel", default_texture)
		$".".visible = false  # Hide the character selection screen
