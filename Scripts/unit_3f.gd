extends Node2D

@export var player_scene: PackedScene 
var player = null
var near_computer = false
var near_door = false
var door_open = false
var bed_buttons = ["BedButton", "BedButton2", "BedButton3"]  # Your button list
var bed_selected_index = 0
var near_bed = false

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	Globals.current_location = "Unit3F"
	if not Globals.on_computer:
		player.position = Vector2(800, 260)
		player.can_move = true
		UI.fade_from_black()
		print("In Unit3F")
		await get_tree().create_timer(0.5).timeout
		_close_door()
	else:
		player.position = Vector2(1310, 530)
		player.can_move = true
		Globals.on_computer = false
		$DoorSprite.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _open_door():
	$DoorOpenAudio.play()
	$DoorSprite.visible = false
	$DoorBody2D/CollisionShape2D.disabled = true
	door_open = true

func _close_door():
	$DoorCloseAudio.play()
	$DoorSprite.visible = true
	door_open = false

func _on_desk_area_2d_body_entered(body):
	if body == player:
		near_computer = true

func _on_desk_area_2d_body_exited(body):
	if body == player:
		near_computer = false

func _input(event):
	if event.is_action_pressed("ui_interact") and near_computer:
		get_tree().change_scene_to_file("res://Scenes/Computer.tscn")
	if event.is_action_pressed("ui_interact") and near_door and not door_open:
		_open_door()
	if event.is_action_pressed("scroll_down") and near_bed:
		bed_selected_index = (bed_selected_index + 1) % bed_buttons.size()
		highlight_button(bed_selected_index)
	elif event.is_action_pressed("scroll_up") and near_bed:
		bed_selected_index = (bed_selected_index - 1 + bed_buttons.size()) % bed_buttons.size()
		highlight_button(bed_selected_index)
	elif event.is_action_pressed("ui_interact") and near_bed:
		select_button(bed_selected_index)

func highlight_button(index):
	# Reset all children to default state
	if near_bed:
		for child in $BedVBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $BedVBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func select_button(index):
	if near_bed:
		var selected_button = bed_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "BedButton":
			_on_bed_button_pressed()
		elif selected_button == "BedButton2":
			_on_bed_button_2_pressed()
		elif selected_button == "BedButton3":
			_on_bed_button_3_pressed()

func _on_door_area_2d_body_entered(body):
	if body == player:
		near_door = true

func _on_door_area_2d_body_exited(body):
	if body == player:
		near_door = false
		if door_open:
			_close_door()
			$DoorBody2D/CollisionShape2D.set_deferred("disabled", false)

func _on_doorway_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await get_tree().create_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor3.tscn")

func _on_bed_area_2d_body_entered(body):
	if body == player:
		near_bed = true
		bed_selected_index = 0
		highlight_button(bed_selected_index)
		$BedVBoxContainer.visible = true

func _on_bed_area_2d_body_exited(body):
	if body == player:
		near_bed = false
		$BedVBoxContainer.visible = false

func _on_bed_button_pressed():
	player.can_move = false
	UI.sleep_for_hours(2)
	UI.pause_time()
	UI.fade_to_black()
	await get_tree().create_timer(1.5).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true

func _on_bed_button_2_pressed():
	player.can_move = false
	UI.sleep_for_hours(4)
	UI.pause_time()
	UI.fade_to_black()
	await get_tree().create_timer(2.5).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true

func _on_bed_button_3_pressed():
	player.can_move = false
	UI.sleep_for_hours(8)
	UI.pause_time()
	UI.fade_to_black()
	await get_tree().create_timer(4.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
