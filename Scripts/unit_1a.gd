extends Node2D

@export var player_scene: PackedScene 
var player = null

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	player.can_move = true
	UI.fade_from_black()
	player.position = Vector2(800, 260)
	Globals.current_location = "Unit1A"
	print("In Unit1A")
	await get_tree().create_timer(0.5).timeout
	_close_door()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _open_door():
	$DoorOpenAudio.play()
	$DoorSprite.visible = false

func _close_door():
	$DoorCloseAudio.play()
	$DoorSprite.visible = true
