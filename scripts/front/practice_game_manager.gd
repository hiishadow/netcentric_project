extends Node

var main
var sign_node = preload("res://scenes/front/sign_panel.tscn")
var play_zone = []
var play_zone_card_slot = []
var play_zone_sign_slot = []
var card_slot = []
var sign_slot = []
var recent_card_slot = 0
var recent_sign_slot = 0
var game_time: int = 60
var modal_time: int = 5
var final_time: int
var modal_is_on: bool = false
var can_submit: bool = false
var can_delete: bool = false
var used_pool = []
var used_num
var target_num
var seed_answer
var is_clicked = false

var your_turn: bool = true
var single_player = true
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	main = get_tree().root.get_child(0)
	if get_tree().root.get_node("main").is_server:
		%ResetGame.visible = true
	
	random_from_pool()
	
	slot_path()
	
	generate_target_and_numbers()
	
	set_up_card_panel()
	%GameTimer.start()

func random_from_pool():
	used_num = []
	target_num = 0
	var pool = [
		[1,3,4,5,6,7],#3+4-7+6-5
		[2,1,4,5,6,8],#8/4-1+6-5
		[3,1,2,3,5,7],#7-5+3-2x1
		[4,1,2,3,6,8],#8-6-2+1+3
		[5,2,3,5,7,8],#7-3-8/2+5
		[6,1,2,3,5,7],#7-1+2+3-5
		[7,1,2,4,7,8],#8-2x4x1+7
		[8,2,4,5,6,9],#2+6+9-4-5
		[9,5,6,7,8,9] #9+5+8-6-7
		]
	
	var pool_answer = [
		"3+4-7+6-5",
		"8/4-1+6-5",
		"7-5+3-2x1",
		"8-6-2+1+3",
		"7-3-8/2+5",
		"7-1+2+3-5",
		"8-2x4x1+7",
		"2+6+9-4-5",
		"9+5+8-6-7"
	]
	
	var arr = pool[rng.randi_range(0, pool.size() -1)]
	while used_pool.find(arr) != -1:
		arr = pool[rng.randi_range(0, pool.size() -1)]
	target_num = arr[0]
	for i in arr.size():
		if i != 0:
			used_num.append(arr[i])
	used_num.sort()
	used_pool.append(arr)
	print("seed_pool:", pool.find(arr))
	seed_answer = pool_answer[pool.find(arr)]
	print(seed_answer)

func slot_path():
	play_zone_card_slot = [
	$"../PlayZone/PlayCardHolderPanel",
	$"../PlayZone/PlayCardHolderPanel2",
	$"../PlayZone/PlayCardHolderPanel3",
	$"../PlayZone/PlayCardHolderPanel4",
	$"../PlayZone/PlayCardHolderPanel5"
	]
	play_zone_sign_slot = [
	$"../PlayZone/PlaySignHolderPanel",
	$"../PlayZone/PlaySignHolderPanel2",
	$"../PlayZone/PlaySignHolderPanel3",
	$"../PlayZone/PlaySignHolderPanel4"
	]

	card_slot = [
	$"../Numbers/CardHolderPanel",
	$"../Numbers/CardHolderPanel2",
	$"../Numbers/CardHolderPanel3",
	$"../Numbers/CardHolderPanel4",
	$"../Numbers/CardHolderPanel5"
	]
	
	sign_slot = [
	$"../Signs/SignPanel",
	$"../Signs/SignPanel2",
	$"../Signs/SignPanel3",
	$"../Signs/SignPanel4"
	]

func set_up_card_panel():
	$"../Numbers/CardPanel".holder_position = "0"
	$"../Numbers/CardPanel2".holder_position = "1"
	$"../Numbers/CardPanel3".holder_position = "2"
	$"../Numbers/CardPanel4".holder_position = "3"
	$"../Numbers/CardPanel5".holder_position = "4"
	
	$"../Numbers/CardPanel".global_position = $"../Numbers/CardHolderPanel".global_position
	$"../Numbers/CardPanel2".global_position =$"../Numbers/CardHolderPanel2".global_position
	$"../Numbers/CardPanel3".global_position = $"../Numbers/CardHolderPanel3".global_position
	$"../Numbers/CardPanel4".global_position =$"../Numbers/CardHolderPanel4".global_position
	$"../Numbers/CardPanel5".global_position =$"../Numbers/CardHolderPanel5".global_position

func setSeed(_used_num, _target_num, _seed_answer):
	used_num = _used_num
	target_num = _target_num
	seed_answer = _seed_answer
	%timeup_answer.get_node("Label4").text = "solution: " + str(seed_answer)

func generate_target_and_numbers():
	for i in used_num.size():
		match i:
			0:
				$"../Numbers/CardPanel".number = used_num[0]
				$"../Numbers/CardPanel".set_label()
			1:
				$"../Numbers/CardPanel2".number = used_num[1]
				$"../Numbers/CardPanel2".set_label()
			2:
				$"../Numbers/CardPanel3".number = used_num[2]
				$"../Numbers/CardPanel3".set_label()
			3:
				$"../Numbers/CardPanel4".number = used_num[3]
				$"../Numbers/CardPanel4".set_label()
			4:
				$"../Numbers/CardPanel5".number = used_num[4]
				$"../Numbers/CardPanel5".set_label()
	
	%TargetPanel.get_node("Label").text = str(target_num)

func reverse_set_up_card_panel():
	while play_zone.size() != 0:
		delete()

	$"../Numbers/CardPanel".global_position = Vector2(-1000,1000)
	$"../Numbers/CardPanel2".global_position =Vector2(-1000,1000)
	$"../Numbers/CardPanel3".global_position = Vector2(-1000,1000)
	$"../Numbers/CardPanel4".global_position =Vector2(-1000,1000)
	$"../Numbers/CardPanel5".global_position = Vector2(-1000,1000)

	%TargetPanel.get_node("Label").text = "#"

func calculate_card_slot(card):
	if recent_card_slot < 5 and recent_card_slot <= recent_sign_slot and card.zone == "number":
		if get_tree().root.get_node("main").face_down_mode:
			card.get_node("Label").text = "#"
		card.zone = "play"
		
		card.get_node("Panel2").size = card.get_node("Panel2").size + Vector2(28,41)
		card.get_node("Panel").size = card.get_node("Panel").size + Vector2(28,41)
		card.get_node("Label").size = card.get_node("Label").size + Vector2(28,41)
		card.get_node("ClickArea").size = card.get_node("ClickArea").size + Vector2(28,41)
		card.get_node("Label").set("theme_override_font_sizes/font_size", 130)
		card.modulate.a = 1.0
		
		card.global_position = play_zone_card_slot[recent_card_slot].global_position
		recent_card_slot += 1
		play_zone.append(card)
		if play_zone.size() == 9:
			var new_sb = StyleBoxFlat.new()
			new_sb.bg_color = Color(0.882, 0.341, 0.302)
			var styleBox: StyleBoxFlat = $"../SubmitPanel".get_node("Panel2").get_theme_stylebox("panel")
			styleBox.set("bg_color", Color(0.882, 0.341, 0.302))
			$"../SubmitPanel".get_node("Panel2").add_theme_stylebox_override("panel", styleBox)
			can_submit = true
		if play_zone.size() == 1:
			var new_sb = StyleBoxFlat.new()
			new_sb.bg_color = Color(1, 0.725, 0.141)
			var styleBox: StyleBoxFlat = $"../DeletePanel".get_node("Panel2").get_theme_stylebox("panel")
			styleBox.set("bg_color", Color(1, 0.725, 0.141))
			$"../DeletePanel".get_node("Panel2").add_theme_stylebox_override("panel", styleBox)
			can_delete = true

func calculate_sign_slot(sign_):
	if recent_sign_slot < 4 and recent_card_slot > recent_sign_slot and sign_.zone == "number":
		var signn_ = sign_node.instantiate()
		signn_._sign = sign_._sign
		signn_.zone = "play"
		signn_.get_node("Panel").size = signn_.get_node("Panel").size + Vector2(16,16)
		signn_.get_node("Panel2").size = signn_.get_node("Panel2").size + Vector2(16,16)
		signn_.get_node("Label").size = signn_.get_node("Label").size + Vector2(16,16)
		signn_.get_node("ClickArea").size = signn_.get_node("ClickArea").size + Vector2(16,16)
		signn_.get_node("Label").set("theme_override_font_sizes/font_size", 80)
		signn_.global_position = play_zone_sign_slot[recent_sign_slot].global_position
		get_tree().root.get_node("main").get_node("PracticeGame").add_child(signn_, true)
		if get_tree().root.get_node("main").face_down_mode:
			signn_.get_node("Label").text = "#"
		recent_sign_slot += 1
		play_zone.append(signn_)

func display_player_count(count):
	if count == 1:
		$"../P1Name".visible = true
		$"../P1Score".visible = true
		$"../P1Avatar".visible = true
	elif count == 2:
		$"../P1Name".visible = true
		$"../P1Score".visible = true
		$"../P1Avatar".visible = true
		$"../P2Name".visible = true
		$"../P2Score".visible = true
		$"../P2Avatar".visible = true

func delete():
	if play_zone.size() == 0: return
	if play_zone.size() == 9:
		var new_sb = StyleBoxFlat.new()
		new_sb.bg_color = Color(0.714, 0.714, 0.714)
		var styleBox: StyleBoxFlat = $"../SubmitPanel".get_node("Panel2").get_theme_stylebox("panel")
		styleBox.set("bg_color", Color(0.714, 0.714, 0.714))
		$"../SubmitPanel".get_node("Panel2").add_theme_stylebox_override("panel", styleBox)
		$"../SubmitPanel".modulate.a = 1.0
		can_submit = false
	if play_zone.size() == 1:
		var new_sb = StyleBoxFlat.new()
		new_sb.bg_color = Color(0.714, 0.714, 0.714)
		var styleBox: StyleBoxFlat = $"../DeletePanel".get_node("Panel2").get_theme_stylebox("panel")
		styleBox.set("bg_color", Color(0.714, 0.714, 0.714))
		$"../DeletePanel".get_node("Panel2").add_theme_stylebox_override("panel", styleBox)
		$"../DeletePanel".modulate.a = 1.0
		can_delete = false

		
	var card = play_zone[play_zone.size() - 1]
	card.zone = "number"

	if card.node_type == "card":
		card.set_label()
		card.get_node("Panel2").size = card.get_node("Panel2").size - Vector2(28,41)
		card.get_node("Panel").size = card.get_node("Panel").size - Vector2(28,41)
		card.get_node("Label").size = card.get_node("Label").size - Vector2(28,41)
		card.get_node("ClickArea").size = card.get_node("ClickArea").size - Vector2(28,41)
		card.get_node("Label").set("theme_override_font_sizes/font_size", 110)
		card.global_position = card_slot[card.holder_position].global_position
		recent_card_slot -= 1
	elif card.node_type == "sign":
		card.queue_free()
		recent_sign_slot -= 1
	play_zone.pop_back()

func submit():
	if play_zone.size() != 9: return
	modal_time = 5
	%CorrectAnswer.get_node("Label3").text = "AUTOSTART IN " + str(modal_time) + " SECONDS"
	%WrongAnswer.get_node("Label3").text = "AUTOCLOSE IN " + str(modal_time) + " SECONDS"
	
	var play_zone_ = []
	for i in play_zone.size():
		if play_zone[i].node_type == "sign":
			play_zone_.append(play_zone[i]._sign)
		elif play_zone[i].node_type == "card":
			play_zone_.append(play_zone[i].number)
	var i = 1  # Start at the first operator (index 1)

	# First pass: Handle multiplication and division
	while i < play_zone_.size():
		if play_zone_[i] == "multiply":
			play_zone_[i - 1] *= play_zone_[i + 1]
			play_zone_.remove_at(i)  # Remove operator
			play_zone_.remove_at(i)  # Remove the number after operator
		elif play_zone_[i] == "divide":
			if play_zone_[i + 1] != 0:
				play_zone_[i - 1] /= play_zone_[i + 1]
				play_zone_.remove_at(i)  # Remove operator
				play_zone_.remove_at(i)  # Remove the number after operator
			else:
				print("Error: Division by zero")
				return null
		else:
			i += 2  # Skip to the next operator

	# Second pass: Handle addition and subtraction
	i = 1  # Reset to first operator
	var result = play_zone_[0]
	while i < play_zone_.size():
		if play_zone_[i] == "plus":
			result += play_zone_[i + 1]
		elif play_zone_[i] == "minus":
			result -= play_zone_[i + 1]
		i += 2  # Move to the next operator
		
	if result != int(%TargetPanel.get_node("Label").text):
		%WrongAnswer.visible = true
		modal_is_on = true
		%ModalTimer.start()
		final_time = 0
	else:
		%GameTimer.stop()
		final_time = int($"../Time".get_node("Label").text)
		
		%CorrectAnswer.visible = true
		modal_is_on = true
		%CorrectAnswer.get_node("Label2").text = "YOU USED " + str(60 - final_time) + " SECONDS"
		%ModalTimer.start()

func send_equation():
	var equation = ""
	for i in play_zone.size():
		equation += (str(play_zone[i].get_node("Label").text))
	return equation

#GameTimer
func _on_timer_timeout() -> void:
	if game_time == 0: 
		%GameTimer.stop()
		if your_turn:

			%timeup_answer.visible = true
			%ModalTimer.start()
		
		game_time = 60
		return
	
	game_time -= 1
	if %EnemyTime.visible:
		%EnemyTime.get_node("Label").text = "TIME : " + str(game_time)
	if %Time.visible:
		%Time.get_node("Label").text = "TIME : " + str(game_time)


func _on_modal_timer_timeout() -> void:
	if modal_time == 0: 
		%ModalTimer.stop()
		if %WrongAnswer.visible:
			%WrongAnswer.visible = false
		if %CorrectAnswer.visible:
			%CorrectAnswer.visible = false
			%Time.get_node("Label").text = "TIME: 60"
			reverse_set_up_card_panel()
			random_from_pool()
			generate_target_and_numbers()
			set_up_card_panel()
			game_time = 60
			modal_time = 5
			%GameTimer.start()
		if %timeup_answer.visible:
			%timeup_answer.visible = false
		if %TurnOfEnemy.visible:
			if your_turn:
				generate_target_and_numbers()
				set_up_card_panel()
				%Turn.get_node("Label").text = "your turn"
				%EnemyTime.visible = false
				%Time.visible = true
				%GameTimer.start()
				
			else:
				reverse_set_up_card_panel()
				%EnemyTime.visible = true
				%Time.visible = false
				%Turn.get_node("Label").text = "enemy's turn"
			%P1Avatar.visible = false
			%P2Avatar.visible = false
			%TurnOfEnemy.visible = false
			%ReadyPanel.visible = false
			%DeletePanel.visible = true
			%SubmitPanel.visible = true
			%Turn.visible = true
		if %Winner.visible:
			%Winner.visible = false
			#START NEXT GAME
			if is_clicked:
				is_clicked = false
			
		modal_is_on = false
		modal_time = 5
		return
		
	modal_time -= 1
	if %WrongAnswer.visible:
		%WrongAnswer.get_node("Label3").text = "AUTOCLOSE IN " + str(modal_time) + " SECONDS"
	if %CorrectAnswer.visible:
		%CorrectAnswer.get_node("Label3").text = "AUTOSTART IN " + str(modal_time) + " SECONDS"
	if %TurnOfEnemy.visible:
		%TurnOfEnemy.get_node("Label3").text = "AUTOSTART IN " + str(modal_time) + " SECONDS"
	if %timeup_answer.visible:
		%timeup_answer.get_node("Label3").text = "AUTOCLOSE IN " + str(modal_time) + " SECONDS"
	if %Winner.visible:
		%Winner.get_node("Label3").text = "AUTOSTART IN " + str(modal_time) + " SECONDS"


func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		get_parent().call_deferred("queue_free")


func _on_click_area_mouse_entered() -> void:
		get_parent().get_node("Panel2").modulate.a = 0.8


func _on_click_area_mouse_exited() -> void:
		get_parent().get_node("Panel2").modulate.a = 1.0
