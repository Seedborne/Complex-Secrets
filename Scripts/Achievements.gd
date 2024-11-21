extends Node

var achievements = {
	"enter_unit_3f": false,
	"unlock_ending_1": false,
	"unlock_ending_2": false,
	"unlock_ending_3": false,
	"unlock_ending_4": false,
	"unlock_all_endings": false,
	"anything_for_money": false, #burn someone's unit down
	"mind_own_business": false, #find new name for this one, do no spy missions
	"nosy_nelly": false, #do all spy missions
	"antisocial": false, #complete the game without talking to anyone when not needed
	"discover_bookcase_secret": false,
	# Add more achievements as needed
}

var achievements_file_path = "user://achievements_save_file.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Automatically load achievements when the game starts
	load_achievements()

# Save achievements to a separate file
func save_achievements():
	var achievements_file = FileAccess.open(achievements_file_path, FileAccess.WRITE)
	if achievements_file:
		achievements_file.store_string(JSON.stringify(achievements))
		achievements_file.close()
		print("Achievements saved")
	else:
		print("Failed to open file for saving achievements.")

# Load achievements when starting the game
func load_achievements():
	if FileAccess.file_exists(achievements_file_path):
		var file = FileAccess.open(achievements_file_path, FileAccess.READ)
		if file:
			var json_data = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_data)
			if parse_result == OK:  # Check if the JSON was parsed successfully
				var achievements_data = json.get_data()
				if typeof(achievements_data) == TYPE_DICTIONARY:
					for key in achievements_data.keys():
						if achievements.has(key):
							achievements[key] = achievements_data[key]
					print("Achievements loaded successfully: ", achievements)
				else:
					print("Achievements data is not a dictionary.")
			else:
				print("Failed to parse JSON data.")
			file.close()
		else:
			print("Failed to open file for reading achievements.")
	else:
		print("Achievements file does not exist.")

# Function to unlock a specific achievement
func unlock_achievement(achievement_key):
	if achievements.has(achievement_key) and not achievements[achievement_key]:
		achievements[achievement_key] = true
		save_achievements()  # Autosave immediately when an achievement is unlocked
		print("Achievement unlocked: ", achievement_key)
	if achievement_key.begins_with("unlock_ending_"):  # Check only if the unlocked key is an ending
		if all_endings_unlocked():  # Verify if all endings are now unlocked
			achievements["unlock_all_endings"] = true
			print("Achievement unlocked: unlock_all_endings")

func is_achievement_unlocked(achievement_key: String) -> bool:
	if achievements.has(achievement_key):
		return achievements[achievement_key]
	else:
		print("Achievement key not found: ", achievement_key)
		return false  # Return false if the achievement key does not exist

func all_endings_unlocked() -> bool:
	for key in achievements.keys():
		if key.begins_with("unlock_ending_") and not achievements[key]:
			return false  # If any ending is not unlocked, return false
	return true  # All endings are unlocked

func delete_achievements_data():
	if FileAccess.file_exists(achievements_file_path):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove(achievements_file_path)
			print("Achievements data deleted successfully.")
		else:
			print("Failed to access achievements directory.")
	else:
		print("Achievements data file does not exist.")
