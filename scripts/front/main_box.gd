extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Replace with function body.
	$"../AvatarChange".visible=false
	%EditAvatar.pressed.connect(func():
		$"../AvatarChange".visible=true
		get_parent().get_parent().modal_is_on = true
		)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bald_gui_input(event: InputEvent) -> void:
	$AvatarContainer # Replace with function body.
