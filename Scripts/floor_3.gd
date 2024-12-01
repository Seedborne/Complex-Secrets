extends Node2D

@export var player_scene: PackedScene 
var player = null
var elevator_open = false
var in_elevator = false
var near_button = false
var button_pressed = false
var near_door = false
var near_home = false
var target_unit = ""
var left_unit = ""
var player_knocking = false
var tenants_not_available = false
var knocking_audio = [
	preload("res://Audio/knock1-pixabay.mp3"),
	preload("res://Audio/knock2-pixabay.mp3"),
	preload("res://Audio/knock3-pixabay.mp3")
]
var door_open = false

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	if Globals.climbing_stairs:
		player.position = Vector2(-1510, 500)
		Globals.climbing_stairs = false
		Globals.current_location = "Floor 3"
	elif Globals.descending_stairs:
		player.position = Vector2(-1658, 500)
		Globals.descending_stairs = false
		Globals.current_location = "Floor 3"
	elif Globals.current_location == "Elevator":
		player.position = Vector2(1440, 540)
		Globals.current_location = "Floor 3"
		$ElevatorSprite.play("closed")
	elif Globals.current_location == "Unit 3F":
		player.position = Vector2(3420, 500)
		left_unit = "3F"
		Globals.current_location = "Floor 3"
		_leave_unit()
	elif Globals.current_location == "Unit 3C":
		player.position = Vector2(450, 500)
		Globals.current_location = "Floor 3"
		left_unit = "3C"
		_leave_unit()
	Globals.current_floor = 3
	add_child(player)
	player.can_move = true
	UI.fade_from_black()
	print("On Third Floor")

func _process(_delta):
	pass

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
	elif event.is_action_pressed("ui_interact") and near_door and not player_knocking and not door_open and not tenants_not_available:
		_on_knock_button_pressed()
	elif event.is_action_pressed("ui_interact") and near_door and not player_knocking and not door_open and tenants_not_available:
		_attempt_lockpick()
	elif event.is_action_pressed("ui_interact") and near_home and not door_open:
		door_open = true
		$Unit3FDoorSprite.visible = false
		$Unit3FStaticBody2D/CollisionShape2D2.disabled = true
		$DoorOpenAudio.play()

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

func _on_stairs_down_area_2d_body_entered(body):
	if body == player:
		Globals.descending_stairs = true
		player.can_move = false
		UI.play_stairs_audio()
		UI.fade_to_black()
		await Globals.create_tracked_timer(1.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor2.tscn")

func _leave_unit():
	$DoorCloseAudio.play()
	if left_unit == "3A":
		$Unit3ADoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit3ADoorSprite.visible = true
	elif left_unit == "3B":
		$Unit3BDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit3BDoorSprite.visible = true
	elif left_unit == "3C":
		$Unit3CDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit3CDoorSprite.visible = true
	elif left_unit == "3D":
		$Unit3DDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit3DDoorSprite.visible = true
	elif left_unit == "3E":
		$Unit3EDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit3EDoorSprite.visible = true
	elif left_unit == "3F":
		$Unit3FDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit3FDoorSprite.visible = true

func _on_unit_3a_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit3ADoorSprite/KnockButton.visible = true
		target_unit = "3A"

func _on_unit_3a_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit3ADoorSprite/KnockButton.visible = false
		target_unit = ""
		tenants_not_available = false

func _on_unit_3b_door_area_2d_body_entered(body):
	if body == player:
		$Unit3BDoorSprite.visible = true

func _on_unit_3b_door_area_2d_body_exited(body):
	if body == player:
		$Unit3BDoorSprite.visible = false

func _on_unit_3b_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit3BDoorSprite/KnockButton.visible = true
		target_unit = "3B"

func _on_unit_3b_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit3BDoorSprite/KnockButton.visible = false
		target_unit = ""
		tenants_not_available = false

func _on_unit_3c_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit3CDoorSprite/KnockButton.visible = true
		target_unit = "3C"

func _on_unit_3c_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit3CDoorSprite/KnockButton.visible = false
		target_unit = ""
		tenants_not_available = false

func _on_unit_3d_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit3DDoorSprite/KnockButton.visible = true
		target_unit = "3D"

func _on_unit_3d_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit3DDoorSprite/KnockButton.visible = false
		target_unit = ""
		tenants_not_available = false

func _on_unit_3e_door_area_2d_body_entered(body):
	if body == player:
		$Unit3EDoorSprite.visible = true

func _on_unit_3e_door_area_2d_body_exited(body):
	if body == player:
		$Unit3EDoorSprite.visible = false

func _on_unit_3e_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit3EDoorSprite/KnockButton.visible = true
		target_unit = "3E"

func _on_unit_3e_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit3EDoorSprite/KnockButton.visible = false
		target_unit = ""
		tenants_not_available = false

func _on_unit_3f_rug_area_2d_body_entered(body):
	if body == player:
		near_home = true
		#$Unit3FDoorSprite/KnockButton.visible = true
		target_unit = "3F"

func _on_unit_3f_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_home = false
		#$Unit3FDoorSprite/KnockButton.visible = false
		target_unit = ""
		tenants_not_available = false

func _on_knock_button_pressed():
	if not player_knocking:
		player_knocking = true
		player.can_move = false
		Globals.is_sneaking = false
		# Choose a random audio file from the array
		var random_index = randi() % knocking_audio.size()
		$KnockingAudio.stream = knocking_audio[random_index]
		$KnockingAudio.play()
		#$Unit3ADoorSprite/KnockButton.visible = false
		#$Unit3BDoorSprite/KnockButton.visible = false
		#$Unit3CDoorSprite/KnockButton.visible = false
		#$Unit3DDoorSprite/KnockButton.visible = false
		#$Unit3EDoorSprite/KnockButton.visible = false
		#$Unit3FDoorSprite/KnockButton.visible = false
		print("Knocking on door ", target_unit)

func _on_knocking_audio_finished():
	await Globals.create_tracked_timer(1.0).timeout
	player_knocking = false
	player.can_move = true
	var tenant = Globals.check_tenant_availability(target_unit)

	if tenant != "":
		door_open = true
		print("Door to %s opens. %s is home." % [target_unit, tenant])

		# Dynamically access the door sprite
		var door_sprite = get_node("Unit%sDoorSprite" % target_unit)
		door_sprite.visible = false

		# Dynamically access the collision shape
		var collision_shape = get_node("Unit%sStaticBody2D/CollisionShape2D2" % target_unit)
		collision_shape.disabled = true

		# Play the door open audio
		$DoorOpenAudio.play()
	else:
		var lockpick_label = get_node_or_null("Unit%sDoorSprite/LockpickLabel" % target_unit)
		if lockpick_label:
			lockpick_label.visible = true
			$LockpickLabelTimer.start()
		tenants_not_available = true
		print("Door closed. No tenants home in unit %s." % target_unit)

func _on_lockpick_label_timer_timeout():
	#$Unit3ADoorSprite/LockpickLabel.visible = false
	#$Unit3BDoorSprite/LockpickLabel.visible = false
	$Unit3CDoorSprite/LockpickLabel.visible = false
	#$Unit3DDoorSprite/LockpickLabel.visible = false
	#$Unit3EDoorSprite/LockpickLabel.visible = false

func _attempt_lockpick():
	if target_unit == "3C": #just for demo
		if Globals.has_item_in_inventory("Bobby Pins"):
			Globals.remove_from_inventory("Bobby Pins", 1)
			print("attempting to pick lock")
			# Calculate success chance based on player_stealth
			var success_chance = Globals.player_stealth * 10 # Convert to percentage
			var roll = randi() % 100 # Generate a random number between 0-99
			if roll < success_chance:
				UI.show_notification("Successfully unlocked door.")
				Globals.is_sneaking = true
				door_open = true
				var door_sprite = get_node("Unit%sDoorSprite" % target_unit)
				door_sprite.visible = false
				var collision_shape = get_node("Unit%sStaticBody2D/CollisionShape2D2" % target_unit)
				collision_shape.disabled = true
				$DoorOpenAudio.play()
			else:
				UI.show_notification("Broke a bobby pin. Increase stealth stat for better lockpicking odds.")
		else:
			UI.show_notification("No bobby pins to attempt to pick lock. Buy some from Bookazon.")
			print("No bobby pins")
	
func _close_door():
	if target_unit == "3A":
		door_open = false
		$Unit3ADoorSprite.visible = true
		$Unit3AStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "3B":
		door_open = false
		$Unit3BDoorSprite.visible = true
		$Unit3BStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "3C":
		door_open = false
		$Unit3CDoorSprite.visible = true
		$Unit3CStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "3D":
		door_open = false
		$Unit3DDoorSprite.visible = true
		$Unit3DStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "3E":
		door_open = false
		$Unit3EDoorSprite.visible = true
		$Unit3EStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "3F":
		door_open = false
		$Unit3FDoorSprite.visible = true
		$Unit3FStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	$DoorCloseAudio.play()

func _on_unit_3a_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3A.tscn")

func _on_unit_3b_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3B.tscn")

func _on_unit_3c_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3C.tscn")

func _on_unit_3d_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3D.tscn")

func _on_unit_3e_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3E.tscn")

func _on_unit_3f_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3F.tscn")
