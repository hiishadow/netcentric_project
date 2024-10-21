extends Label


func _process(delta: float) -> void:
	text = "your_turn: " + str(%GameManager.your_turn) + "\ngame_time: " + str(%GameManager.game_time) + "\nmodal_time: "+ str(%GameManager.modal_time) + "\nfinal_time: "+ str(%GameManager.final_time) + "\nis_clicked: " + str(%GameManager.is_clicked)
