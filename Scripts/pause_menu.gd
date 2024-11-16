extends CanvasLayer

var button_pressed = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and Globals.in_game and not Globals.on_computer:
		if not PauseMenu.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			PauseMenu.visible = true
			get_tree().paused = true
			print("paused")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			PauseMenu.visible = false
			get_tree().paused = false
			print("unpaused")

func _on_resume_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	PauseMenu.visible = false
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
		get_tree().paused = false
	elif button_pressed == "quit":
		get_tree().quit()

func _on_no_button_pressed():
	if button_pressed == "menu":
		visible = false
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		get_tree().paused = false
	elif button_pressed == "quit":
		get_tree().quit()

func _on_quit_button_pressed():
	button_pressed = "quit"
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
