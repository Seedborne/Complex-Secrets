extends Node2D

@export var player_scene: PackedScene 
var player = null
var searching = false
var lights_on = true
var near_lightswitch = false
var near_computer = false
var near_door = false
var door_open = false
var near_bed = false
var near_bookshelf = false
var bookshelf_selected_index = 0
var near_secret_path = false
var bookshelf_open = false
var bookcase_inventory = {}
var near_nightstand_1 = false
var near_nightstand_2 = false
var near_dresser = false
var near_basket = false
var near_washer = false
var near_dryer = false
var near_counter = false
var near_kitchen_trash = false
var near_side_door = false
var near_elena = false
var near_mateo = false
var input_received = false
var talking = false
var dialogue_selected_index = 0

@onready var bookshelf_container = $BookshelfVBoxContainer

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	if Globals.is_npc_available("3C", "Elena"):
		lights_on = true
	else:
		lights_on = false
	if lights_on:
		$LightsOff.visible = false
		$LightswitchSprite2D.texture = load("res://Assets/testlightswitch-on.png")
	else:
		$LightsOff.visible = true
		$LightswitchSprite2D.texture = load("res://Assets/testlightswitch-off.png")
	if Globals.current_location == "Floor 3":
		Globals.current_location = "Unit 3C"
		player.position = Vector2(800, 260)
		player.can_move = true
		UI.fade_from_black()
		print("In Unit3C")
		await Globals.create_tracked_timer(0.5).timeout
		_close_door()
	elif Globals.on_computer:
		Globals.current_location = "Unit 3C"
		player.position = Vector2(1310, 530)
		player.can_move = true
		Globals.on_computer = false
		$DoorSprite.visible = true
	else:
		Globals.current_location = "Unit 3C"
		player.position = Vector2(165, 590)
		player.can_move = true
		$DoorSprite.visible = true
		UI.fade_from_black()
		print("In Unit 3C")
	Globals.current_floor = 3
	Globals.update_npc_positions()
	$BookshelfSprite.play("bookshelf_closed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _open_door():
	$DoorOpenAudio.play()
	$DoorSprite.visible = false
	$DoorBody2D/CollisionShape2D.disabled = true
	door_open = true

func _close_door():
	$DoorCloseAudio.play()
	$DoorSprite.visible = true
	door_open = false

func _on_desk_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_computer = true
		$DeskSearchButton.visible = true

func _on_desk_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_computer = false
		$DeskSearchButton.visible = false

func _input(event):
	if event.is_action_pressed("ui_interact") and near_lightswitch:
		if lights_on:
			lights_on = false
			$LightswitchOnAudio.play()
			$LightsOff.visible = true
			$LightswitchSprite2D.texture = load("res://Assets/testlightswitch-off.png")
		else:
			lights_on = true
			$LightswitchOffAudio.play()
			$LightsOff.visible = false
			$LightswitchSprite2D.texture = load("res://Assets/testlightswitch-on.png")
	#if event.is_action_pressed("ui_interact") and near_computer:
		#get_tree().change_scene_to_file("res://Scenes/Computer.tscn")
	if event.is_action_pressed("ui_interact") and near_computer and not searching:
		_search_desk()
	if event.is_action_pressed("ui_interact") and near_door and not door_open:
		_open_door()
	if event.is_action_pressed("ui_interact") and near_bed and not searching:
		_on_bed_search_button_pressed()
	#if event.is_action_pressed("scroll_down") and near_bookshelf:
		#bookshelf_selected_index = (bookshelf_selected_index + 1) % bookshelf_container.get_child_count()
		#bookshelf_highlight_button(bookshelf_selected_index)
	#elif event.is_action_pressed("scroll_up") and near_bookshelf:
		#bookshelf_selected_index = (bookshelf_selected_index - 1 + bookshelf_container.get_child_count()) % bookshelf_container.get_child_count()
		#bookshelf_highlight_button(bookshelf_selected_index)
	#elif event.is_action_pressed("ui_interact") and near_bookshelf:
		#bookshelf_select_button(bookshelf_selected_index)
	if event.is_action_pressed("ui_interact") and near_nightstand_1 and not searching:
		_on_nightstand_search_button_1_pressed()
	if event.is_action_pressed("ui_interact") and near_nightstand_2 and not searching:
		_on_nightstand_search_button_2_pressed()
	if event.is_action_pressed("ui_interact") and near_dresser and not searching:
		_on_dresser_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_basket and not searching:
		_on_clothes_basket_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_washer and not searching:
		_on_washer_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_dryer and not searching:
		_on_dryer_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_counter and not searching:
		_on_counter_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_kitchen_trash and not searching:
		_on_trash_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_bookshelf and not searching:
		_on_bookshelf_search_button_pressed()
	if event.is_action_pressed("ui_interact") and near_secret_path and not near_bookshelf and not bookshelf_open:
		_open_secret_bookshelf()
	if event.is_action_pressed("ui_interact") and near_side_door:
		_open_side_door()
	if event.is_action_pressed("ui_interact") and near_elena and not Globals.is_sneaking and not talking:
		talk_to_elena()
	if event.is_action_pressed("ui_interact") and near_mateo and not Globals.is_sneaking and not talking:
		talk_to_mateo()
	if event.is_action_pressed("ui_accept"):
		input_received = true
	var player_node = get_tree().current_scene.get_node("Player")
	var dialogue_container = player_node.dialogue_container
	if event.is_action_pressed("scroll_down") and talking and dialogue_container.visible:
		dialogue_selected_index = (dialogue_selected_index + 1) % dialogue_container.get_child_count()
		dialogue_highlight_button(dialogue_selected_index)
	elif event.is_action_pressed("scroll_up") and talking and dialogue_container.visible:
		dialogue_selected_index = (dialogue_selected_index - 1 + dialogue_container.get_child_count()) % dialogue_container.get_child_count()
		dialogue_highlight_button(dialogue_selected_index)
	elif event.is_action_pressed("ui_interact") and talking and dialogue_container.visible:
		dialogue_select_button(dialogue_selected_index)

func _on_lightswitch_area_2d_body_entered(body):
	if body == player:
		near_lightswitch = true

func _on_lightswitch_area_2d_body_exited(body):
	if body == player:
		near_lightswitch = false

# Adjusted highlight_button function for bookshelf buttons
#func bookshelf_highlight_button(index):
	# Reset all children to default state
	#if near_bookshelf:
		#for child in bookshelf_container.get_children():
			#child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		#var selected_child = bookshelf_container.get_child(index)
		#selected_child.focus_mode = Control.FOCUS_ALL
		#selected_child.grab_focus()

# Adjusted select_button function to handle dynamically created buttons
#func bookshelf_select_button(index):
	#if near_bookshelf:
		#var selected_button = bookshelf_container.get_child(index)
		#print("Selected button: %s" % selected_button.text)
		#if selected_button.text == "Store Books":
			#store_books()
		#else:
			# Assuming the book buttons trigger a read function
			#take_book(selected_button.text)  # Pass the book name to the read function

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
		await Globals.create_tracked_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor3.tscn")

func _search_desk():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	#player.position = Vector2(1310, 530)
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_bed_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_bed = true
		$BedSearchButton.visible = true

func _on_bed_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_bed = false
		$BedSearchButton.visible = false

func _on_bed_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	#player.position = Vector2(1740, 710)
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_bookshelf_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_bookshelf = true
		$BookshelfSearchButton.visible = true
		#update_bookshelf_display()
		#$BookshelfVBoxContainer.visible = true
		#bookshelf_selected_index = 0
		#bookshelf_highlight_button(bookshelf_selected_index)

func _on_bookshelf_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_bookshelf = false
		$BookshelfSearchButton.visible = false
		#$BookshelfVBoxContainer.visible = false

func _on_bookshelf_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	#player.position = Vector2(1120, 220))
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

#func update_bookshelf_display():
	# Clear existing buttons
	#for child in bookshelf_container.get_children():
		#child.queue_free()
		
	#var has_books_to_store = Globals.player_inventory["Books"].size() > 0
# Add a button to store book(s) if relevant to story, must fix this code this stores all held books.
	#var store_button = Button.new()
	#store_button.text = "Store Books"
	#store_button.disabled = not has_books_to_store
	#store_button.connect("pressed", Callable(self, "store_books"))
	#bookshelf_container.add_child(store_button)
	
	# Add buttons for each book in bookshelf inventory
	#for book_name in bookcase_inventory.keys():
		#var button = Button.new()
		#button.text = book_name
		#button.connect("pressed", Callable(self, "_on_book_button_pressed").bind(book_name))
		#bookshelf_container.add_child(button)
	#bookshelf_selected_index = 0
	#bookshelf_highlight_button(bookshelf_selected_index)

#func store_books():
	#for book_name in Globals.player_inventory["Books"].keys():
		#var quantity = Globals.player_inventory["Books"][book_name]
		#if Globals.bookshelf_inventory.has(book_name):
		#	Globals.bookshelf_inventory[book_name] += quantity
		#else:
		#	Globals.bookshelf_inventory[book_name] = quantity
		
		# Set the player's inventory quantity to zero after transferring to the bookshelf
		#Globals.remove_from_inventory(book_name, quantity)

	# Remove books with zero quantity by creating a new dictionary with only non-zero quantities
	#var filtered_books = {}
	#for book_name in Globals.player_inventory["Books"].keys():
	#	if Globals.player_inventory["Books"][book_name] > 0:
	#		filtered_books[book_name] = Globals.player_inventory["Books"][book_name]
	#Globals.player_inventory["Books"] = filtered_books  # Replace with the filtered dictionary

	#update_bookshelf_display()

#func take_book(book_name):
	#player.can_move = false
	#UI.fade_to_black()
	#UI.pause_time()
	#await Globals.create_tracked_timer(1.0).timeout
	#UI.resume_time()
	#UI.fade_from_black()
	#player.position = Vector2(1120, 220)
	#player.can_move = true
	# Remove one copy from bookshelf inventory
	#bookcase_inventory[book_name] -= 1
	#if bookcase_inventory[book_name] <= 0:
	#	bookcase_inventory.erase(book_name)
	#update_bookshelf_display()
	#Globals.add_to_inventory()

func _on_secret_bookshelf_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_secret_path = true

func _on_secret_bookshelf_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_secret_path = false

func _open_secret_bookshelf():
	$BookshelfBody2D/CollisionShape2D.disabled = true
	$BookshelfBody2D/CollisionShape2D2.disabled = false
	$BookshelfArea2D/CollisionShape2D.disabled = true
	$BookshelfSprite.play("bookshelf_open")
	$SecretBookshelfLabel.visible = true
	bookshelf_open = true
	if not Achievements.is_achievement_unlocked("discover_bookcase_secret"):
		Achievements.unlock_achievement("discover_bookcase_secret")

func _on_secret_bookshelf_entrance_area_2d_body_entered(body):
	if body == player:
		print("Entered secret bookshelf area")

func _on_hallway_end_area_2d_2_body_exited(body):
	if body == player:
		if bookshelf_open:
			$BookshelfBody2D/CollisionShape2D.set_deferred("disabled", false)
			$BookshelfBody2D/CollisionShape2D2.set_deferred("disabled", true)
			$BookshelfArea2D/CollisionShape2D.set_deferred("disabled", false)
			$BookshelfSprite.play("bookshelf_closed")
			$SecretBookshelfLabel.visible = false
			bookshelf_open = false

func _on_nightstand_search_button_1_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_nightstand_search_button_2_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_nightstand_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_nightstand_1 = true
		$NightstandSearchButton1.visible = true

func _on_nightstand_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_nightstand_1 = false
		$NightstandSearchButton1.visible = false

func _on_nightstand_area_2d_2_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_nightstand_2 = true
		$NightstandSearchButton2.visible = true

func _on_nightstand_area_2d_2_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_nightstand_2 = false
		$NightstandSearchButton2.visible = false

func _on_dresser_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_dresser = true
		$DresserSearchButton.visible = true

func _on_dresser_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_dresser = false
		$DresserSearchButton.visible = false

func _on_dresser_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_clothes_basket_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_clothes_basket_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_basket = true
		$ClothesBasketSearchButton.visible = true

func _on_clothes_basket_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_basket = false
		$ClothesBasketSearchButton.visible = false

func _on_washer_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_dryer_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_washer_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_washer = true
		$WasherSearchButton.visible = true

func _on_washer_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_washer = false
		$WasherSearchButton.visible = false

func _on_dryer_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_dryer = true
		$DryerSearchButton.visible = true

func _on_dryer_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_dryer = false
		$DryerSearchButton.visible = false

func _on_counter_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_counter_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_counter = true
		$CounterSearchButton.visible = true

func _on_counter_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_counter = false
		$CounterSearchButton.visible = false

func _on_trash_search_button_pressed():
	player.can_move = false
	searching = true
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(1.0).timeout
	UI.resume_time()
	UI.fade_from_black()
	player.can_move = true
	searching = false
	UI.show_notification("Didn't find anything")

func _on_trash_area_2d_body_entered(body):
	if body == player and Globals.is_sneaking:
		near_kitchen_trash = true
		$TrashSearchButton.visible = true

func _on_trash_area_2d_body_exited(body):
	if body == player and Globals.is_sneaking:
		near_kitchen_trash = false
		$TrashSearchButton.visible = false

func _on_side_door_area_2d_body_entered(body):
	if body == player:
		near_side_door = true

func _on_side_door_area_2d_body_exited(body):
	if body == player:
		near_side_door = false
		_close_side_door()

func _on_side_door_area_2d_2_body_entered(body):
	if body == player:
		player.can_move = false
		UI.fade_to_black()
		await Globals.create_tracked_timer(0.5).timeout
		player.can_move = true
		UI.fade_from_black()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Unit3CRoom2.tscn")

func _open_side_door():
	$SideDoorBody2D/CollisionShape2D.disabled = true
	$SideDoorSprite.play("coffee_door_open")

func _close_side_door():
	$SideDoorBody2D/CollisionShape2D.set_deferred("disabled", false)
	$SideDoorSprite.play("coffee_door_closed")

func dialogue_highlight_button(index):
	# Reset all children to default state
	if talking:
		var player_node = get_tree().current_scene.get_node("Player")
		var dialogue_container = player_node.dialogue_container
		for child in dialogue_container.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = dialogue_container.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

# Adjusted select_button function to handle dynamically created buttons
func dialogue_select_button(index):
	if talking:
		var player_node = get_tree().current_scene.get_node("Player")
		var dialogue_container = player_node.dialogue_container
		var selected_button = dialogue_container.get_child(index)
		print("Selected button: %s" % selected_button.text)
		if selected_button.text == "No, I'm good":
			talk_to_elena_2()
		elif selected_button.text == "Yeah, what's your favorite dish?":
			talk_to_elena_3()
		else:
			pass

func _on_elena_area_2d_body_entered(body):
	if body == player:
		near_elena = true

func _on_elena_area_2d_body_exited(body):
	if body == player:
		near_elena = false

func _on_mateo_area_2d_body_entered(body):
	if body == player:
		near_mateo = true

func _on_mateo_area_2d_body_exited(body):
	if body == player:
		near_mateo = false

func talk_to_elena():
	if get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		player.can_move = false
		talking = true
		player_node.dialogue_label.text = "Hi, how are you?"
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		$Elena/DialogueLabel.text = "I'm doing well, thank you. 
		Can I help you with something?"
		$Elena/DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$Elena/DialogueLabel.visible = false
		for child in player_node.dialogue_container.get_children():
			child.queue_free()
		var no_im_good_button = Button.new()
		no_im_good_button.text = "No, I'm good."
		no_im_good_button.connect("pressed", Callable(self, "talk_to_elena_2"))
		player_node.dialogue_container.add_child(no_im_good_button)
		var dish_button = Button.new()
		if Globals.player_social == 0:
			dish_button.disabled = true
			dish_button.text = "Yeah, what's your favorite dish? 
			(Locked, requires at least 1 social skill point.)"
		else:
			dish_button.disabled = false
			dish_button.text = "Yeah, what's your favorite dish?"
		#dish_button.connect("pressed", Callable(self, "ask_fav_dish"))
		dish_button.connect("pressed", Callable(self, "talk_to_elena_3"))
		player_node.dialogue_container.add_child(dish_button)
		player_node.dialogue_container.visible = true
		dialogue_selected_index = 0
		dialogue_highlight_button(dialogue_selected_index)

func talk_to_elena_2():
	if get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		player_node.dialogue_container.visible = false
		player_node.dialogue_label.text = "No, I'm good."
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		talking = false
		player.can_move = true

func talk_to_elena_3():
	if get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		player_node.dialogue_container.visible = false
		player_node.dialogue_label.text = "Yeah, what's your favorite dish?"
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		$Elena/DialogueLabel.text = "Oh, um. My favorite dish is Mole Poblano."
		$Elena/DialogueLabel.visible = true
		UI.play_dialogue_audio()
		MissionsManager.mark_task_completed("culinary_reconnaissance", "Find out Elena from 3C's favorite dish")
		await wait_for_input()
		$Elena/DialogueLabel.text = "Why do you ask?"
		UI.play_dialogue_audio()
		await wait_for_input()
		$Elena/DialogueLabel.visible = false
		player_node.dialogue_label.text = "No reason."
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		$Elena/DialogueLabel.text = "Okay..."
		$Elena/DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$Elena/DialogueLabel.visible = false
		talking = false
		player.can_move = true

func wait_for_input() -> void:
	input_received = false
	while not input_received:
		#await get_tree().idle_frame
		await get_tree().process_frame

func talk_to_mateo():
	pass
