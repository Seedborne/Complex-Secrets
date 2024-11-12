extends Node

var in_game = false
var current_location = ""
var current_floor = 0
var climbing_stairs = false
var descending_stairs = false
var at_class = false
var at_work = false
var is_sleeping = false
var is_eating = false
var on_computer = false
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
	# Add other items and their categories here
}
var item_weights = {
	"Bobby Pins": 0.01,
	"Ballpoint Pen": 0.2,
	"Scissors": 0.5,
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
	"Tools": {},
}

var base_carry_weight = 10.0
var current_carry_weight = 0.0

var player_speed: int = 250
var player_strength: int = 1
var player_intelligence: int = 1
var player_social: int = 1
var player_stealth: int = 1

func _ready():
	pass
	
func _process(_delta):
	pass

func max_carry_weight() -> float:
	return base_carry_weight + (player_strength * 2.5)

# Methods to increase stats
func increase_player_speed(amount: int):
	player_speed += amount
	print("player_speed increased to ", player_speed)

func increase_player_strength(amount: int):
	player_strength += amount
	print("player_strength increased to ", player_strength)

func increase_player_intelligence(amount: int):
	player_intelligence += amount
	print("player_intelligence increased to ", player_intelligence)

func increase_player_social(amount: int):
	player_social += amount
	print("player_social increased to ", player_social)

func increase_player_stealth(amount: int):
	player_stealth += amount
	print("player_stealth increased to ", player_stealth)

func increase_player_money(amount: float):
	player_money += amount
	print("player_money increased to ", player_money)

func decrease_player_money(amount: int):
	player_money -= amount
	print("player_money decreased to ", player_money)

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
		print("Cannot pick up", item_name, "- over max carry weight!")
		return false  # Indicate that the item couldn't be added
	# Proceed to add the item since it’s within the weight limit
	current_carry_weight += item_weight  # Update carry weight
	UI.update_carry_weight_display()
	if player_inventory[category].has(item_name):
		player_inventory[category][item_name] += adjusted_quantity
	else:
		player_inventory[category][item_name] = adjusted_quantity
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
		print("Removed", quantity, item_name, "from", category, "inventory.")
	else:
		print("Item not in inventory.")

func check_tenant_availability():
	tenant_home = true
