extends Node2D

@export var player_scene: PackedScene 
var player = null
var elevator_open = false
var in_elevator = false
var near_button = false
var button_pressed = false
var near_door = false
var target_unit = ""
var left_unit = ""
var player_knocking = false
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
		Globals.current_location = "Floor 1"
	elif Globals.descending_stairs:
		player.position = Vector2(-1658, 500)
		Globals.descending_stairs = false
		Globals.current_location = "Floor 1"
	elif Globals.current_location == "Elevator":
		player.position = Vector2(1440, 540)
		Globals.current_location = "Floor 1"
		$ElevatorSprite.play("closed")
	elif Globals.current_location == "Unit 1A":
		player.position = Vector2(-620, 500)
		Globals.current_location = "Floor 1"
		left_unit = "1A"
		_leave_unit()
	elif Globals.current_location == "Unit 1D":
		player.position = Vector2(2390, 500)
		Globals.current_location = "Floor 1"
		left_unit = "1D"
		_leave_unit()
	else:
		player.position = Vector2(950, 950)
		Globals.current_location = "Floor 1"
	Globals.current_floor = 1
	add_child(player)
	player.can_move = true
	UI.fade_from_black()
	print("On First Floor")

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
	elif event.is_action_pressed("ui_interact") and near_door and not player_knocking and not door_open:
		_on_knock_button_pressed()

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

func _on_stairs_up_area_2d_body_entered(body):
	if body == player:
		Globals.climbing_stairs = true
		player.can_move = false
		UI.play_stairs_audio()
		UI.fade_to_black()
		await Globals.create_tracked_timer(1.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor2.tscn")

func _on_stairs_down_area_2d_body_entered(body):
	if body == player:
		Globals.descending_stairs = true
		player.can_move = false
		UI.play_stairs_audio()
		UI.fade_to_black()
		await Globals.create_tracked_timer(1.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Lobby.tscn")

func _leave_unit():
	$DoorCloseAudio.play()
	if left_unit == "1A":
		$Unit1ADoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit1ADoorSprite.visible = true
	elif left_unit == "1B":
		$Unit1BDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit1BDoorSprite.visible = true
	elif left_unit == "1C":
		$Unit1CDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit1CDoorSprite.visible = true
	elif left_unit == "1D":
		$Unit1DDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit1DDoorSprite.visible = true
	elif left_unit == "1E":
		$Unit1EDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit1EDoorSprite.visible = true
	elif left_unit == "1F":
		$Unit1FDoorSprite.visible = false
		await Globals.create_tracked_timer(0.5).timeout
		$Unit1FDoorSprite.visible = true

func _on_unit_1a_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit1ADoorSprite/KnockButton.visible = true
		target_unit = "1A"

func _on_unit_1a_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit1ADoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_1b_door_area_2d_body_entered(body):
	if body == player:
		$Unit1BDoorSprite.visible = true

func _on_unit_1b_door_area_2d_body_exited(body):
	if body == player:
		$Unit1BDoorSprite.visible = false

func _on_unit_1b_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit1BDoorSprite/KnockButton.visible = true
		target_unit = "1B"

func _on_unit_1b_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit1BDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_1c_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit1CDoorSprite/KnockButton.visible = true
		target_unit = "1C"

func _on_unit_1c_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit1CDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_1d_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit1DDoorSprite/KnockButton.visible = true
		target_unit = "1D"

func _on_unit_1d_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit1DDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_1e_door_area_2d_body_entered(body):
	if body == player:
		$Unit1EDoorSprite.visible = true

func _on_unit_1e_door_area_2d_body_exited(body):
	if body == player:
		$Unit1EDoorSprite.visible = false

func _on_unit_1e_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit1EDoorSprite/KnockButton.visible = true
		target_unit = "1E"

func _on_unit_1e_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit1EDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_1f_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit1FDoorSprite/KnockButton.visible = true
		target_unit = "1F"

func _on_unit_1f_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit1FDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_knock_button_pressed():
	if not player_knocking:
		player_knocking = true
		player.can_move = false
		# Choose a random audio file from the array
		var random_index = randi() % knocking_audio.size()
		$KnockingAudio.stream = knocking_audio[random_index]
		$KnockingAudio.play()
		#$Unit1ADoorSprite/KnockButton.visible = false
		#$Unit1BDoorSprite/KnockButton.visible = false
		#$Unit1CDoorSprite/KnockButton.visible = false
		#$Unit1DDoorSprite/KnockButton.visible = false
		#$Unit1EDoorSprite/KnockButton.visible = false
		#$Unit1FDoorSprite/KnockButton.visible = false
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
		print("Door closed. No tenants home in unit %s." % target_unit)

func _close_door():
	if target_unit == "1A":
		door_open = false
		$Unit1ADoorSprite.visible = true
		$Unit1AStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "1B":
		door_open = false
		$Unit1BDoorSprite.visible = true
		$Unit1BStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "1C":
		door_open = false
		$Unit1CDoorSprite.visible = true
		$Unit1CStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "1D":
		door_open = false
		$Unit1DDoorSprite.visible = true
		$Unit1DStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "1E":
		door_open = false
		$Unit1EDoorSprite.visible = true
		$Unit1EStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "1F":
		door_open = false
		$Unit1FDoorSprite.visible = true
		$Unit1FStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	$DoorCloseAudio.play()

func _on_unit_1a_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit1A.tscn")

func _on_unit_1b_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit1B.tscn")

func _on_unit_1c_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit1C.tscn")

func _on_unit_1d_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit1D.tscn")

func _on_unit_1e_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit1E.tscn")

func _on_unit_1f_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit1F.tscn")
