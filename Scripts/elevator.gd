extends Node2D

@export var player_scene: PackedScene 

var player = null
var elevator_open = false
var elevator_moving = false
var in_elevator = true
var near_button = false
var selected_floor = ""
var original_position = position
var elevator_buttons = ["Button0", "Button1", "Button2", "Button3"]  # Your button list
var elevator_selected_index = 0

func _ready():
	Globals.current_location = "Elevator"
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	player.position = Vector2(973, 450)
	player.can_move = true
	$ElevatorSprite.play("closed")
	$ElevatorLabel.text = str(Globals.current_floor)
	$ElevatorLabel.visible = true
	UI.fade_from_black()
	print("In Elevator")

func _process(_delta):
	pass

func _on_elevator_button_area_2d_body_entered(body):
	if body == player:
		near_button = true
		if not elevator_open and not elevator_moving:
			$ElevatorPanel.visible = true
			elevator_selected_index = 0
			highlight_button(elevator_selected_index)

func _on_elevator_button_area_2d_body_exited(body):
	if body == player:
		near_button = false
		$ElevatorPanel.visible = false

func _input(event):
	if event.is_action_pressed("ui_0") and $ElevatorPanel.visible:
		_on_button_0_pressed()
	elif event.is_action_pressed("ui_1") and $ElevatorPanel.visible:
		_on_button_1_pressed()
	elif event.is_action_pressed("ui_2") and $ElevatorPanel.visible:
		_on_button_2_pressed()
	elif event.is_action_pressed("ui_3") and $ElevatorPanel.visible:
		_on_button_3_pressed()
	if event.is_action_pressed("scroll_down") and $ElevatorPanel.visible:
		elevator_selected_index = (elevator_selected_index + 1) % elevator_buttons.size()
		highlight_button(elevator_selected_index)
	elif event.is_action_pressed("scroll_up") and $ElevatorPanel.visible:
		elevator_selected_index = (elevator_selected_index - 1 + elevator_buttons.size()) % elevator_buttons.size()
		highlight_button(elevator_selected_index)
	elif event.is_action_pressed("ui_interact") and $ElevatorPanel.visible:
		select_button(elevator_selected_index)

func highlight_button(index):
	# Reset all children to default state
	if $ElevatorPanel.visible:
		for child in $ElevatorPanel/VBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $ElevatorPanel/VBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func select_button(index):
	if $ElevatorPanel.visible:
		var selected_button = elevator_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "Button0":
			_on_button_0_pressed()
		elif selected_button == "Button1":
			_on_button_1_pressed()
		elif selected_button == "Button2":
			_on_button_2_pressed()
		elif selected_button == "Button3":
			_on_button_3_pressed()

func _on_button_0_pressed():
	selected_floor = "Lobby"
	$ButtonPressAudio.play()
	if Globals.current_floor != 0:
		$ElevatorButtonSprite0.visible = true
		$ElevatorPanel.visible = false
		shake()
	else:
		$ElevatorButtonSprite0.visible = true
		$ElevatorPanel.visible = false
		_on_shake_finished(original_position)

func _on_button_1_pressed():
	selected_floor = "Floor1"
	$ButtonPressAudio.play()
	if Globals.current_floor != 1:
		$ElevatorButtonSprite1.visible = true
		$ElevatorPanel.visible = false
		shake()
	else:
		$ElevatorButtonSprite1.visible = true
		$ElevatorPanel.visible = false
		_on_shake_finished(original_position)

func _on_button_2_pressed():
	selected_floor = "Floor2"
	$ButtonPressAudio.play()
	if Globals.current_floor != 2:
		$ElevatorButtonSprite2.visible = true
		$ElevatorPanel.visible = false
		shake()
	else:
		$ElevatorButtonSprite2.visible = true
		$ElevatorPanel.visible = false
		_on_shake_finished(original_position)

func _on_button_3_pressed():
	selected_floor = "Floor3"
	$ButtonPressAudio.play()
	if Globals.current_floor != 3:
		$ElevatorButtonSprite3.visible = true
		$ElevatorPanel.visible = false
		shake()
	else:
		$ElevatorButtonSprite3.visible = true
		$ElevatorPanel.visible = false
		_on_shake_finished(original_position)

func shake(intensity: float = 4.0, duration: float = 2.5):
	elevator_moving = true
	$ElevatorAudio.play()
	$ElevatorLabel.visible = false
	var shake_timer = Timer.new()
	shake_timer.one_shot = true
	shake_timer.wait_time = duration
	shake_timer.connect("timeout", Callable(self, "_on_shake_finished").bind(original_position))
	add_child(shake_timer)
	shake_timer.start()

	while shake_timer.time_left > 0:
		position.x = original_position.x + randf_range(-intensity, intensity)
		position.y = original_position.y + randf_range(-intensity, intensity)
		await get_tree().create_timer(0.05).timeout

@warning_ignore("shadowed_variable")
func _on_shake_finished(original_position):
	position = original_position
	$ElevatorSprite.play("opening")
	$ElevatorOpenAudio.play()
	$ElevatorDingAudio.play()
	if selected_floor == "Lobby":
		Globals.current_floor = 0
	elif selected_floor == "Floor1":
		Globals.current_floor = 1
	elif selected_floor == "Floor2":
		Globals.current_floor = 2
	elif selected_floor == "Floor3":
		Globals.current_floor = 3
	$ElevatorLabel.text = str(Globals.current_floor)
	$ElevatorLabel.visible = true

func _on_elevator_sprite_animation_finished():
	if $ElevatorSprite.animation == "opening":
		$ElevatorBody2D/CollisionShape2D.disabled = true
		$ElevatorSprite.play("open")
		elevator_moving = false
		elevator_open = true
		$ElevatorTimer.start()
	elif $ElevatorSprite.animation == "closing" and in_elevator:
		$ElevatorButtonSprite0.visible = false
		$ElevatorButtonSprite1.visible = false
		$ElevatorButtonSprite2.visible = false
		$ElevatorButtonSprite3.visible = false
		$ElevatorSprite.play("closed")
		elevator_open = false
		if near_button:
			$ElevatorPanel.visible = true
			elevator_selected_index = 0
			highlight_button(elevator_selected_index)
	elif $ElevatorSprite.animation == "closing" and not in_elevator:
		$ElevatorButtonSprite0.visible = false
		$ElevatorButtonSprite1.visible = false
		$ElevatorButtonSprite2.visible = false
		$ElevatorButtonSprite3.visible = false
		$ElevatorSprite.play("closed")
		elevator_open = false
		var scene_path = "res://Scenes/" + selected_floor + ".tscn"
		get_tree().change_scene_to_file(scene_path)
		print("Changing scene to ", selected_floor)

func _on_elevator_timer_timeout():
	$ElevatorBody2D/CollisionShape2D.disabled = false
	$ElevatorSprite.play("closing")
	$ElevatorCloseAudio.play()

func _on_elevator_area_2d_body_entered(body):
	if body == player:
		in_elevator = false
		player.can_move = false
		$ElevatorSprite.z_index = 1
		$ElevatorSprite.play("closing")
		$ElevatorCloseAudio.play()
		UI.fade_to_black()
