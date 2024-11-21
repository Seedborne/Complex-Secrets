extends Node2D

@export var player_scene: PackedScene 
var player = null
var elevator_open = false
var in_elevator = false
var near_button = false
var button_pressed = false
var near_entrance = false
var near_player_mailbox = false
var buttons = ["ClassButton", "WorkButton1", "WorkButton2", "WorkButton3"]  # Your button list
var selected_index = 0
var class_upcoming = false

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	if Globals.descending_stairs:
		player.position = Vector2(281, 260)
		Globals.descending_stairs = false
		Globals.current_location = "Lobby"
	elif Globals.current_location == "Elevator":
		player.position = Vector2(1380, 260)
		Globals.current_location = "Lobby"
		$ElevatorSprite.play("closed")
	elif Globals.current_location == "Gym":
		var animated_sprite = player.get_node("PlayerSprite")
		animated_sprite.flip_h = true
		player.position = Vector2(1800, 635)
		Globals.current_location = "Lobby"
	elif Globals.current_location == "Coffee Shop":
		player.position = Vector2(125, 615)
		Globals.current_location = "Lobby"
	elif Globals.at_class or Globals.at_work:
		Globals.at_class = false
		Globals.at_work = false
		player.position = Vector2(950, 950)
		Globals.current_location = "Lobby"
	elif Globals.new_game:
		Globals.new_game = false
		player.position = Vector2(950, 950)
		player.facing_direction = Vector2(0, -1)
		Globals.current_location = "Lobby"
		#Globals.schedule_keys_delivery()
		print("New Game Started")
	else:
		player.position = Vector2(950, 950)
		Globals.current_location = "Lobby"

	$VBoxContainer.visible = false
	Globals.current_floor = 0
	add_child(player)
	player.can_move = true
	player.visible = true
	UI.fade_from_black()
	print("In Lobby")

func _process(_delta):
	var day_name = UI.days_of_week[UI.current_day_index]
	for class_hour in UI.class_schedule.get(day_name, []):
		if UI.current_hour == (class_hour - 1):
			$VBoxContainer/ClassButton.visible = true
		elif UI.current_hour == class_hour:
			$VBoxContainer/ClassButton.visible = false
	if Globals.mailbox_items.size() > 0:
		$PlayerMailboxSprite.visible = true
	else:
		$PlayerMailboxSprite.visible = false
	#if UI.current_day_index == 0:
		#$CoffeeShopBody2D/CollisionShape2D.disabled = false
	if UI.current_hour >= 14:
		$CoffeeShopBody2D/CollisionShape2D.disabled = false
	elif UI.current_hour <= 5:
		$CoffeeShopBody2D/CollisionShape2D.disabled = false
	else:
		$CoffeeShopBody2D/CollisionShape2D.disabled = true
	if Globals.has_item_in_inventory("Gym Key"):
		$GymBody2D/CollisionShape2D.disabled = true
	else:
		$GymBody2D/CollisionShape2D.disabled = false

func _on_elevator_button_area_2d_body_entered(body):
	if body == player:
		near_button = true

func _on_elevator_button_area_2d_body_exited(body):
	if body == player:
		near_button = false

func _input(event):
	if event.is_action_pressed("ui_interact") and near_button and not elevator_open and not button_pressed:
		button_pressed = true
		$ButtonPressAudio.play()
		$ElevatorButtonSprite.visible = true
		$ElevatorAudio.play()
		await Globals.create_tracked_timer(2.5).timeout
		$ElevatorSprite.play("opening")
		$ElevatorOpenAudio.play()
		$ElevatorDingAudio.play()
	if event.is_action_pressed("scroll_down") and near_entrance and not Globals.at_class and not Globals.at_work:
		selected_index = (selected_index + 1) % buttons.size()
		highlight_button(selected_index)
	elif event.is_action_pressed("scroll_up") and near_entrance and not Globals.at_class and not Globals.at_work:
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		highlight_button(selected_index)
	elif event.is_action_pressed("ui_interact") and near_entrance and not Globals.at_class and not Globals.at_work:
		select_button(selected_index)
	if event.is_action_pressed("ui_interact") and near_player_mailbox:
		Globals.collect_mail()

func highlight_button(index):
	# Reset all children to default state
	for child in $VBoxContainer.get_children():
		child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
	var selected_child = $VBoxContainer.get_child(index)
	selected_child.focus_mode = Control.FOCUS_ALL
	selected_child.grab_focus()

func select_button(index):
	var selected_button = buttons[index]
	print("Selected button: %s" % selected_button)
	if selected_button == "ClassButton":
		_on_class_button_pressed()
	elif selected_button == "WorkButton1":
		_on_work_button_1_pressed()
	elif selected_button == "WorkButton2":
		_on_work_button_2_pressed()
	elif selected_button == "WorkButton3":
		_on_work_button_3_pressed()

func _on_elevator_sprite_animation_finished():
	if $ElevatorSprite.animation == "opening":
		$ElevatorBody2D/CollisionShape2D.disabled = true
		$ElevatorSprite.play("open")
		elevator_open = true
		button_pressed = false
		$ElevatorTimer.start()
	elif $ElevatorSprite.animation == "closing" and not in_elevator:
		$ElevatorButtonSprite.visible = false
		$ElevatorSprite.play("closed")
		elevator_open = false
	elif $ElevatorSprite.animation == "closing" and in_elevator:
		$ElevatorButtonSprite.visible = false
		$ElevatorSprite.play("closed")
		elevator_open = false
		get_tree().change_scene_to_file("res://Scenes/Elevator.tscn")

func _on_elevator_timer_timeout():
	$ElevatorBody2D/CollisionShape2D.disabled = false
	$ElevatorSprite.play("closing")
	$ElevatorCloseAudio.play()

func _on_elevator_area_2d_body_entered(body):
	if body == player:
		in_elevator = true
		player.can_move = false
		UI.fade_to_black()
		$ElevatorSprite.z_index = 1
		$ElevatorSprite.play("closing")
		$ElevatorCloseAudio.play()

func _on_stairs_area_2d_body_entered(body):
	if body == player:
		Globals.climbing_stairs = true
		player.can_move = false
		UI.play_stairs_audio()
		UI.fade_to_black()
		await Globals.create_tracked_timer(1.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor1.tscn")

func _on_coffee_shop_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		player.can_move = true
		UI.fade_from_black()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/CoffeeShop.tscn")

func _on_gym_area_2d_2_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		player.can_move = true
		UI.fade_from_black()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Gym.tscn")

func _on_entrance_area_2d_body_entered(body):
	if body == player:
		near_entrance = true
		var day_name = UI.days_of_week[UI.current_day_index]  # Get day name from current day index
		# Check for each scheduled class in the current day
		for class_hour in UI.class_schedule.get(day_name, []):
			if UI.current_hour == (class_hour - 1):  # If it's the hour before a class
				class_upcoming = true
				$VBoxContainer/ClassButton.visible = true
				print("Class upcoming at ", class_hour)
		if class_upcoming:
			selected_index = 0
		else:
			selected_index = 1
		highlight_button(selected_index)
		$VBoxContainer.visible = true
		for email in EventsManager.emails:
			if email["id"] == "work_email":  # Match the email ID with the event name
				if email["read"]:
					$VBoxContainer/WorkButton1.visible = true
					$VBoxContainer/WorkButton2.visible = true
					$VBoxContainer/WorkButton3.visible = true

func _on_entrance_area_2d_body_exited(body):
	if body == player:
		near_entrance = false
		class_upcoming = false
		$VBoxContainer/ClassButton.visible = false
		$VBoxContainer.visible = false

func _on_class_button_pressed():
	if $VBoxContainer/ClassButton.visible and not Globals.at_class:
		Globals.at_class = true
		Globals.current_location = "At Class"
		player.can_move = false
		player.visible = false
		print("Off to class")

func _on_work_button_1_pressed():
	if $VBoxContainer/WorkButton1.visible and not Globals.at_work:
		Globals.at_work = true
		Globals.current_location = "At Work"
		player.can_move = false
		player.visible = false
		UI.fade_to_black()
		UI.pause_time()
		print("At work")
		await Globals.create_tracked_timer(1.5).timeout
		$VBoxContainer.visible = false
		UI.resume_time()
		UI.skip_time(2)
		Globals.increase_player_money(12.50)
		get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")

func _on_work_button_2_pressed():
	if $VBoxContainer/WorkButton2.visible and not Globals.at_work:
		Globals.at_work = true
		Globals.current_location = "At Work"
		player.can_move = false
		player.visible = false
		UI.fade_to_black()
		UI.pause_time()
		print("At work")
		await Globals.create_tracked_timer(2.0).timeout
		$VBoxContainer.visible = false
		UI.resume_time()
		UI.skip_time(4)
		Globals.increase_player_money(25.00)
		get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")

func _on_work_button_3_pressed():
	if $VBoxContainer/WorkButton3.visible and not Globals.at_work:
		Globals.at_work = true
		Globals.current_location = "At Work"
		player.can_move = false
		player.visible = false
		UI.fade_to_black()
		UI.pause_time()
		print("At work")
		await Globals.create_tracked_timer(2.5).timeout
		$VBoxContainer.visible = false
		UI.resume_time()
		UI.skip_time(6)
		Globals.increase_player_money(37.50)
		get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")

func _on_mailbox_area_2d_body_entered(body):
	if body == player:
		near_player_mailbox = true

func _on_mailbox_area_2d_body_exited(body):
	if body == player:
		near_player_mailbox = false

func _on_test_area_2d_body_entered(body):
	if body == player:
		print("Player Stats
	Speed: ", Globals.player_speed, "
	Strength: ", Globals.player_strength, "
	Intelligence: ", Globals.player_intelligence, "
	Social: ", Globals.player_social, "
	Stealth: ", Globals.player_stealth
	)
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3F.tscn")
		
