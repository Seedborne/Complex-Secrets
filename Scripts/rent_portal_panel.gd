extends Panel

func update_rent_info():
	var rent_container = $VBoxContainer/RentContainer
	for child in rent_container.get_children():
		child.queue_free() #clear old buttons

	# Display overdue rent if applicable
	if EventsManager.rent_balance > EventsManager.weekly_rent:
		var overdue_amount = EventsManager.weekly_rent + EventsManager.late_fee
		var overdue_due_date = "Overdue"
		var overdue_entry = create_rent_entry(overdue_amount, overdue_due_date, true)
		rent_container.add_child(overdue_entry)
	if EventsManager.rent_balance == EventsManager.weekly_rent or EventsManager.rent_balance > (EventsManager.weekly_rent * 2):
	# Display upcoming rent
		var upcoming_due_date = calculate_next_due_date()
		var upcoming_amount = EventsManager.weekly_rent
		var upcoming_entry = create_rent_entry(upcoming_amount, "Due Date: " + upcoming_due_date, false)
		rent_container.add_child(upcoming_entry)

# Create a rent entry dynamically
func create_rent_entry(amount: float, due_date: String, is_overdue: bool) -> Control:
	var rent_entry = VBoxContainer.new()

	var amount_label = Label.new()
	amount_label.text = "Amount due: $" + str(amount)
	rent_entry.add_child(amount_label)

	var due_date_label = Label.new()
	due_date_label.text = due_date
	if is_overdue:
		due_date_label.add_theme_color_override("font_color", Color.RED)
	rent_entry.add_child(due_date_label)

	var pay_button = Button.new()
	pay_button.text = "Pay $" + str(amount)
	pay_button.connect("pressed", Callable(self, "_on_pay_button_pressed").bind(amount))
	rent_entry.add_child(pay_button)

	return rent_entry

# Handle payment button press
func _on_pay_button_pressed(amount: float):
	if amount > EventsManager.rent_balance:
		amount = EventsManager.rent_balance  # Pay only the amount owed
	if amount <= 0:
		print("Payment must be greater than zero.")
	elif Globals.player_money >= amount:
		pay_rent(amount)
		update_rent_info()  # Refresh the rent info after payment
	else:
		print("Not enough money, need $", amount)

func pay_rent(amount: float):
	EventsManager.rent_balance -= amount
	Globals.player_money -= amount
	print("Payment of $", amount, " made. Remaining balance: $", EventsManager.rent_balance)
	if EventsManager.rent_balance <= EventsManager.weekly_rent:
		EventsManager.eviction_warning_sent = false  # Reset eviction warning if overdue balance cleared
	if EventsManager.rent_balance <= 0:
		print("Rent paid in full!")

# Helper function to calculate the next rent due date
func calculate_next_due_date() -> String:
	# Calculate the upcoming Monday
	var day_index = UI.current_day_index
	var days_until_due = (EventsManager.rent_due_day_index - day_index + 7) % 7
	var next_due_day = UI.current_day + days_until_due

	# Handle month overflow
	var next_due_month = UI.current_month
	var next_due_year = UI.current_year
	if next_due_day > UI.days_in_months[UI.current_month - 1]:
		next_due_day = next_due_day - UI.days_in_months[UI.current_month - 1]
		next_due_month += 1
		if next_due_month > 12:
			next_due_month = 1
			next_due_year += 1

	return "%d/%d/%d" % [next_due_month, next_due_day, next_due_year]

func _on_visibility_changed():
	update_rent_info()

func _on_refresh_button_pressed():
	update_rent_info()
