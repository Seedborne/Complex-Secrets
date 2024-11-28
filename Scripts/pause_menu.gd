extends CanvasLayer

var button_pressed = ""
var menu_buttons = ["ResumeButton", "SaveButton", "OptionsButton", "ControlsButton", "MainMenuButton", "QuitButton"]  # Your button list
var menu_selected_index = 0
var sq_menu_buttons = ["YesButton", "NoButton"]
var sq_menu_selected_index = 0

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if UI.grades_bar <= 0.9 and not Globals.game_over:
		if not Achievements.is_achievement_unlocked("unlock_ending_1"):
			Achievements.unlock_achievement("unlock_ending_1")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Globals.game_over = true
		PauseMenu.visible = true
		Globals.game_paused = true
		get_tree().paused = true
		$GameOverPanel.visible = true
		$GameOverPanel/VBoxContainer/GOLabel.text = "Ending 1
		You failed out of college and had to move back home."
	if EventsManager.is_datetime_or_later(26, 5, 2008, 0, 0):
		trigger_end_game()

func trigger_end_game():
	if not Achievements.is_achievement_unlocked("unlock_ending_3"):
		Achievements.unlock_achievement("unlock_ending_3")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.game_over = true
	visible = true
	Globals.game_paused = true
	get_tree().paused = true
	$GameOverPanel.visible = true
	$GameOverPanel/VBoxContainer/GOLabel.text = "Ending 3
	You made it through the end of your freshman class year!
	A friend from college asked you if you wanted to be 
	roommates with them next year.
	You decided it was time to leave Indigo Ridge."

func trigger_eviction():
	if not Achievements.is_achievement_unlocked("unlock_ending_2"):
		Achievements.unlock_achievement("unlock_ending_2")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.game_over = true
	visible = true
	Globals.game_paused = true
	get_tree().paused = true
	$GameOverPanel.visible = true
	$GameOverPanel/VBoxContainer/GOLabel.text = "Ending 2
	You were evicted from your apartment due to unpaid rent. 
	You were forced to withdraw from college and move back home."
	#remove Ending 1 and Ending 2 parts of labels and add achievements like "Unlocked Ending 1/Reach first ending"

func _input(event):
	if Input.is_action_just_pressed("ui_cancel") and Globals.in_game and not Globals.on_computer and Globals.can_pause_game() and not Globals.game_over and not Globals.in_cutscene and not Globals.in_stats:
		if not PauseMenu.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			PauseMenu.visible = true
			Globals.game_paused = true
			get_tree().paused = true
			print("paused")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			PauseMenu.visible = false
			Globals.game_paused = false
			get_tree().paused = false
			print("unpaused")
	if event.is_action_pressed("scroll_down") and visible and not Globals.game_over:
		menu_selected_index = (menu_selected_index + 1) % menu_buttons.size()
		menu_highlight_button(menu_selected_index)
		if not $Panel/VBoxContainer/MainMenuButton.visible:
			button_pressed = ""
			$Panel/VBoxContainer/MainMenuButton.visible = true
			$Panel/VBoxContainer/HBoxContainer.visible = false
			$Panel/VBoxContainer/Label.visible = false
		elif not $Panel/VBoxContainer/QuitButton.visible:
			button_pressed = ""
			$Panel/VBoxContainer/QuitButton.visible = true
			$Panel/VBoxContainer/HBoxContainer.visible = false
			$Panel/VBoxContainer/Label.visible = false
	elif event.is_action_pressed("scroll_up") and visible and not Globals.game_over:
		menu_selected_index = (menu_selected_index - 1 + menu_buttons.size()) % menu_buttons.size()
		menu_highlight_button(menu_selected_index)
		if not $Panel/VBoxContainer/MainMenuButton.visible:
			button_pressed = ""
			$Panel/VBoxContainer/MainMenuButton.visible = true
			$Panel/VBoxContainer/HBoxContainer.visible = false
			$Panel/VBoxContainer/Label.visible = false
		elif not $Panel/VBoxContainer/QuitButton.visible:
			button_pressed = ""
			$Panel/VBoxContainer/QuitButton.visible = true
			$Panel/VBoxContainer/HBoxContainer.visible = false
			$Panel/VBoxContainer/Label.visible = false
	elif event.is_action_pressed("ui_interact") and visible and not $Panel/VBoxContainer/HBoxContainer.visible and not Globals.game_over:
		menu_select_button(menu_selected_index)
	if event.is_action_pressed("scroll_right") and visible and $Panel/VBoxContainer/HBoxContainer.visible and not Globals.game_over:
		sq_menu_selected_index = (sq_menu_selected_index + 1) % sq_menu_buttons.size()
		sq_menu_highlight_button(sq_menu_selected_index)
	elif event.is_action_pressed("scroll_left") and visible and $Panel/VBoxContainer/HBoxContainer.visible and not Globals.game_over:
		sq_menu_selected_index = (sq_menu_selected_index - 1 + sq_menu_buttons.size()) % sq_menu_buttons.size()
		sq_menu_highlight_button(sq_menu_selected_index)
	elif event.is_action_pressed("ui_interact") and visible and $Panel/VBoxContainer/HBoxContainer.visible and not Globals.game_over:
		sq_menu_select_button(sq_menu_selected_index)

func menu_highlight_button(index):
	# Reset all children to default state
	if $Panel/VBoxContainer.visible:
		for child in $Panel/VBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $Panel/VBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func menu_select_button(index):
	if $Panel/VBoxContainer.visible:
		var selected_button = menu_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "ResumeButton":
			_on_resume_button_pressed()
		elif selected_button == "SaveButton":
			_on_save_button_pressed()
		elif selected_button == "OptionsButton":
			pass
		elif selected_button == "ControlsButton":
			pass
		elif selected_button == "MainMenuButton":
			_on_main_menu_button_pressed()
		elif selected_button == "QuitButton":
			_on_quit_button_pressed()

func sq_menu_highlight_button(index):
	# Reset all children to default state
	if $Panel/VBoxContainer/HBoxContainer.visible:
		for child in $Panel/VBoxContainer/HBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $Panel/VBoxContainer/HBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func sq_menu_select_button(index):
	if $Panel/VBoxContainer/HBoxContainer.visible:
		var selected_button = sq_menu_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "YesButton":
			_on_yes_button_pressed()
		elif selected_button == "NoButton":
			_on_no_button_pressed()

func _on_resume_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	PauseMenu.visible = false
	Globals.game_paused = false
	get_tree().paused = false
	print("unpaused")

func _on_save_button_pressed():
	SaveLoadManager.save_game()
	await get_tree().create_timer(0.4).timeout
	$Panel/VBoxContainer/SaveButton.text = "Saved!"
	$Panel/VBoxContainer/SaveButton.disabled = true
	await get_tree().create_timer(1.0).timeout
	$Panel/VBoxContainer/SaveButton.text = "Save"
	$Panel/VBoxContainer/SaveButton.disabled = false
	
func _on_main_menu_button_pressed():
	button_pressed = "menu"
	await get_tree().create_timer(0.1).timeout
	$Panel/VBoxContainer/MainMenuButton.visible = false
	$Panel/VBoxContainer/QuitButton.visible = true
	$Panel/VBoxContainer/Label.visible = true
	$Panel/VBoxContainer/HBoxContainer.visible = true

func _on_yes_button_pressed():
	SaveLoadManager.save_game()
	await get_tree().create_timer(0.4).timeout
	$Panel/VBoxContainer/Label.text = "Saved!"
	await get_tree().create_timer(0.7).timeout
	$Panel/VBoxContainer/Label.text = "Save?"
	if button_pressed == "menu":
		visible = false
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		Globals.game_paused = false
		get_tree().paused = false
	elif button_pressed == "quit":
		get_tree().quit()

func _on_no_button_pressed():
	if button_pressed == "menu":
		visible = false
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		Globals.game_paused = false
		get_tree().paused = false
	elif button_pressed == "quit":
		get_tree().quit()

func _on_quit_button_pressed():
	button_pressed = "quit"
	await get_tree().create_timer(0.1).timeout
	$Panel/VBoxContainer/QuitButton.visible = false
	$Panel/VBoxContainer/MainMenuButton.visible = true
	$Panel/VBoxContainer/Label.visible = true
	$Panel/VBoxContainer/HBoxContainer.visible = true

func _on_visibility_changed():
	button_pressed = ""
	$Panel/VBoxContainer/MainMenuButton.visible = true
	$Panel/VBoxContainer/QuitButton.visible = true
	$Panel/VBoxContainer/Label.visible = false
	$Panel/VBoxContainer/HBoxContainer.visible = false
	menu_selected_index = 0
	menu_highlight_button(menu_selected_index)

func _on_h_box_container_visibility_changed():
	if $Panel/VBoxContainer/HBoxContainer.visible:
		sq_menu_selected_index = 0
		sq_menu_highlight_button(sq_menu_selected_index)

func _on_go_quit_button_pressed():
	get_tree().quit()

func _on_go_main_menu_button_pressed():
	PauseMenu.visible = false
	$GameOverPanel.visible = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	Globals.game_paused = false
	get_tree().paused = false

func _on_go_start_over_button_pressed():
	SaveLoadManager.delete_save_data()
	SaveLoadManager.reset_game_state()
	Globals.new_game = true
	PauseMenu.visible = false
	$GameOverPanel.visible = false
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")
	Globals.game_paused = false
	get_tree().paused = false
	Globals.in_game = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	UI.update_bars()
	UI.update_clock_display()
	UI.clock_timer.start()
