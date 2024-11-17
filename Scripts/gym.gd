extends Node2D

@export var player_scene: PackedScene 
var player = null
var near_treadmill = false
var near_workout = false
var treadmill_buttons = ["Button1", "Button2", "Button3"]  # Your button list
var treadmill_selected_index = 0
var workout_buttons = ["Button4", "Button5", "Button6"]  # Your button list
var workout_selected_index = 0
var can_exercise = true
# Called when the node enters the scene tree for the first time.
func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	player.position = Vector2(125, 615)
	Globals.current_location = "Gym"
	Globals.current_floor = 0
	add_child(player)
	player.can_move = true
	player.visible = true
	UI.fade_from_black()
	print("In Gym")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("scroll_down") and near_treadmill:
		treadmill_selected_index = (treadmill_selected_index + 1) % treadmill_buttons.size()
		treadmill_highlight_button(treadmill_selected_index)
	elif event.is_action_pressed("scroll_up") and near_treadmill:
		treadmill_selected_index = (treadmill_selected_index - 1 + treadmill_buttons.size()) % treadmill_buttons.size()
		treadmill_highlight_button(treadmill_selected_index)
	elif event.is_action_pressed("ui_interact") and near_treadmill:
		treadmill_select_button(treadmill_selected_index)
	if event.is_action_pressed("scroll_down") and near_workout:
		workout_selected_index = (workout_selected_index + 1) % workout_buttons.size()
		workout_highlight_button(workout_selected_index)
	elif event.is_action_pressed("scroll_up") and near_workout:
		workout_selected_index = (workout_selected_index - 1 + workout_buttons.size()) % workout_buttons.size()
		workout_highlight_button(workout_selected_index)
	elif event.is_action_pressed("ui_interact") and near_workout:
		workout_select_button(workout_selected_index)

func treadmill_highlight_button(index):
	# Reset all children to default state
	if $TreadmillVBoxContainer.visible:
		for child in $TreadmillVBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $TreadmillVBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func treadmill_select_button(index):
	if $TreadmillVBoxContainer.visible and can_exercise:
		var selected_button = treadmill_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "Button1":
			_on_button_1_pressed()
		elif selected_button == "Button2":
			_on_button_2_pressed()
		elif selected_button == "Button3":
			_on_button_3_pressed()
		can_exercise = false

func workout_highlight_button(index):
	# Reset all children to default state
	if $WorkoutVBoxContainer.visible:
		for child in $WorkoutVBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $WorkoutVBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func workout_select_button(index):
	if $WorkoutVBoxContainer.visible and can_exercise:
		var selected_button = workout_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "Button4":
			_on_button_4_pressed()
		elif selected_button == "Button5":
			_on_button_5_pressed()
		elif selected_button == "Button6":
			_on_button_6_pressed()
		can_exercise = false

func _on_lobby_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		player.can_move = true
		UI.fade_from_black()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Lobby.tscn")

func _on_treadmill_area_2d_body_entered(body):
	if body == player:
		near_treadmill = true
		$TreadmillVBoxContainer.visible = true
		treadmill_selected_index = 0
		treadmill_highlight_button(treadmill_selected_index)

func _on_treadmill_area_2d_body_exited(body):
	if body == player:
		near_treadmill = false
		$TreadmillVBoxContainer.visible = false

func _on_button_1_pressed():
	Globals.is_exercising = true
	player.can_move = false
	UI.fade_to_black()
	UI.pause_time()
	await Globals.create_tracked_timer(1.5).timeout
	Globals.increase_player_speed(5)
	UI.resume_time()
	UI.skip_time_minutes(30)
	UI.fade_from_black()
	player.can_move = true
	Globals.is_exercising = false
	$ExerciseDelay.start()
	print("Speed: ", Globals.player_speed)

func _on_button_2_pressed():
	Globals.is_exercising = true
	player.can_move = false
	UI.fade_to_black()
	UI.pause_time()
	await Globals.create_tracked_timer(2.0).timeout
	Globals.increase_player_speed(10)
	UI.resume_time()
	UI.skip_time(1)
	UI.fade_from_black()
	player.can_move = true
	Globals.is_exercising = false
	$ExerciseDelay.start()
	print("Speed: ", Globals.player_speed)

func _on_button_3_pressed():
	Globals.is_exercising = true
	player.can_move = false
	UI.fade_to_black()
	UI.pause_time()
	await Globals.create_tracked_timer(2.5).timeout
	Globals.increase_player_speed(20)
	UI.resume_time()
	UI.skip_time(2)
	UI.fade_from_black()
	player.can_move = true
	Globals.is_exercising = false
	$ExerciseDelay.start()
	print("Speed: ", Globals.player_speed)

func _on_workout_area_2d_body_entered(body):
	if body == player:
		near_workout = true
		$WorkoutVBoxContainer.visible = true
		workout_selected_index = 0
		workout_highlight_button(workout_selected_index)

func _on_workout_area_2d_body_exited(body):
	if body == player:
		near_workout = false
		$WorkoutVBoxContainer.visible = false

func _on_button_4_pressed():
	Globals.is_exercising = true
	player.can_move = false
	UI.fade_to_black()
	UI.pause_time()
	await Globals.create_tracked_timer(1.5).timeout
	Globals.increase_player_strength(0.2)
	UI.resume_time()
	UI.skip_time_minutes(30)
	UI.fade_from_black()
	player.can_move = true
	Globals.is_exercising = false
	$ExerciseDelay.start()
	print("Strength: ", Globals.player_strength)

func _on_button_5_pressed():
	Globals.is_exercising = true
	player.can_move = false
	UI.fade_to_black()
	UI.pause_time()
	await Globals.create_tracked_timer(2.0).timeout
	Globals.increase_player_strength(0.4)
	UI.resume_time()
	UI.skip_time(1)
	UI.fade_from_black()
	player.can_move = true
	Globals.is_exercising = false
	$ExerciseDelay.start()
	print("Strength: ", Globals.player_strength)

func _on_button_6_pressed():
	Globals.is_exercising = true
	player.can_move = false
	UI.fade_to_black()
	UI.pause_time()
	await Globals.create_tracked_timer(2.5).timeout
	Globals.increase_player_strength(0.8)
	UI.resume_time()
	UI.skip_time(2)
	UI.fade_from_black()
	player.can_move = true
	Globals.is_exercising = false
	$ExerciseDelay.start()
	print("Strength: ", Globals.player_strength)

func _on_exercise_delay_timeout():
	can_exercise = true
