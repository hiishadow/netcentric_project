extends Control  

# Declare references to nodes
@onready var character_selection_screen = $MainContainer/AvatarChange
@onready var pencil_button = $MainMenu/MainBox/EditAvatar

func _ready():
	# Hide the character selection screen at the start
	character_selection_screen.visible = false
	
	# Connect the button pressed signal to the function
	pencil_button.connect("pressed", Callable(self, "_on_pencil_button_pressed"))

# Function to handle what happens when pencil button is pressed
func _on_pencil_button_pressed():
	# Toggle the visibility of the character selection screen
	character_selection_screen.visible = true
	# Optionally, hide the main screen if needed
	# self.visible = false
