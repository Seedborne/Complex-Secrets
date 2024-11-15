extends Node

# Define the file path for saving and loading
const SAVE_FILE_PATH = "user://save_game.json"

# Method to save game data
func save_game():
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
		
		"inventory": Globals.player_inventory,
		"carry_weight": Globals.current_carry_weight,
		"item_stock": Globals.item_stock,
		
		"money": Globals.player_money,
		
		"delivery_queue": Globals.delivery_queue,
		"mailbox_items": Globals.mailbox_items,
		
		"bookshelf_inventory": Globals.bookshelf_inventory
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
			file.close()
			var json = JSON.new()
			var parse_result = json.parse(json_data)
			if parse_result.error == OK:  # Check if the JSON was parsed successfully
				var save_data = parse_result.result
				if typeof(save_data) == TYPE_DICTIONARY:
					apply_loaded_data(save_data)
					print("Game loaded successfully!")
				else:
					print("Error: save data is corrupted or not a dictionary.")
			else:
				print("Error loading game: failed to parse JSON.")
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
	
	UI.update_bars()
	UI.update_clock_display()
