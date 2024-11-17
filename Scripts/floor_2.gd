extends Node2D

@export var player_scene: PackedScene 
var player = null
var elevator_open = false
var in_elevator = false
var near_button = false
var button_pressed = false
var near_door = false
var target_unit = ""
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
		player.position = Vector2(-1658, 525)
		Globals.climbing_stairs = false
		Globals.current_location = "Floor2"
	elif Globals.current_location == "Elevator":
		player.position = Vector2(1440, 540)
		Globals.current_location = "Floor2"
		$ElevatorSprite.play("closed")
	else:
		player.position = Vector2(950, 950)
		Globals.current_location = "Floor2"
	Globals.current_floor = 2
	add_child(player)
	player.can_move = true
	UI.fade_from_black()
	print("On Second Floor")

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
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor3.tscn")

func _on_stairs_down_area_2d_body_entered(body):
	if body == player:
		Globals.climbing_stairs = true
		player.can_move = false
		UI.play_stairs_audio()
		UI.fade_to_black()
		await Globals.create_tracked_timer(1.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor1.tscn")

func _on_unit_2a_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit2ADoorSprite/KnockButton.visible = true
		target_unit = "2A"

func _on_unit_2a_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit2ADoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_2b_door_area_2d_body_entered(body):
	if body == player:
		$Unit2BDoorSprite.visible = true

func _on_unit_2b_door_area_2d_body_exited(body):
	if body == player:
		$Unit2BDoorSprite.visible = false

func _on_unit_2b_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit2BDoorSprite/KnockButton.visible = true
		target_unit = "2B"

func _on_unit_2b_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit2BDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_2c_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit2CDoorSprite/KnockButton.visible = true
		target_unit = "2C"

func _on_unit_2c_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit2CDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_2d_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit2DDoorSprite/KnockButton.visible = true
		target_unit = "2D"

func _on_unit_2d_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit2DDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_2e_door_area_2d_body_entered(body):
	if body == player:
		$Unit2EDoorSprite.visible = true

func _on_unit_2e_door_area_2d_body_exited(body):
	if body == player:
		$Unit2EDoorSprite.visible = false

func _on_unit_2e_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit2EDoorSprite/KnockButton.visible = true
		target_unit = "2E"

func _on_unit_2e_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit2EDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_unit_2f_rug_area_2d_body_entered(body):
	if body == player:
		near_door = true
		#$Unit2FDoorSprite/KnockButton.visible = true
		target_unit = "2F"

func _on_unit_2f_rug_area_2d_body_exited(body):
	if body == player:
		if door_open:
			_close_door()
		near_door = false
		#$Unit2FDoorSprite/KnockButton.visible = false
		target_unit = ""

func _on_knock_button_pressed():
	if not player_knocking:
		player_knocking = true
		player.can_move = false
		# Choose a random audio file from the array
		var random_index = randi() % knocking_audio.size()
		$KnockingAudio.stream = knocking_audio[random_index]
		$KnockingAudio.play()
		#$Unit2ADoorSprite/KnockButton.visible = false
		#$Unit2BDoorSprite/KnockButton.visible = false
		#$Unit2CDoorSprite/KnockButton.visible = false
		#$Unit2DDoorSprite/KnockButton.visible = false
		#$Unit2EDoorSprite/KnockButton.visible = false
		#$Unit2FDoorSprite/KnockButton.visible = false
		print("Knocking on door ", target_unit)

func _on_knocking_audio_finished():
	Globals.check_tenant_availability()
	player_knocking = false
	player.can_move = true
	if target_unit == "2A" and Globals.tenant_home:
		door_open = true
		$Unit2ADoorSprite.visible = false
		$Unit2AStaticBody2D/CollisionShape2D2.disabled = true
	elif target_unit == "2B" and Globals.tenant_home:
		door_open = true
		$Unit2BDoorSprite.visible = false
		$Unit2BStaticBody2D/CollisionShape2D2.disabled = true
	elif target_unit == "2C" and Globals.tenant_home:
		door_open = true
		$Unit2CDoorSprite.visible = false
		$Unit2CStaticBody2D/CollisionShape2D2.disabled = true
	elif target_unit == "2D" and Globals.tenant_home:
		door_open = true
		$Unit2DDoorSprite.visible = false
		$Unit2DStaticBody2D/CollisionShape2D2.disabled = true
	elif target_unit == "2E" and Globals.tenant_home:
		door_open = true
		$Unit2EDoorSprite.visible = false
		$Unit2EStaticBody2D/CollisionShape2D2.disabled = true
	elif target_unit == "2F" and Globals.tenant_home:
		door_open = true
		$Unit2FDoorSprite.visible = false
		$Unit2FStaticBody2D/CollisionShape2D2.disabled = true
	$DoorOpenAudio.play()

func _close_door():
	if target_unit == "2A":
		door_open = false
		$Unit2ADoorSprite.visible = true
		$Unit2AStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "2B":
		door_open = false
		$Unit2BDoorSprite.visible = true
		$Unit2BStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "2C":
		door_open = false
		$Unit2CDoorSprite.visible = true
		$Unit2CStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "2D":
		door_open = false
		$Unit2DDoorSprite.visible = true
		$Unit2DStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "2E":
		door_open = false
		$Unit2EDoorSprite.visible = true
		$Unit2EStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	elif target_unit == "2F":
		door_open = false
		$Unit2FDoorSprite.visible = true
		$Unit2FStaticBody2D/CollisionShape2D2.set_deferred("disabled", false)
	$DoorCloseAudio.play()

func _on_unit_2a_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit2A.tscn")

func _on_unit_2b_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit2B.tscn")

func _on_unit_2c_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit2C.tscn")

func _on_unit_2d_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit2D.tscn")

func _on_unit_2e_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit2E.tscn")

func _on_unit_2f_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit2F.tscn")
