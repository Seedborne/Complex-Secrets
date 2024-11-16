extends Node

# Define the file path for saving and loading
const SAVE_FILE_PATH = "user://save_game.json"

# Method to save game data
func save_game():
	var player_position = {}
	if get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		player_position = {
			"x": player_node.global_position.x,
			"y": player_node.global_position.y
			}
	var event_states = {}
	for event in Globals.events:
		event_states[event["name"]] = event["triggered"]
	var save_data = {
		"stats": {
			"speed": Globals.player_speed,
			"strength": Globals.player_strength,
			"intelligence": Globals.player_intelligence,
			"social": Globals.player_social,
			"stealth": Globals.player_stealth
		},
		"bars": {
			"hunger": UI.hunger_bar,
			"sleep": UI.sleep_bar,
			"grades": UI.grades_bar
		},
		"time": {
			"current_hour": UI.current_hour,
			"current_minute": UI.current_minute,
			"current_day_index": UI.current_day_index
		},
		"date": {
			"current_day": UI.current_day,
			"current_month": UI.current_month,
			"current_year": UI.current_year
		},
		"floor": Globals.current_floor,
		"location": Globals.current_location,
		
		"player_position": player_position,
		
		"inventory": Globals.player_inventory,
		"carry_weight": Globals.current_carry_weight,
		"item_stock": Globals.item_stock,
		
		"money": Globals.player_money,
		
		"delivery_queue": Globals.delivery_queue,
		"mailbox_items": Globals.mailbox_items,
		
		"bookshelf_inventory": Globals.bookshelf_inventory,
		
		"event_states": event_states
	}

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))  # Convert dictionary to JSON and save it
		file.close()
		print("Game saved successfully!")
	else:
		print("Error saving game")

# Method to load game data
func load_game():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_data = file.get_as_text()
			
			var json = JSON.new()
			var parse_result = json.parse(json_data)
			if parse_result == OK:  # Check if the JSON was parsed successfully
				var save_data = json.get_data()
				if typeof(save_data) == TYPE_DICTIONARY:
					apply_loaded_data(save_data)
					print("Game loaded successfully!")
				else:
					print("Error: save data is corrupted or not a dictionary.")
			else:
				print("Error loading game: failed to parse JSON.")
			file.close()
		else:
			print("Error loading game: could not open file.")
	else:
		print("Save file not found.")

# Method to apply loaded data to the game's state
func apply_loaded_data(save_data):
	# Restore player stats
	Globals.player_speed = save_data["stats"]["speed"]
	Globals.player_strength = save_data["stats"]["strength"]
	Globals.player_intelligence = save_data["stats"]["intelligence"]
	Globals.player_social = save_data["stats"]["social"]
	Globals.player_stealth = save_data["stats"]["stealth"]

	# Restore bar statuses
	UI.hunger_bar = save_data["bars"]["hunger"]
	UI.sleep_bar = save_data["bars"]["sleep"]
	UI.grades_bar = save_data["bars"]["grades"]

	# Restore time and day of week
	UI.current_hour = save_data["time"]["current_hour"]
	UI.current_minute = save_data["time"]["current_minute"]
	UI.current_day_index = save_data["time"]["current_day_index"]

	# Restore date (day, month, year)
	UI.current_day = save_data["date"]["current_day"]
	UI.current_month = save_data["date"]["current_month"]
	UI.current_year = save_data["date"]["current_year"]

	# Restore location
	Globals.current_floor = save_data["floor"]
	Globals.current_location = save_data["location"]
	
	Globals.player_inventory = save_data["inventory"]
	Globals.current_carry_weight = save_data["carry_weight"]
	Globals.item_stock = save_data["item_stock"]
	
	Globals.player_money = save_data["money"]
	
	Globals.delivery_queue = save_data["delivery_queue"]
	Globals.mailbox_items = save_data["mailbox_items"]
	
	Globals.bookshelf_inventory = save_data["bookshelf_inventory"]
	
	if save_data.has("event_states"):
		for event in Globals.events:
			if event["name"] in save_data["event_states"]:
				event["triggered"] = save_data["event_states"][event["name"]]

	UI.update_bars()
	UI.update_clock_display()
	load_current_location()
	
	var player_position = save_data["player_position"]
	if player_position:
		call_deferred("_restore_player_position", player_position)

func _restore_player_position(player_position):
	while get_tree().current_scene == null or not get_tree().current_scene.has_node("Player"):
		await get_tree().process_frame
	if get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		player_node.global_position = Vector2(
			player_position["x"],
			player_position["y"]
		)

func load_current_location():
	# Construct the path to the scene based on the current location
	var scene_path = "res://Scenes/" + Globals.current_location + ".tscn"

	# Check if the file exists before changing the scene
	if FileAccess.file_exists(scene_path):
		# Change to the specified scene
		get_tree().change_scene_to_file(scene_path)
		print("Loaded scene:", scene_path)
	#else:
		# If the scene file doesn't exist, print an error message and send to Lobby
		#get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")
		#print("Error: Scene file for location", Globals.current_location, "not found at", scene_path)
