extends Control


func _ready():
	Globals.in_game = false

func _process(_delta):
	pass

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")
	Globals.in_game = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	UI.clock_timer.start()
	

func _on_quit_game_button_pressed():
	get_tree().quit()
