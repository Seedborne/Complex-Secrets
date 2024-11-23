extends Control


func _ready():
	Globals.in_game = false

func _process(_delta):
	pass

func _on_new_game_button_pressed():
	if SaveLoadManager.check_for_save_data():
		$VBoxContainer/VBoxContainer.visible = true
	else:
		SaveLoadManager.delete_save_data()
		SaveLoadManager.reset_game_state()
		Globals.new_game = true
		get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")
		Globals.in_game = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		UI.update_bars()
		UI.update_clock_display()
		UI.clock_timer.start()

func _on_yes_button_pressed():
	SaveLoadManager.delete_save_data()
	SaveLoadManager.reset_game_state()
	Globals.new_game = true
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")
	Globals.in_game = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	UI.update_bars()
	UI.update_clock_display()
	UI.clock_timer.start()

func _on_no_button_pressed():
	$VBoxContainer/VBoxContainer.visible = false

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_load_game_button_pressed():
	SaveLoadManager.load_game()
	Globals.in_game = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	UI.clock_timer.start()

func _on_achievements_button_pressed():
	$AchievementsPanel.visible = true
