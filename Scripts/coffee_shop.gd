extends Node2D

@export var player_scene: PackedScene 
var player = null
var near_counter = false
var coffee_buttons = ["SmallCoffee", "Latte", "Espresso"]  # Your button list
var coffee_selected_index = 0
var can_order = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	player.position = Vector2(1800, 615)
	Globals.current_location = "Coffee Shop"
	Globals.current_floor = 0
	add_child(player)
	var animated_sprite = player.get_node("PlayerSprite")
	animated_sprite.flip_h = true
	player.can_move = true
	player.visible = true
	UI.fade_from_black()
	print("In Coffee Shop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("scroll_down") and near_counter:
		coffee_selected_index = (coffee_selected_index + 1) % coffee_buttons.size()
		coffee_highlight_button(coffee_selected_index)
	elif event.is_action_pressed("scroll_up") and near_counter:
		coffee_selected_index = (coffee_selected_index - 1 + coffee_buttons.size()) % coffee_buttons.size()
		coffee_highlight_button(coffee_selected_index)
	elif event.is_action_pressed("ui_interact") and near_counter:
		coffee_select_button(coffee_selected_index)

func coffee_highlight_button(index):
	# Reset all children to default state
	if $CoffeeVBoxContainer.visible:
		for child in $CoffeeVBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $CoffeeVBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func coffee_select_button(index):
	if $CoffeeVBoxContainer.visible and can_order:
		var selected_button = coffee_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "SmallCoffee":
			_on_small_coffee_pressed()
		elif selected_button == "Latte":
			_on_latte_pressed()
		elif selected_button == "Espresso":
			_on_espresso_pressed()
		can_order = false

func _on_small_coffee_pressed():
	if Globals.player_money >= 5:
		Globals.decrease_player_money(5)
		player.can_move = false
		UI.fade_to_black()
		#UI.pause_time()
		await Globals.create_tracked_timer(1.0).timeout
		UI.sleep_bar += 10  # Refill rate, adjust as needed
		UI.sleep_bar = clamp(UI.sleep_bar, 0, 100)
		UI.update_bars()
		#UI.resume_time()
		UI.fade_from_black()
		player.can_move = true
		$OrderDelay.start()
		print("Drank Small Coffee. Sleep bar refilled to ", UI.sleep_bar)
	else:
		print("Can't afford small coffee")

func _on_latte_pressed():
	if Globals.player_money >= 8:
		Globals.decrease_player_money(8)
		player.can_move = false
		UI.fade_to_black()
		#UI.pause_time()
		await Globals.create_tracked_timer(1.0).timeout
		UI.sleep_bar += 16  # Refill rate, adjust as needed
		UI.sleep_bar = clamp(UI.sleep_bar, 0, 100)
		UI.update_bars()
		#UI.resume_time()
		UI.fade_from_black()
		player.can_move = true
		$OrderDelay.start()
		print("Drank Latte. Sleep bar refilled to ", UI.sleep_bar)
	else:
		print("Can't afford latte")

func _on_espresso_pressed():
	if Globals.player_money >= 10:
		Globals.decrease_player_money(10)
		player.can_move = false
		UI.fade_to_black()
		#UI.pause_time()
		await Globals.create_tracked_timer(1.0).timeout
		UI.sleep_bar += 20  # Refill rate, adjust as needed
		UI.sleep_bar = clamp(UI.sleep_bar, 0, 100)
		UI.update_bars()
		#UI.resume_time()
		UI.fade_from_black()
		player.can_move = true
		$OrderDelay.start()
		print("Drank Espresso. Sleep bar refilled to ", UI.sleep_bar)
	else:
		print("Can't afford espresso")

func _on_lobby_area_2d_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		player.can_move = true
		UI.fade_from_black()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Lobby.tscn")

func _on_counter_area_2d_body_entered(body):
	if body == player:
		near_counter = true
		$CoffeeVBoxContainer.visible = true
		coffee_selected_index = 0
		coffee_highlight_button(coffee_selected_index)

func _on_counter_area_2d_body_exited(body):
	if body == player:
		near_counter = false
		$CoffeeVBoxContainer.visible = false

func _on_order_delay_timeout():
	can_order = true
