extends Node2D

@export var player_scene: PackedScene 
var player = null
var searching = false
var lights_on = false
var near_lamp = false
var near_bed = false
var near_nightstand = false
var near_dresser = false
var near_side_door = false
var is_weekend = UI.current_day_index in [6, 0]

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	if lights_on:
		$LightsOff.visible = false
	else:
		$LightsOff.visible = true
	Globals.current_location = "Unit 3C"
	player.position = Vector2(1250, 550)
	var animated_sprite = player.get_node("PlayerSprite")
	animated_sprite.flip_h = true
	player.can_move = true
	UI.fade_from_black()
	Globals.current_floor = 3
	Globals.update_npc_positions()
	$SideDoorSprite.play("side_door_closed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_weekend:
		if UI.current_hour >= 21:
			$Mateo.visible = true
		elif UI.current_hour <= 8:
			$Mateo.visible = true
		else:
			$Mateo.visible = false
	else:
		if UI.current_hour >= 20:
			$Mateo.visible = true
		elif UI.current_hour <= 6:
			$Mateo.visible = true
		else:
			$Mateo.visible = false

func _input(event):
	if event.is_action_pressed("ui_interact") and near_lamp:
		if lights_on:
			lights_on = false
			$LightswitchOnAudio.play()
			$LightsOff.visible = true
		else:
			lights_on = true
			$LightswitchOffAudio.play()
			$LightsOff.visible = false
	if event.is_action_pressed("ui_interact") and near_bed and not searching:
		_on_bed_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_nightstand and not searching:
		_on_nightstand_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_dresser and not searching:
		_on_dresser_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_side_door:
		_open_side_door()

func _on_lamp_area_2d_body_entered(body):
	if body == player:
		near_lamp = true

func _on_lamp_area_2d_body_exited(body):
	if body == player:
		near_lamp = false

func _on_bed_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking and not $Mateo.visible:
		near_bed = true
		$BedSearchButton.visible = true

func _on_bed_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking and not $Mateo.visible:
		near_bed = false
		$BedSearchButton.visible = false

func _on_bed_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	#player.position = Vector2(1740, 710)
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_nightstand_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_nightstand_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_nightstand = true
		$NightstandSearchButton.visible = true

func _on_nightstand_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_nightstand = false
		$NightstandSearchButton.visible = false

func _on_dresser_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_dresser = true
		$DresserSearchButton.visible = true

func _on_dresser_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_dresser = false
		$DresserSearchButton.visible = false

func _on_dresser_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_side_door_area_2d_body_entered(body):
	if body == player:
		near_side_door = true

func _on_side_door_area_2d_body_exited(body):
	if body == player:
		near_side_door = false
		_close_side_door()

func _on_side_door_area_2d_2_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		player.can_move = true
		UI.fade_from_black()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3C.tscn")

func _open_side_door():
	$SideDoorBody2D/CollisionShape2D.disabled = true
	$SideDoorSprite.play("side_door_open")

func _close_side_door():
	$SideDoorBody2D/CollisionShape2D.set_deferred("disabled", false)
	$SideDoorSprite.play("side_door_closed")
