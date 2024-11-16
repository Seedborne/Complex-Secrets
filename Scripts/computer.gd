extends Control

var amazon_panel_max = true
var zmail_panel_max = true

@onready var amazon_panel = $AmazonPanel
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.on_computer = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UI.hide_ui()
	UI.cpu_fade_from_black()
	await get_tree().create_timer(0.2).timeout
	UI.hide_screen_fade()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_clock_display()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		UI.show_screen_fade()
		UI.cpu_fade_to_black()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if amazon_panel:  # Ensure the reference is valid
			amazon_panel._on_clear_cart_button_pressed()  # Call the restore_cart_stock function in amazon_panel.gd
		await get_tree().create_timer(0.2).timeout
		UI.cpu_fade_from_black_no_audio()
		UI.show_ui()
		get_tree().change_scene_to_file("res://Scenes/Unit3F.tscn")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$MouseClickAudio.play()

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
		$Panel/HBoxContainer/ClockLabel.text = "%02d:%02d %s" % [display_hour, UI.current_minute, am_pm] + "\n" + "%02d/%02d/%04d" % [UI.current_month, UI.current_day, UI.current_year] # Double-digit hour formatting
	else:
		$Panel/HBoxContainer/ClockLabel.text = "%01d:%02d %s" % [display_hour, UI.current_minute, am_pm] + "\n" + "%02d/%02d/%04d" % [UI.current_month, UI.current_day, UI.current_year] # Single-digit hour formatting
	#$HBoxContainer/DayLabel.text = UI.days_of_week[UI.current_day_index]

func _on_amazon_button_pressed():
	$AmazonPanel.visible = true
	$HBoxContainer/AmazonBarButton.visible = true

func _on_amazon_bar_button_pressed():
	if $AmazonPanel.z_index == 0:
		$AmazonPanel.z_index = -1
	elif $AmazonPanel.z_index == -1:
		$AmazonPanel.z_index = 0

func _on_amazon_close_button_pressed():
	$AmazonPanel.visible = false
	$HBoxContainer/AmazonBarButton.visible = false
	$AmazonPanel.scale = Vector2(1.0, 1.0)
	$AmazonPanel.position = Vector2(0, 0)
	$AmazonPanel/Panel/AmazonMaxButton.text = "o"
	amazon_panel_max = true

func _on_amazon_max_button_pressed():
	if amazon_panel_max:
		$AmazonPanel.scale = Vector2(0.7, 0.7)
		$AmazonPanel.position = Vector2(200, 100)
		$AmazonPanel/Panel/AmazonMaxButton.text = "O"
		amazon_panel_max = false
	else:
		$AmazonPanel.scale = Vector2(1.0, 1.0)
		$AmazonPanel.position = Vector2(0, 0)
		$AmazonPanel/Panel/AmazonMaxButton.text = "o"
		amazon_panel_max = true

func _on_amazon_min_button_pressed():
	$AmazonPanel.z_index = -1

func _on_email_bar_button_pressed():
	if $ZMailPanel.z_index == 0:
		$ZMailPanel.z_index = -1
	elif $ZMailPanel.z_index == -1:
		$ZMailPanel.z_index = 0


func _on_z_mail_close_button_pressed():
	pass # Replace with function body.


func _on_z_mail_max_button_pressed():
	if zmail_panel_max:
		$ZMailPanel.scale = Vector2(0.7, 0.7)
		$ZMailPanel.position = Vector2(200, 100)
		$ZMailPanel/Panel/ZMailMaxButton.text = "O"
		zmail_panel_max = false
	else:
		$ZMailPanel.scale = Vector2(1.0, 1.0)
		$ZMailPanel.position = Vector2(0, 0)
		$ZMailPanel/Panel/ZMailMaxButton.text = "o"
		zmail_panel_max = true

func _on_z_mail_min_button_pressed():
	$ZMailPanel.z_index = -1
