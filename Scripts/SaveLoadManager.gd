extends Node

# Define the file path for saving and loading
const SAVE_FILE_PATH = "user://save_game.json"

# Method to save game data
func save_game():
	var player_position = {}
	if get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		player_position = {
			"x": player_node.global_position.x,
			"y": player_node.global_position.y
			}
	else:
		print("Player coodinates not saved.")
	var event_states = {}
	for event in EventsManager.events:
		event_states[event["name"]] = event["triggered"]
	var email_states = {}
	for email in EventsManager.emails:
		email_states[email["id"]] = {
		"read": email["read"],
		"sent": email["sent"]
	}
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
		
		"objectives": UI.objectives,
		
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
		
		"event_states": event_states,
		"emails": email_states,
		
		"3f_lights_on": Globals.lights_on,
		
		"rent_balance": EventsManager.rent_balance,
		"eviction_warning": EventsManager.eviction_warning_sent,
		
		"bgm_on": SettingsManager.bgm_on,
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
					start_new_game()
					print("Error: save data is corrupted or not a dictionary, starting new game.")
			else:
				start_new_game()
				print("Error loading game: failed to parse JSON, starting new game.")
			file.close()
		else:
			start_new_game()
			print("Error loading game: could not open file, starting new game.")
	else:
		start_new_game()
		print("Save file not found, starting new game.")

func start_new_game():
	delete_save_data()
	reset_game_state()
	Globals.new_game = true
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")
	Globals.in_game = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	UI.update_bars()
	UI.update_clock_display()
	UI.clock_timer.start()
	
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
	
	UI.objectives = save_data["objectives"]
	
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
	
	Globals.lights_on = save_data["3f_lights_on"]
	
	EventsManager.rent_balance = save_data["rent_balance"]
	EventsManager.eviction_warning_sent = save_data["eviction_warning"]
	
	SettingsManager.bgm_on = save_data["bgm_on"]
	
	if save_data.has("event_states"):
		for event in EventsManager.events:
			if event["name"] in save_data["event_states"]:
				event["triggered"] = save_data["event_states"][event["name"]]

	if save_data.has("emails"):
		for email in EventsManager.emails:
			if save_data["emails"].has(email["id"]):
				email["read"] = save_data["emails"][email["id"]]["read"]
				email["sent"] = save_data["emails"][email["id"]]["sent"]
	
	UI.update_bars()
	UI.update_clock_display()
	load_current_location()
	
	var player_position = save_data["player_position"]
	if player_position:
		call_deferred("_restore_player_position", player_position)

func _restore_player_position(player_position):
	while get_tree().current_scene == null or not get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
		await get_tree().process_frame
	if get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
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

func check_for_save_data() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		return true
	else:
		return false

func delete_save_data():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove(SAVE_FILE_PATH)
			print("Save data deleted successfully.")
		else:
			print("Failed to access directory.")
	else:
		print("Save data file does not exist.")

func reset_game_state():
	Globals.game_over = false
	Globals.game_paused = false
	Globals.in_game = false
	Globals.in_stats = false
	Globals.in_cutscene = false
	Globals.current_location = ""
	Globals.current_floor = 0
	Globals.climbing_stairs = false
	Globals.descending_stairs = false
	Globals.at_class = false
	Globals.at_work = false
	Globals.is_sleeping = false
	Globals.is_eating = false
	Globals.is_exercising = false
	Globals.on_computer = false
	Globals.lights_on = true
	Globals.tenant_home = false
	Globals.delivery_queue = []  # Array to store orders scheduled for delivery
	Globals.mailbox_items = [] # Stores items that are ready to be collected from the mailbox
	Globals.item_stock = {
		"Bobby Pins": -1,       # Unlimited stock
		"Ballpoint Pen": 1, # Limited to 1
		"Scissors": 1,
		"Digital Camera": 1,
		"Voice Recorder": 1,
		"Trail Camera": 1,
		"IntBook1": 1,
		"SocBook1": 1,
		"StlBook1": 1,
		"IntBook2": 1,
		"SocBook2": 1,
		"StlBook2": 1,
		"IntBook3": 1,
		"SocBook3": 1,
		"StlBook3": 1,
		"IntBook4": 1,
		"SocBook4": 1,
		"StlBook4": 1,    
	}

	Globals.bookshelf_inventory = {}
	Globals.player_money = 0.00
	Globals.player_inventory = {
	"Books": {},
	"Keys": {},
	"Tools": {},
}

	Globals.current_carry_weight = 0.00

	Globals.player_speed = 250
	Globals.player_strength = 0.0
	Globals.player_intelligence = 0
	Globals.player_social = 0
	Globals.player_stealth = 0

	UI.current_hour = 8  # Start the game at 8:00 AM
	UI.current_minute = 0
	UI.current_day_index = 0  # Index for days of the week (0 = Sunday, 1 = Monday, ...)
	UI.current_year = 2007
	UI.current_month = 9  # September
	UI.current_day = 2    # Start on September 2nd
# Days in each month (index 0 = January, index 11 = December)
	UI.clock_paused = false
	UI.sleep_bar = 100.0  # Starts at full
	UI.hunger_bar = 100.0  # Starts at full
# Properties for grades
	UI.grades_bar = 100.0  # Starts at full
	
	UI.objectives = []
	UI.update_objectives_ui()

	EventsManager.rent_balance = 0.0
	EventsManager.eviction_warning_sent = false
	EventsManager.reset_events()
