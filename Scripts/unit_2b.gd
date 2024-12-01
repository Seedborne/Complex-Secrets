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

@onready var bookshelf_container = $BookshelfVBoxContainer

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	if lights_on:
		$LightsOff.visible = false
		$LightswitchSprite2D.texture = load("res://Assets/testlightswitch-on.png")
	else:
		$LightsOff.visible = true
		$LightswitchSprite2D.texture = load("res://Assets/testlightswitch-off.png")
	if Globals.current_location == "Floor 2":
		Globals.current_location = "Unit 2B"
		player.position = Vector2(800, 260)
		player.can_move = true
		UI.fade_from_black()
		print("In Unit2B")
		await Globals.create_tracked_timer(0.5).timeout
		_close_door()
	elif Globals.on_computer:
		Globals.current_location = "Unit 2B"
		player.position = Vector2(1310, 530)
		player.can_move = true
		Globals.on_computer = false
		$DoorSprite.visible = true
	else:
		Globals.current_location = "Unit 2B"
		player.position = Vector2(800, 260)
		player.can_move = true
		$DoorSprite.visible = true
		UI.fade_from_black()
		print("In Unit 2B")
	Globals.current_floor = 2
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
	if body == player:
		near_computer = true
		$DeskSearchButton.visible = true

func _on_desk_area_2d_body_exited(body):
	if body == player:
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
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor2.tscn")

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
	if body == player:
		near_bed = true
		$BedSearchButton.visible = true

func _on_bed_area_2d_body_exited(body):
	if body == player:
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
	if body == player:
		near_bookshelf = true
		$BookshelfSearchButton.visible = true
		#update_bookshelf_display()
		#$BookshelfVBoxContainer.visible = true
		#bookshelf_selected_index = 0
		#bookshelf_highlight_button(bookshelf_selected_index)

func _on_bookshelf_area_2d_body_exited(body):
	if body == player:
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
	if body == player:
		near_secret_path = true

func _on_secret_bookshelf_area_2d_body_exited(body):
	if body == player:
		near_secret_path = false

func _open_secret_bookshelf():
	$BookshelfBody2D/CollisionShape2D.disabled = true
	$BookshelfBody2D/CollisionShape2D2.disabled = false
	$BookshelfArea2D/CollisionShape2D.disabled = true
	$BookshelfSprite.play("bookshelf_open")
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
	if body == player:
		near_nightstand_1 = true
		$NightstandSearchButton1.visible = true

func _on_nightstand_area_2d_body_exited(body):
	if body == player:
		near_nightstand_1 = false
		$NightstandSearchButton1.visible = false

func _on_nightstand_area_2d_2_body_entered(body):
	if body == player:
		near_nightstand_2 = true
		$NightstandSearchButton2.visible = true

func _on_nightstand_area_2d_2_body_exited(body):
	if body == player:
		near_nightstand_2 = false
		$NightstandSearchButton2.visible = false

func _on_dresser_area_2d_body_entered(body):
	if body == player:
		near_dresser = true
		$DresserSearchButton.visible = true

func _on_dresser_area_2d_body_exited(body):
	if body == player:
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
	if body == player:
		near_basket = true
		$ClothesBasketSearchButton.visible = true

func _on_clothes_basket_area_2d_body_exited(body):
	if body == player:
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
	if body == player:
		near_washer = true
		$WasherSearchButton.visible = true

func _on_washer_area_2d_body_exited(body):
	if body == player:
		near_washer = false
		$WasherSearchButton.visible = false

func _on_dryer_area_2d_body_entered(body):
	if body == player:
		near_dryer = true
		$DryerSearchButton.visible = true

func _on_dryer_area_2d_body_exited(body):
	if body == player:
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
	if body == player:
		near_counter = true
		$CounterSearchButton.visible = true

func _on_counter_area_2d_body_exited(body):
	if body == player:
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
	if body == player:
		near_kitchen_trash = true
		$TrashSearchButton.visible = true

func _on_trash_area_2d_body_exited(body):
	if body == player:
		near_kitchen_trash = false
		$TrashSearchButton.visible = false
