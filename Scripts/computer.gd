extends Control

var amazon_panel_max = true
var zmail_panel_max = true
var rent_panel_max = true
var banking_panel_max = true
var spy_app_panel_max = true
var recycle_bin_panel_max = false
#var sensitivity = 20.0
#var cursor_pos = Vector2()
@onready var amazon_panel = $AmazonPanel

func _ready():
	Globals.on_computer = true
	check_unread_emails()
	#cursor_pos = DisplayServer.mouse_get_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UI.hide_ui()
	UI.cpu_fade_from_black()
	await Globals.create_tracked_timer(0.2).timeout
	UI.hide_screen_fade()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_clock_display()
	for email in EventsManager.emails:
		if email["id"] == "apartment_email_1":
			if email["read"]:
				$VBoxContainer2/RentPortalButton.visible = true
		if email["id"] == "spy_email_1":
			if email["read"]:
				$VBoxContainer/SpyAppButton.visible = true
				$AmazonPanel/HBoxContainer/VBoxContainer2.visible = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		UI.show_screen_fade()
		UI.cpu_fade_to_black()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if amazon_panel:  # Ensure the reference is valid
			amazon_panel._on_clear_cart_button_pressed()  # Call the restore_cart_stock function in amazon_panel.gd
		await Globals.create_tracked_timer(0.2).timeout
		UI.cpu_fade_from_black_no_audio()
		UI.show_ui()
		get_tree().change_scene_to_file("res://Scenes/Unit3F.tscn")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$MouseClickAudio.play()
	#if event is InputEventJoypadMotion:
		#if event.axis in [JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y]:
			#cursor_pos = Vector2(cursor_pos)
			#cursor_pos += Vector2(
				#event.axis_value * sensitivity if event.axis == JOY_AXIS_RIGHT_X else 0,
				#event.axis_value * sensitivity if event.axis == JOY_AXIS_RIGHT_Y else 0
			#)
			#Input.warp_mouse(cursor_pos)
	
	#if event is InputEventJoypadButton:
		#if event.button_index == JOY_BUTTON_A and event.pressed:
			# Simulate a left mouse button press
			#print("press")
			#var mouse_event = InputEventMouseButton.new()
			#mouse_event.button_index = MOUSE_BUTTON_LEFT
			#mouse_event.pressed = true
			#mouse_event.global_position = DisplayServer.mouse_get_position()
			#Input.parse_input_event(mouse_event)
			#await Globals.create_tracked_timer(0.1).timeout
			# Simulate a left mouse button release
			#print("release")
			#mouse_event.pressed = false
			#mouse_event.global_position = DisplayServer.mouse_get_position()
			#Input.parse_input_event(mouse_event)
			#print("Released:", mouse_event.is_released())

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

func set_mouse_filter_recursive(node: Node, mouse_filter_mode: int):
	if node is Control:
		node.mouse_filter = mouse_filter_mode
	for child in node.get_children():
		set_mouse_filter_recursive(child, mouse_filter_mode)

func play_email_audio():
	$EmailNotifAudio.play()

func check_unread_emails():
	for email in EventsManager.emails:
		if email["sent"] and not email["read"]:
			$VBoxContainer/EmailButton/EmailNotification.visible = true
			return  # Stop checking as soon as an unread email is found
		$VBoxContainer/EmailButton/EmailNotification.visible = false

func _on_rent_portal_button_pressed():
	$RentPortalPanel.visible = true
	$HBoxContainer/RentPortalBarButton.visible = true
	if $RentPortalPanel.z_index == -1:
		$RentPortalPanel.z_index = 0
		set_mouse_filter_recursive($RentPortalPanel, Control.MOUSE_FILTER_STOP)

func _on_rent_portal_bar_button_pressed():
	if $RentPortalPanel.z_index == 0:
		$RentPortalPanel.z_index = -1
		set_mouse_filter_recursive($RentPortalPanel, Control.MOUSE_FILTER_IGNORE)
	elif $RentPortalPanel.z_index == -1:
		$RentPortalPanel.z_index = 0
		set_mouse_filter_recursive($RentPortalPanel, Control.MOUSE_FILTER_STOP)

func _on_rent_portal_close_button_pressed():
	$RentPortalPanel.visible = false
	$HBoxContainer/RentPortalBarButton.visible = false
	$RentPortalPanel.scale = Vector2(1.0, 1.0)
	$RentPortalPanel.position = Vector2(0, 0)
	$RentPortalPanel/Panel/RentPortalMaxButton.text = "o"
	rent_panel_max = true

func _on_rent_portal_max_button_pressed():
	if rent_panel_max:
		$RentPortalPanel.scale = Vector2(0.7, 0.7)
		$RentPortalPanel.position = Vector2(220, 140)
		$RentPortalPanel/Panel/RentPortalMaxButton.text = "O"
		rent_panel_max = false
	else:
		$RentPortalPanel.scale = Vector2(1.0, 1.0)
		$RentPortalPanel.position = Vector2(0, 0)
		$RentPortalPanel/Panel/RentPortalMaxButton.text = "o"
		rent_panel_max = true

func _on_rent_portal_min_button_pressed():
	$RentPortalPanel.z_index = -1
	set_mouse_filter_recursive($RentPortalPanel, Control.MOUSE_FILTER_IGNORE)

func _on_amazon_button_pressed():
	$AmazonPanel.visible = true
	$HBoxContainer/AmazonBarButton.visible = true
	if $AmazonPanel.z_index == -1:
		$AmazonPanel.z_index = 0
		set_mouse_filter_recursive($AmazonPanel, Control.MOUSE_FILTER_STOP)

func _on_amazon_bar_button_pressed():
	if $AmazonPanel.z_index == 0:
		$AmazonPanel.z_index = -1
		set_mouse_filter_recursive($AmazonPanel, Control.MOUSE_FILTER_IGNORE)
	elif $AmazonPanel.z_index == -1:
		$AmazonPanel.z_index = 0
		set_mouse_filter_recursive($AmazonPanel, Control.MOUSE_FILTER_STOP)

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
		$AmazonPanel.position = Vector2(260, 220)
		$AmazonPanel/Panel/AmazonMaxButton.text = "O"
		amazon_panel_max = false
	else:
		$AmazonPanel.scale = Vector2(1.0, 1.0)
		$AmazonPanel.position = Vector2(0, 0)
		$AmazonPanel/Panel/AmazonMaxButton.text = "o"
		amazon_panel_max = true

func _on_amazon_min_button_pressed():
	$AmazonPanel.z_index = -1
	set_mouse_filter_recursive($AmazonPanel, Control.MOUSE_FILTER_IGNORE)

func _on_email_button_pressed():
	$ZMailPanel.visible = true
	$HBoxContainer/EmailBarButton.visible = true
	UI.complete_objective("Use your computer to check your email
(E to interact)")
	if $ZMailPanel.z_index == -1:
		$ZMailPanel.z_index = 0
		set_mouse_filter_recursive($ZMailPanel, Control.MOUSE_FILTER_STOP)

func _on_email_bar_button_pressed():
	if $ZMailPanel.z_index == 0:
		$ZMailPanel.z_index = -1
		set_mouse_filter_recursive($ZMailPanel, Control.MOUSE_FILTER_IGNORE)
	elif $ZMailPanel.z_index == -1:
		$ZMailPanel.z_index = 0
		set_mouse_filter_recursive($ZMailPanel, Control.MOUSE_FILTER_STOP)

func _on_z_mail_close_button_pressed():
	$ZMailPanel.visible = false
	$HBoxContainer/EmailBarButton.visible = false
	$ZMailPanel.scale = Vector2(1.0, 1.0)
	$ZMailPanel.position = Vector2(0, 0)
	$ZMailPanel/Panel/ZMailMaxButton.text = "o"
	zmail_panel_max = true

func _on_z_mail_max_button_pressed():
	if zmail_panel_max:
		$ZMailPanel.scale = Vector2(0.7, 0.7)
		$ZMailPanel.position = Vector2(240, 180)
		$ZMailPanel/Panel/ZMailMaxButton.text = "O"
		zmail_panel_max = false
	else:
		$ZMailPanel.scale = Vector2(1.0, 1.0)
		$ZMailPanel.position = Vector2(0, 0)
		$ZMailPanel/Panel/ZMailMaxButton.text = "o"
		zmail_panel_max = true

func _on_z_mail_min_button_pressed():
	$ZMailPanel.z_index = -1
	set_mouse_filter_recursive($ZMailPanel, Control.MOUSE_FILTER_IGNORE)

func _on_banking_button_pressed():
	$BankingPanel.visible = true
	$HBoxContainer/BankingBarButton.visible = true
	if $BankingPanel.z_index == -1:
		$BankingPanel.z_index = 0
		set_mouse_filter_recursive($BankingPanel, Control.MOUSE_FILTER_STOP)
	
func _on_banking_bar_button_pressed():
	if $BankingPanel.z_index == 0:
		$BankingPanel.z_index = -1
		set_mouse_filter_recursive($BankingPanel, Control.MOUSE_FILTER_IGNORE)
	elif $BankingPanel.z_index == -1:
		$BankingPanel.z_index = 0
		set_mouse_filter_recursive($BankingPanel, Control.MOUSE_FILTER_STOP)

func _on_banking_close_button_pressed():
	$BankingPanel.visible = false
	$HBoxContainer/BankingBarButton.visible = false
	$BankingPanel.scale = Vector2(1.0, 1.0)
	$BankingPanel.position = Vector2(0, 0)
	$BankingPanel/Panel/BankingMaxButton.text = "o"
	banking_panel_max = true

func _on_banking_max_button_pressed():
	if banking_panel_max:
		$BankingPanel.scale = Vector2(0.7, 0.7)
		$BankingPanel.position = Vector2(200, 100)
		$BankingPanel/Panel/BankingMaxButton.text = "O"
		banking_panel_max = false
	else:
		$BankingPanel.scale = Vector2(1.0, 1.0)
		$BankingPanel.position = Vector2(0, 0)
		$BankingPanel/Panel/BankingMaxButton.text = "o"
		banking_panel_max = true

func _on_banking_min_button_pressed():
	$BankingPanel.z_index = -1
	set_mouse_filter_recursive($BankingPanel, Control.MOUSE_FILTER_IGNORE)

func _on_spy_app_button_pressed():
	$SpyAppPanel.visible = true
	$HBoxContainer/SpyAppBarButton.visible = true
	for objective in UI.objectives:
			if objective["text"] == "Check out AnonHelp app":
				if not objective["completed"]:
					UI.remove_completed_objectives()
					UI.complete_objective("Check out AnonHelp app")
	if $SpyAppPanel.z_index == -1:
		$SpyAppPanel.z_index = 0
		set_mouse_filter_recursive($SpyAppPanel, Control.MOUSE_FILTER_STOP)

func _on_spy_app_bar_button_pressed():
	if $SpyAppPanel.z_index == 0:
		$SpyAppPanel.z_index = -1
		set_mouse_filter_recursive($SpyAppPanel, Control.MOUSE_FILTER_IGNORE)
	elif $SpyAppPanel.z_index == -1:
		$SpyAppPanel.z_index = 0
		set_mouse_filter_recursive($SpyAppPanel, Control.MOUSE_FILTER_STOP)

func _on_spy_app_close_button_pressed():
	$SpyAppPanel.visible = false
	$HBoxContainer/SpyAppBarButton.visible = false
	$SpyAppPanel.scale = Vector2(1.0, 1.0)
	$SpyAppPanel.position = Vector2(0, 0)
	$SpyAppPanel/Panel/SpyAppMaxButton.text = "o"
	spy_app_panel_max = true

func _on_spy_app_max_button_pressed():
	if spy_app_panel_max:
		$SpyAppPanel.scale = Vector2(0.7, 0.7)
		$SpyAppPanel.position = Vector2(280, 260)
		$SpyAppPanel/Panel/SpyAppMaxButton.text = "O"
		spy_app_panel_max = false
	else:
		$SpyAppPanel.scale = Vector2(1.0, 1.0)
		$SpyAppPanel.position = Vector2(0, 0)
		$SpyAppPanel/Panel/SpyAppMaxButton.text = "o"
		spy_app_panel_max = true

func _on_spy_app_min_button_pressed():
	$SpyAppPanel.z_index = -1
	set_mouse_filter_recursive($SpyAppPanel, Control.MOUSE_FILTER_IGNORE)

func _on_recycle_bin_button_pressed():
	$RecycleBinPanel.visible = true
	$HBoxContainer/RecycleBinBarButton.visible = true
	if $RecycleBinPanel.z_index == -1:
		$RecycleBinPanel.z_index = 0
		set_mouse_filter_recursive($RecycleBinPanel, Control.MOUSE_FILTER_STOP)

func _on_recycle_bin_bar_button_pressed():
	if $RecycleBinPanel.z_index == 0:
		$RecycleBinPanel.z_index = -1
		set_mouse_filter_recursive($RecycleBinPanel, Control.MOUSE_FILTER_IGNORE)
	elif $RecycleBinPanel.z_index == -1:
		$RecycleBinPanel.z_index = 0
		set_mouse_filter_recursive($RecycleBinPanel, Control.MOUSE_FILTER_STOP)

func _on_recycle_bin_close_button_pressed():
	$RecycleBinPanel.visible = false
	$HBoxContainer/RecycleBinBarButton.visible = false
	$RecycleBinPanel/HintPanel.visible = false
	$RecycleBinPanel.scale = Vector2(1.0, 1.0)
	$RecycleBinPanel.position = Vector2(0, 0)
	$RecycleBinPanel/Panel/RecycleBinMaxButton.text = "o"
	recycle_bin_panel_max = false

func _on_recycle_bin_max_button_pressed():
	if recycle_bin_panel_max:
		$RecycleBinPanel.scale = Vector2(0.7, 0.7)
		$RecycleBinPanel.position = Vector2(180, 60)
		$RecycleBinPanel/Panel/RecycleBinMaxButton.text = "O"
		recycle_bin_panel_max = false
	else:
		$RecycleBinPanel.scale = Vector2(1.0, 1.0)
		$RecycleBinPanel.position = Vector2(0, 0)
		$RecycleBinPanel/Panel/RecycleBinMaxButton.text = "o"
		recycle_bin_panel_max = true

func _on_recycle_bin_min_button_pressed():
	$RecycleBinPanel.z_index = -1
	set_mouse_filter_recursive($RecycleBinPanel, Control.MOUSE_FILTER_IGNORE)
