extends CanvasLayer

var current_hour: int = 8  # Start the game at 8:00 AM
var current_minute: int = 0
var current_day_index: int = 0  # Index for days of the week (0 = Sunday, 1 = Monday, ...)
var days_of_week: Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var current_year: int = 2007
var current_month: int = 9  # September
var current_day: int = 2    # Start on September 2nd
# Days in each month (index 0 = January, index 11 = December)
var days_in_months = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var clock_paused = false
var sleep_bar: float = 100.0  # Starts at full
var sleep_drain_rate: float = 0.1  # Amount it drains per minute
var hunger_bar: float = 100.0  # Starts at full
var hunger_drain_rate: float = 0.2  # Amount it drains per minute
# Properties for grades
var grades_bar: float = 100.0  # Starts at full
var grades_loss_per_missed_class: float = 15.0  # Grade loss for skipping class
var grades_gain_per_class: float = 10.0  # Grade gain for attending class
var class_schedule: Dictionary = {
	#"Sunday": [9], #test class
	"Monday": [10, 14],  # Classes at 10:00 and 14:00 on Monday
	"Wednesday": [9, 15],  # Example schedule
	"Friday": [13]  # Single class on Friday
}
@onready var clock_timer: Timer = $ClockTimer
@onready var clock_label: Label = $VBoxContainer/ClockLabel
@onready var day_label: Label = $VBoxContainer/DayLabel
@onready var date_label: Label = $VBoxContainer/DateLabel
@onready var hunger_progress_bar: ProgressBar = $VBoxContainer2/HungerBar
@onready var sleep_progress_bar: ProgressBar = $VBoxContainer2/SleepBar
@onready var grades_progress_bar: ProgressBar = $VBoxContainer2/GradesBar

func _ready():
	update_bars()

func _process(_delta):
	if Globals.in_game:
		visible = true
		$VBoxContainer/LocationLabel.text = Globals.current_location
		$VBoxContainer/MoneyLabel.text = "$" + String("%.2f" % Globals.player_money)
	else:
		visible = false

func _on_clock_timer_timeout():
	# Increment the time by 1 minute each second
	current_minute += 1
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1

	if current_hour >= 24:
		current_hour = 0
		#current_day_index = (current_day_index + 1) % days_of_week.size()
		advance_day()

	update_clock_display()
	update_date_display()
	sleep_bar -= sleep_drain_rate
	sleep_bar = clamp(sleep_bar, 0, 100)
	hunger_bar -= hunger_drain_rate
	hunger_bar = clamp(hunger_bar, 0, 100)
	update_bars()
	
	if current_hour in class_schedule.get(get_current_day(), []) and current_minute == 0:
		if Globals.at_class:
			attend_class()
		else:
			miss_class()
	if current_hour == 9 and current_minute == 0:
		check_for_deliveries()

func check_for_deliveries():
	var delivery_today = false
	for delivery in Globals.delivery_queue:
		if delivery["delivery_day"] == current_day and delivery["delivery_month"] == current_month and delivery["delivery_year"] == current_year:
			Globals.mailbox_items.append(delivery["items"])  # Add items to the mailbox
			print("Package:", Globals.mailbox_items)
			delivery_today = true
	
	# Remove today's deliveries from the delivery queue
	if delivery_today:
		var new_delivery_queue = []
		for d in Globals.delivery_queue:
			if not (d["delivery_day"] == current_day and d["delivery_month"] == current_month and d["delivery_year"] == current_year):
				new_delivery_queue.append(d)
		Globals.delivery_queue = new_delivery_queue
		print("Mail has arrived!")
	print("All Mailbox items:", Globals.mailbox_items)

func get_current_day() -> String:
	return days_of_week[current_day_index]

func advance_day():
	current_day += 1

	# Check if the current day exceeds the number of days in the month
	if current_day > days_in_months[current_month - 1]:
		current_day = 1  # Reset to the first day of the month
		current_month += 1  # Move to the next month

		# Check if the month exceeds December
		if current_month > 12:
			current_month = 1  # Reset to January
			current_year += 1  # Move to the next year

	# Update day of the week index (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
	current_day_index = (current_day_index + 1) % 7

func hide_ui():
	$Panel.visible = false
	$VBoxContainer.visible = false
	$VBoxContainer2.visible = false
	$CarryWeightLabel.visible = false

func show_ui():
	$Panel.visible = true
	$VBoxContainer.visible = true
	$VBoxContainer2.visible = true
	$CarryWeightLabel.visible = true

func hide_bars():
	$VBoxContainer2.visible = false

func show_bars():
	$VBoxContainer2.visible = true

func hide_screen_fade():
	$ScreenFade.visible = false

func show_screen_fade():
	$ScreenFade.visible = true

func eat_food(amount: float):
	hunger_bar += amount  # Increase hunger bar by the specified amount
	hunger_bar = clamp(hunger_bar, 0, 100)
	update_bars()  # Update progress bars
	print("Ate food, hunger bar refilled to ", hunger_bar)

# Example interaction where the player eats food worth 20 points
# eat_food(20)

func sleep_for_hours(hours: int):
	Globals.is_sleeping = true
	sleep_bar += hours * 12.5  # Refill rate, adjust as needed
	sleep_bar = clamp(sleep_bar, 0, 100)
	skip_time(hours)
	print("Sleep bar refilled to ", sleep_bar)

# Method for attending class to refill grades bar
func attend_class():
	fade_to_black()
	pause_time()
	print("At class")
	await get_tree().create_timer(2.0).timeout
	resume_time()
	grades_bar += grades_gain_per_class + (Globals.player_intelligence * 1.0)  # Intelligence boosts class effect
	grades_bar = clamp(grades_bar, 0, 100)
	skip_time(2)
	Globals.at_class = false
	print("Attended class, grades bar refilled to ", grades_bar)
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")

# Method for missing class
func miss_class():
	grades_bar -= grades_loss_per_missed_class - (Globals.player_intelligence * 0.5)  # Intelligence reduces loss
	grades_bar = clamp(grades_bar, 0, 100)
	update_bars()
	print("Missed class, grades bar reduced to ", grades_bar)

# Update the visual clock label with formatted time (e.g., 8:00 AM, 11:00 PM)
func update_clock_display():
	var am_pm = "AM"
	var display_hour = current_hour
	if current_hour >= 12:
		am_pm = "PM"
	if current_hour == 0:
		display_hour = 12  # Midnight case
	elif current_hour > 12:
		display_hour -= 12
	if display_hour >= 10:
		clock_label.text = "%02d:%02d %s" % [display_hour, current_minute, am_pm] # Double-digit hour formatting
	else:
		clock_label.text = "%01d:%02d %s" % [display_hour, current_minute, am_pm] # Single-digit hour formatting
	day_label.text = days_of_week[current_day_index]

func update_date_display():
	date_label.text = "%02d/%02d/%04d" % [current_month, current_day, current_year]

# Skip time method
func skip_time(hours: int):
	var initial_hour = current_hour
	var initial_minute = current_minute
	var final_hour = (initial_hour + hours) % 24
	var final_minute = current_minute
	var final_day = current_day_index
	# Check if skipping over 9:00 AM
	if (initial_hour < 9 or (initial_hour == 9 and initial_minute == 0)) \
		and (final_hour > 9 or (final_hour == 9 and final_minute >= 0)):
		check_for_deliveries()
	
	if initial_hour + hours >= 24:
		final_day = (current_day_index + 1) % days_of_week.size()

		# Get the day's name for checking the schedule
	var day_name = days_of_week[final_day]

	# Check for each scheduled class in the current (or next) day
	for class_hour in class_schedule.get(day_name, []):
		# Check if the class start time (e.g., class_hour:00) falls between the initial and final times
		if (initial_hour < class_hour or (initial_hour == class_hour and initial_minute < 1)) \
			and (final_hour > class_hour or (final_hour == class_hour and final_minute >= 0)):
			if not Globals.at_class:
				miss_class()  # Apply the missed class penalty
				print("Missed class at:", class_hour)  # Debug output
	current_hour += hours
	if current_hour >= 24:
		@warning_ignore("integer_division")
		var days_to_add = int(current_hour / 24)
		current_hour %= 24
		for day in range(days_to_add):
			advance_day()
	if Globals.is_sleeping:
		var hunger_drain = hours * 60 * (hunger_drain_rate / 4)
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		Globals.is_sleeping = false
		print("Sleeping, reduced hunger drain")
	elif Globals.is_eating:
		var sleep_drain = hours * 60 * sleep_drain_rate
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
	elif Globals.is_exercising:
		var hunger_drain = hours * 60 * (hunger_drain_rate * 2)
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		var sleep_drain = hours * 60 * (sleep_drain_rate * 4)  # Calculate sleep drain over the skipped time
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
		print("Exercising, increased hunger and sleep drain")
	else:
		var hunger_drain = hours * 60 * hunger_drain_rate 
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		var sleep_drain = hours * 60 * sleep_drain_rate  # Calculate sleep drain over the skipped time
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
	update_bars()
	update_clock_display()

func skip_time_minutes(minutes: int):
	var initial_hour = current_hour
	var initial_minute = current_minute
	var total_minutes = initial_minute + minutes
	@warning_ignore("integer_division")
	var final_hour = (initial_hour + int(total_minutes / 60)) % 24
	var final_minute = total_minutes % 60
	var final_day = current_day_index
	# Check if skipping over 9:00 AM
	if (initial_hour < 9 or (initial_hour == 9 and initial_minute == 0)) \
		and (final_hour > 9 or (final_hour == 9 and final_minute >= 0)):
		check_for_deliveries()
	# Handle day overflow if the skip crosses midnight
	if initial_hour * 60 + initial_minute + minutes >= 1440:  # 1440 minutes = 24 hours
		final_day = (current_day_index + 1) % days_of_week.size()
	
	var day_name = days_of_week[final_day]

	# Check for each scheduled class in the current (or next) day
	for class_hour in class_schedule.get(day_name, []):
		# Check if the class start time (e.g., class_hour:00) falls between the initial and final times
		if (initial_hour < class_hour or (initial_hour == class_hour and initial_minute < 1)) \
			and (final_hour > class_hour or (final_hour == class_hour and final_minute >= 0)):
			if not Globals.at_class:
				miss_class()  # Apply the missed class penalty
				print("Missed class at hour ", class_hour)  # Debug output
	current_minute += minutes
	
	# Handle minute overflow to hours
	if current_minute >= 60:
		@warning_ignore("integer_division")
		var additional_hours = int(current_minute / 60)
		current_minute %= 60
		current_hour += additional_hours
	
	# Handle overflow to days
	if current_hour >= 24:
		@warning_ignore("integer_division")
		current_hour %= 24
		advance_day()  # Advance the day
	if Globals.is_sleeping:
		var hunger_drain = minutes * (hunger_drain_rate / 4)
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		Globals.is_sleeping = false
		print("Sleeping, reduced hunger drain")
	elif Globals.is_eating:
		var sleep_drain = minutes * sleep_drain_rate # Calculate sleep drain over the skipped time
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
	elif Globals.is_exercising:
		var hunger_drain = minutes * (hunger_drain_rate * 2)
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		var sleep_drain = minutes * (sleep_drain_rate * 4)  # Calculate sleep drain over the skipped time
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
		print("Exercising, increased hunger and sleep drain")
	else:
		var hunger_drain = minutes * hunger_drain_rate 
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		var sleep_drain = minutes * sleep_drain_rate  # Calculate sleep drain over the skipped time
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
	update_bars()
	update_clock_display()

# Pause time (use when interacting with a computer or tenants)
func pause_time():
	clock_paused = true
	clock_timer.stop()

# Resume time
func resume_time():
	clock_paused = false
	clock_timer.start()

func update_bars():
	hunger_progress_bar.value = hunger_bar
	sleep_progress_bar.value = sleep_bar  # Update the sleep progress bar
	grades_progress_bar.value = grades_bar
	update_carry_weight_display()

func update_carry_weight_display():
	$CarryWeightLabel.text = "Carry Weight: %.2f / %d" % [Globals.current_carry_weight, Globals.max_carry_weight()]

#func _on_button_pressed():
	#skip_time(12)

#func _on_button_2_pressed():
	#if not clock_paused:
		#pause_time()
	#else:
		#resume_time()

func fade_to_black():
	$ScreenFade/FadeAnimation.play("fade_out")

func fade_from_black():
	$ScreenFade/FadeAnimation.play("fade_in")

func play_stairs_audio():
	$StairsAudio.play()

func cpu_fade_to_black():
	$ComputerAudio.pitch_scale = 0.8
	$ComputerAudio.play()
	$ScreenFade/FadeAnimation.play("cpu_fade_out")

func cpu_fade_from_black():
	$ComputerAudio.pitch_scale = 1.0
	$ComputerAudio.play()
	$ScreenFade/FadeAnimation.play("cpu_fade_in")

func cpu_fade_from_black_no_audio():
	$ScreenFade/FadeAnimation.play("cpu_fade_in")
