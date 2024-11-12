extends Node2D

@export var player_scene: PackedScene 
var player = null
var near_computer = false
var near_door = false
var door_open = false
var bed_buttons = ["BedButton", "BedButton2", "BedButton3"]  # Your button list
var bed_selected_index = 0
var near_bed = false
var near_bookshelf = false
var bookshelf_selected_index = 0
@onready var bookshelf_container = $BookshelfVBoxContainer

func _ready():
	player_scene = load("res://Scenes/Player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	Globals.current_location = "Unit3F"
	Globals.current_floor = 3
	if not Globals.on_computer:
		player.position = Vector2(800, 260)
		player.can_move = true
		UI.fade_from_black()
		print("In Unit3F")
		await get_tree().create_timer(0.5).timeout
		_close_door()
	else:
		player.position = Vector2(1310, 530)
		player.can_move = true
		Globals.on_computer = false
		$DoorSprite.visible = true

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

func _on_desk_area_2d_body_exited(body):
	if body == player:
		near_computer = false

func _input(event):
	if event.is_action_pressed("ui_interact") and near_computer:
		get_tree().change_scene_to_file("res://Scenes/Computer.tscn")
	if event.is_action_pressed("ui_interact") and near_door and not door_open:
		_open_door()
	if event.is_action_pressed("scroll_down") and near_bed:
		bed_selected_index = (bed_selected_index + 1) % bed_buttons.size()
		bed_highlight_button(bed_selected_index)
	elif event.is_action_pressed("scroll_up") and near_bed:
		bed_selected_index = (bed_selected_index - 1 + bed_buttons.size()) % bed_buttons.size()
		bed_highlight_button(bed_selected_index)
	elif event.is_action_pressed("ui_interact") and near_bed:
		bed_select_button(bed_selected_index)
	if event.is_action_pressed("scroll_down") and near_bookshelf:
		bookshelf_selected_index = (bookshelf_selected_index + 1) % bookshelf_container.get_child_count()
		bookshelf_highlight_button(bookshelf_selected_index)
	elif event.is_action_pressed("scroll_up") and near_bookshelf:
		bookshelf_selected_index = (bookshelf_selected_index - 1 + bookshelf_container.get_child_count()) % bookshelf_container.get_child_count()
		bookshelf_highlight_button(bookshelf_selected_index)
	elif event.is_action_pressed("ui_interact") and near_bookshelf:
		bookshelf_select_button(bookshelf_selected_index)

# Adjusted highlight_button function for bookshelf buttons
func bookshelf_highlight_button(index):
	# Reset all children to default state
	if near_bookshelf:
		for child in bookshelf_container.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = bookshelf_container.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

# Adjusted select_button function to handle dynamically created buttons
func bookshelf_select_button(index):
	if near_bookshelf:
		var selected_button = bookshelf_container.get_child(index)
		print("Selected button: %s" % selected_button.text)
		if selected_button.text == "Store Books":
			store_books()
		else:
			# Assuming the book buttons trigger a read function
			read_book(selected_button.text)  # Pass the book name to the read function

func bed_highlight_button(index):
	# Reset all children to default state
	if near_bed:
		for child in $BedVBoxContainer.get_children():
			child.focus_mode = Control.FOCUS_NONE  # Remove highlight
	# Highlight the selected child
		var selected_child = $BedVBoxContainer.get_child(index)
		selected_child.focus_mode = Control.FOCUS_ALL
		selected_child.grab_focus()

func bed_select_button(index):
	if near_bed:
		var selected_button = bed_buttons[index]
		print("Selected button: %s" % selected_button)
		if selected_button == "BedButton":
			_on_bed_button_pressed()
		elif selected_button == "BedButton2":
			_on_bed_button_2_pressed()
		elif selected_button == "BedButton3":
			_on_bed_button_3_pressed()

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
		await get_tree().create_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Floor3.tscn")

func _on_bed_area_2d_body_entered(body):
	if body == player:
		near_bed = true
		bed_selected_index = 0
		bed_highlight_button(bed_selected_index)
		$BedVBoxContainer.visible = true

func _on_bed_area_2d_body_exited(body):
	if body == player:
		near_bed = false
		$BedVBoxContainer.visible = false

func _on_bed_button_pressed():
	player.can_move = false
	UI.pause_time()
	UI.fade_to_black()
	await get_tree().create_timer(1.5).timeout
	UI.resume_time()
	UI.sleep_for_hours(2)
	UI.fade_from_black()
	player.position = Vector2(1740, 710)
	player.can_move = true

func _on_bed_button_2_pressed():
	player.can_move = false
	UI.pause_time()
	UI.fade_to_black()
	await get_tree().create_timer(2.5).timeout
	UI.resume_time()
	UI.sleep_for_hours(4)
	UI.fade_from_black()
	player.position = Vector2(1740, 710)
	player.can_move = true

func _on_bed_button_3_pressed():
	player.can_move = false
	UI.pause_time()
	UI.fade_to_black()
	await get_tree().create_timer(4.0).timeout
	UI.resume_time()
	UI.sleep_for_hours(8)
	UI.fade_from_black()
	player.position = Vector2(1740, 710)
	player.can_move = true

func _on_bookshelf_area_2d_body_entered(body):
	if body == player:
		near_bookshelf = true
		update_bookshelf_display()
		$BookshelfVBoxContainer.visible = true

func _on_bookshelf_area_2d_body_exited(body):
	if body == player:
		near_bookshelf = false
		$BookshelfVBoxContainer.visible = false

func update_bookshelf_display():
	# Clear existing buttons
	for child in bookshelf_container.get_children():
		child.queue_free()

	var has_books_to_store = Globals.player_inventory["Books"].size() > 0
# Add a button to store books
	var store_button = Button.new()
	store_button.text = "Store Books"
	store_button.disabled = not has_books_to_store
	store_button.connect("pressed", Callable(self, "store_books"))
	bookshelf_container.add_child(store_button)

	# Add buttons for each book in bookshelf inventory
	for book_name in Globals.bookshelf_inventory.keys():
		var button = Button.new()
		button.text = book_name
		button.connect("pressed", Callable(self, "_on_book_button_pressed").bind(book_name))
		bookshelf_container.add_child(button)
	bookshelf_selected_index = 0
	if not store_button.disabled:
		bookshelf_highlight_button(bookshelf_selected_index)

func store_books():
	for book_name in Globals.player_inventory["Books"].keys():
		var quantity = Globals.player_inventory["Books"][book_name]
		if Globals.bookshelf_inventory.has(book_name):
			Globals.bookshelf_inventory[book_name] += quantity
		else:
			Globals.bookshelf_inventory[book_name] = quantity
		
		# Set the player's inventory quantity to zero after transferring to the bookshelf
		Globals.remove_from_inventory(book_name, quantity)

	# Remove books with zero quantity by creating a new dictionary with only non-zero quantities
	var filtered_books = {}
	for book_name in Globals.player_inventory["Books"].keys():
		if Globals.player_inventory["Books"][book_name] > 0:
			filtered_books[book_name] = Globals.player_inventory["Books"][book_name]
	Globals.player_inventory["Books"] = filtered_books  # Replace with the filtered dictionary

	update_bookshelf_display()

func read_book(book_name):
	var book_info = Globals.book_stat_gain[book_name]
	if book_info:
		# Apply stat gain
		Globals[book_info["stat"]] += book_info["gain"]
		print(book_name, " read! Increased ", book_info["stat"], " by ", book_info["gain"])
		print("Player Stats
	Speed: ", Globals.player_speed, "
	Strength: ", Globals.player_strength, "
	Intelligence: ", Globals.player_intelligence, "
	Social: ", Globals.player_social, "
	Stealth: ", Globals.player_stealth
	)
		player.can_move = false
		UI.fade_to_black()
		UI.pause_time()
		await get_tree().create_timer(1.5).timeout
		UI.resume_time()
		# Skip time
		UI.skip_time(book_info["time_skip"])
		UI.fade_from_black()
		player.position = Vector2(1120, 220)
		player.can_move = true
		# Remove one copy from bookshelf inventory
		Globals.bookshelf_inventory[book_name] -= 1
		if Globals.bookshelf_inventory[book_name] <= 0:
			Globals.bookshelf_inventory.erase(book_name)
	update_bookshelf_display()

func _on_book_button_pressed(book_name):
	read_book(book_name)
