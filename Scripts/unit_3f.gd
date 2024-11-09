extends Node2D

@export var player_scene: PackedScene 
var player = null
var near_computer = false
var near_door = false
var door_open = false

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
	if event.is_action_pressed("ui_interact") and near_door:
		_open_door()
		$DoorBody2D/CollisionShape2D.disabled = true

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
