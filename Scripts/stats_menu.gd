extends CanvasLayer

@onready var stats_container = $Panel/HBoxContainer/StatsContainer
@onready var inventory_container = $Panel/HBoxContainer/InventoryContainer
@onready var delivery_container = $Panel/HBoxContainer/DeliveryContainer

func _ready():
	update_stats_screen()

func update_stats_screen():
	for child in stats_container.get_children():
		child.queue_free()
	for child in inventory_container.get_children():
		child.queue_free()
	for child in delivery_container.get_children():
		child.queue_free()
	
	populate_stats()
	populate_inventory()
	populate_deliveries()

func _input(_event):
	if Input.is_action_just_pressed("ui_stats") and Globals.in_game and not Globals.game_paused and not Globals.on_computer and Globals.can_pause_game() and not Globals.game_over and not Globals.in_cutscene:
		if not StatsMenu.visible:
			StatsMenu.visible = true
			Globals.in_stats = true
			get_tree().paused = true
			print("in stats menu")
		else:
			StatsMenu.visible = false
			Globals.in_stats = false
			get_tree().paused = false
			print("left stats menu")

func populate_stats():
	# List of stats to display
	var stats = {
		#"Money": "$%.2f" % Globals.player_money,
		"Speed": "%d / %d" % [(Globals.player_speed), 500],
		"Strength": "%.1f / %d" % [(Globals.player_strength), 10],
		"Intelligence": "%d / %d" % [(Globals.player_intelligence), 10],
		"Social": "%d / %d" % [(Globals.player_social), 10],
		"Stealth": "%d / %d" % [(Globals.player_stealth), 10],
		#"Carry Weight": "%.2f / %.2f" % [Globals.current_carry_weight, Globals.max_carry_weight()]
	}

	for stat_name in stats.keys():
		var stat_label = Label.new()
		stat_label.text = "%s: %s" % [stat_name, stats[stat_name]]
		stat_label.add_theme_font_size_override("font_size", 32)
		stats_container.add_child(stat_label)

func populate_inventory():
	# Display inventory by categories
	for category in Globals.player_inventory.keys():
		# Add category header
		var category_label = Label.new()
		category_label.text = "%s:" % category
		category_label.add_theme_font_size_override("font_size", 32)
		category_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1))  # Optional: Customize category header
		inventory_container.add_child(category_label)

		# Display items in the category
		for item_name in Globals.player_inventory[category].keys():
			var quantity = Globals.player_inventory[category][item_name]
			var item_label = Label.new()
			item_label.text = "- %s x%d" % [item_name, quantity]
			item_label.add_theme_font_size_override("font_size", 24)
			inventory_container.add_child(item_label)

func populate_deliveries():
	# Display scheduled deliveries
	if Globals.delivery_queue.size() > 0:
		for delivery in Globals.delivery_queue:
			var delivery_label = Label.new()
			var delivery_date = "%02d/%02d/%d" % [delivery["delivery_month"], delivery["delivery_day"], delivery["delivery_year"]]
			delivery_label.text = "Delivery scheduled for: %s" % delivery_date
			delivery_label.add_theme_font_size_override("font_size", 32)
			delivery_container.add_child(delivery_label)
	else:
		var no_delivery_label = Label.new()
		no_delivery_label.text = "No deliveries scheduled."
		no_delivery_label.add_theme_font_size_override("font_size", 32)
		delivery_container.add_child(no_delivery_label)

func _on_visibility_changed():
	update_stats_screen()
