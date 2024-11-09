extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.on_computer = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UI.hide_ui()
	UI.cpu_fade_from_black()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_clock_display()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		UI.cpu_fade_to_black()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		await get_tree().create_timer(0.2).timeout
		UI.cpu_fade_from_black_no_audio()
		UI.show_ui()
		get_tree().change_scene_to_file("res://Scenes/Unit3F.tscn")

func update_clock_display():
	var am_pm = "AM"
	var display_hour = UI.current_hour
	if UI.current_hour >= 12:
		am_pm = "PM"
	if UI.current_hour == 0:
		display_hour = 12  # Midnight case
	elif UI.current_hour > 12:
		display_hour -= 12
	if display_hour >= 10:
		$HBoxContainer/ClockLabel.text = "%02d:%02d %s" % [display_hour, UI.current_minute, am_pm] # Double-digit hour formatting
	else:
		$HBoxContainer/ClockLabel.text = "%01d:%02d %s" % [display_hour, UI.current_minute, am_pm] # Single-digit hour formatting
	#$HBoxContainer/DayLabel.text = UI.days_of_week[UI.current_day_index]
