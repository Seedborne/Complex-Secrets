extends Node

var new_game = false
var in_game = false
var in_stats = false
var in_cutscene = false
var game_over = false
var game_paused = false
var current_location = ""
var current_floor = 0
var climbing_stairs = false
var descending_stairs = false
var at_class = false
var at_work = false
var is_sleeping = false
var is_eating = false
var is_exercising = false
var on_computer = false
var lights_on = true
var tenant_home = false
var delivery_queue = []  # Array to store orders scheduled for delivery
var mailbox_items = [] # Stores items that are ready to be collected from the mailbox
var item_stock = {
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

# Define item categories
var item_categories = {
	"Bobby Pins": "Tools",
	"Ballpoint Pen": "Tools",
	"Scissors": "Tools",
	"Digital Camera": "Tools",
	"Voice Recorder": "Tools",
	"Trail Camera": "Tools",
	"IntBook1": "Books",
	"SocBook1": "Books",
	"StlBook1": "Books",
	"IntBook2": "Books",
	"SocBook2": "Books",
	"StlBook2": "Books",
	"IntBook3": "Books",
	"SocBook3": "Books",
	"StlBook3": "Books",
	"IntBook4": "Books",
	"SocBook4": "Books",
	"StlBook4": "Books",  
	"Gym Key": "Keys",
	"Mail Key 3F": "Keys",
	"Unit Key 3F": "Keys", 
	# Add other items and their categories here
}
var item_weights = {
	"Bobby Pins": 0.1,
	"Ballpoint Pen": 0.5,
	"Scissors": 1.0,
	"Digital Camera": 2.0,
	"Voice Recorder": 1.5,
	"Trail Camera": 3.0,
	"IntBook1": 2.0,
	"SocBook1": 2.0,
	"StlBook1": 2.0,
	"IntBook2": 2.0,
	"SocBook2": 2.0,
	"StlBook2": 2.0,
	"IntBook3": 2.0,
	"SocBook3": 2.0,
	"StlBook3": 2.0,
	"IntBook4": 2.0,
	"SocBook4": 2.0,
	"StlBook4": 2.0,
	"Gym Key": 0.2,
	"Mail Key 3F": 0.2,
	"Unit Key 3F": 0.2,
	# Add weights for other items
}
var bookshelf_inventory = {}
var book_stat_gain = {
	"IntBook1": {"stat": "player_intelligence", "gain": 1, "time_skip": 2},
	"SocBook1": {"stat": "player_social", "gain": 1, "time_skip": 2},
	"StlBook1": {"stat": "player_stealth", "gain": 1, "time_skip": 2},
	"IntBook2": {"stat": "player_intelligence", "gain": 2, "time_skip": 2},
	"SocBook2": {"stat": "player_social", "gain": 2, "time_skip": 2},
	"StlBook2": {"stat": "player_stealth", "gain": 2, "time_skip": 2},
	"IntBook3": {"stat": "player_intelligence", "gain": 3, "time_skip": 2},
	"SocBook3": {"stat": "player_social", "gain": 3, "time_skip": 2},
	"StlBook3": {"stat": "player_stealth", "gain": 3, "time_skip": 2},
	"IntBook4": {"stat": "player_intelligence", "gain": 4, "time_skip": 2},
	"SocBook4": {"stat": "player_social", "gain": 4, "time_skip": 2},
	"StlBook4": {"stat": "player_stealth", "gain": 4, "time_skip": 2},
	# Add more books here with their respective stats and gains
}

var player_money: float = 0.00
var player_inventory = {
	"Books": {},
	"Keys": {},
	"Tools": {},
}

var base_carry_weight = 10.0
var current_carry_weight = 0.00

var player_speed: int = 250
var player_strength: float = 0.0
var player_intelligence: int = 0
var player_social: int = 0
var player_stealth: int = 0

var active_timers = []

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

func create_tracked_timer(duration: float) -> SceneTreeTimer:
	# Create the timer
	var timer = get_tree().create_timer(duration)
	# Add it to the active timers list
	active_timers.append(timer)
	# Connect the timeout signal and bind the timer instance
	timer.timeout.connect(_on_timer_timeout.bind(timer))
	return timer

func _on_timer_timeout(timer: SceneTreeTimer) -> void:
	# Remove the specific timer from the active list
	if timer in active_timers:
		active_timers.erase(timer)
	else:
		print("Timer not found in active_timers!")

func can_pause_game() -> bool:
	# Check if there are any active timers
	return active_timers.is_empty()

func max_carry_weight() -> float:
	return base_carry_weight + (player_strength * 2.5)

# Methods to increase stats
func increase_player_speed(amount: int):
	player_speed += amount
	player_speed = clamp(player_speed, 250, 500)
	if player_speed == 500:
		UI.show_notification("Speed maxed out!")
		print("Player speed is maxed out at ", player_speed)
	else:
		UI.show_notification("Speed increased from running")
		print("Player speed increased to ", player_speed)

func increase_player_strength(amount: float):
	player_strength += amount
	player_strength = clamp(player_strength, 0.0, 10.0)
	if player_strength == 10.0:
		UI.show_notification("Strength maxed out!")
		print("Player strength is maxed out at ", player_strength)
	else:
		UI.show_notification("Strength increased from lifting")
		print("Player strength increased to ", player_strength)

func increase_player_intelligence(amount: int):
	player_intelligence += amount
	player_intelligence = clamp(player_intelligence, 0, 10)
	UI.show_notification("Intelligence increased by %d" % amount)
	print("Player intelligence increased to ", player_intelligence)

func increase_player_social(amount: int):
	player_social += amount
	player_social = clamp(player_social, 0, 10)
	UI.show_notification("Social increased by %d" % amount)
	print("Player social increased to ", player_social)

func increase_player_stealth(amount: int):
	player_stealth += amount
	player_stealth = clamp(player_stealth, 0, 10)
	UI.show_notification("Stealth increased by %d" % amount)
	print("Player stealth increased to ", player_stealth)

func increase_player_money(amount: float):
	player_money += amount
	UI.show_notification("$%.2f earned" % amount)
	print("Player money increased to $", player_money)

func decrease_player_money(amount: float):
	player_money -= amount
	UI.show_notification("$%.2f spent" % amount)
	print("Player money decreased to $", player_money)

func schedule_keys_delivery():
	var keys_package = {
		#"Unit Key 3F": {"quantity": 1},  # Match the expected format
		#"Mail Key 3F": {"quantity": 1},
		"Gym Key": {"quantity": 1}
	}
	mailbox_items.append(keys_package)  # Add the delivery directly to mailbox_items

func schedule_delivery(items: Dictionary, order_date: Dictionary):
	var delivery_day = order_date["day"]
	var delivery_month = order_date["month"]
	var delivery_year = order_date["year"]
	# Calculate the delivery date, considering the no-Sunday delivery rule
	# Advance to the next day, unless it's Saturday or Sunday
	if UI.days_of_week[order_date["day_index"]] == "Saturday":
		delivery_day += 2  # Deliver on Monday
	elif UI.days_of_week[order_date["day_index"]] == "Sunday":
		delivery_day += 1  # Deliver on Monday
	else:
		delivery_day += 1  # Deliver the next day

	# Check month overflow
	if delivery_day > UI.days_in_months[order_date["month"] - 1]:
		delivery_day = 1
		delivery_month += 1
		if delivery_month > 12:
			delivery_month = 1
			delivery_year += 1

	# Add to queue
	delivery_queue.append({
		"items": items,
		"delivery_day": delivery_day,
		"delivery_month": delivery_month,
		"delivery_year": delivery_year
	})

func collect_mail():
	if mailbox_items.size() > 0:
		var items_to_keep = []  # List to store items that couldn't be collected
		for items in mailbox_items:
			print("Collecting package items:", items)
			var failed_to_collect = false  # Track if any item in the package fails to be collected

			for item_name in items.keys():
				var quantity = items[item_name]["quantity"]
				var success = add_to_inventory(item_name, quantity)  # Attempt to add to inventory
				
				if not success:
					failed_to_collect = true  # Mark as failed if item cannot be added
					print("Could not collect", quantity, item_name, "- exceeded carry weight limit.")
					break  # Stop collecting if any item in the package cannot be added

			# Only keep the package in mailbox if collection failed
			if failed_to_collect:
				items_to_keep.append(items)

		# Update mailbox items with only the packages that couldn't be collected
		mailbox_items = items_to_keep

		if mailbox_items.size() > 0:
			print("Some items could not be collected due to weight limit and remain in the mailbox.")
		else:
			print("Collected all mail items!")
	else:
		UI.show_notification("Mailbox is empty.")
		print("No mail to collect.")

func add_to_inventory(item_name: String, quantity: int):
	var adjusted_quantity = quantity
	# Special case for "Bobby Pins" to add 10 per ordered quantity
	if item_name == "Bobby Pins":
		adjusted_quantity = quantity * 10
	var category = item_categories[item_name]
	var item_weight = item_weights.get(item_name, 0) * adjusted_quantity  # Total weight for quantity
	# Check if adding the item exceeds the max carry weight
	if current_carry_weight + item_weight > max_carry_weight():
		var carry_cap_message = "Cannot pick up %s - over max carry weight!" % item_name
		UI.show_notification(carry_cap_message)
		print("Cannot pick up", item_name, "- over max carry weight!")
		return false  # Indicate that the item couldn't be added
	# Proceed to add the item since it’s within the weight limit
	current_carry_weight += item_weight  # Update carry weight
	UI.update_carry_weight_display()
	if player_inventory[category].has(item_name):
		player_inventory[category][item_name] += adjusted_quantity
	else:
		player_inventory[category][item_name] = adjusted_quantity
	#var message = "+ %s" % [item_name]
	var message = "+ %d %s" % [adjusted_quantity, item_name]
	UI.show_notification(message)
	if item_name == "Gym Key":
		UI.complete_objective("Collect gym key from mailbox")
	print("Added ", adjusted_quantity, " ", item_name, " to ", category, " inventory. Total: ", player_inventory[category][item_name])
	return true

func remove_from_inventory(item_name: String, quantity: int):
	var category = item_categories[item_name]
	var item_weight = item_weights.get(item_name, 0) * quantity

	if player_inventory[category].has(item_name):
		player_inventory[category][item_name] -= quantity
		if player_inventory[category][item_name] <= 0:
			player_inventory[category].erase(item_name)

		current_carry_weight = max(current_carry_weight - item_weight, 0)  # Ensure weight doesn’t go negative
		UI.update_carry_weight_display()
		#var message = "Removed %s from inventory." % [item_name]
		var message = "Removed %d %s from inventory." % [quantity, item_name]
		UI.show_notification(message)
		print("Removed", quantity, item_name, "from", category, "inventory.")
	else:
		print("Item not in inventory.")

func has_item_in_inventory(item_name: String) -> bool:

	var category = item_categories.get(item_name)
	if category:
		# Check if the item exists in the player's inventory and has a quantity > 0
		return player_inventory[category].has(item_name) and player_inventory[category][item_name] > 0
	return false

func check_tenant_availability():
	tenant_home = false
