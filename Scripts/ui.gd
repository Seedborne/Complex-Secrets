extends CanvasLayer

var current_hour: int = 8  # Start the game at 8:00 AM
var current_minute: int = 0
var current_day_index: int = 0  # Index for days of the week (0 = Sunday, 1 = Monday, ...)
var days_of_week: Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
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
var class_checked: bool = false
@onready var clock_timer: Timer = $ClockTimer
@onready var clock_label: Label = $VBoxContainer/ClockLabel
@onready var day_label: Label = $VBoxContainer/DayLabel
@onready var hunger_progress_bar: ProgressBar = $VBoxContainer2/HungerBar
@onready var sleep_progress_bar: ProgressBar = $VBoxContainer2/SleepBar
@onready var grades_progress_bar: ProgressBar = $VBoxContainer2/GradesBar

func _ready():
	update_bars()

func _process(_delta):
	if Globals.in_game:
		visible = true
		$VBoxContainer/LocationLabel.text = Globals.current_location
	else:
		visible = false

func _on_clock_timer_timeout():
	# Increment the time by 1 minute each second
	current_minute += 1
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1
		print(sleep_bar)

	if current_hour >= 24:
		current_hour = 0
		current_day_index = (current_day_index + 1) % days_of_week.size()

	update_clock_display()
	sleep_bar -= sleep_drain_rate
	sleep_bar = clamp(sleep_bar, 0, 100)
	hunger_bar -= hunger_drain_rate
	hunger_bar = clamp(hunger_bar, 0, 100)
	update_bars()
	
	if not class_checked and current_hour in class_schedule.get(get_current_day(), []):
		if Globals.at_class:
			attend_class()
		else:
			miss_class()
		class_checked = true  # Set the flag to prevent repeated checks

func get_current_day() -> String:
	return days_of_week[current_day_index]

func hide_ui():
	$VBoxContainer.visible = false
	$VBoxContainer2.visible = false

func show_ui():
	$VBoxContainer.visible = true
	$VBoxContainer2.visible = true

func eat_food(amount: float):
	hunger_bar += amount  # Increase hunger bar by the specified amount
	hunger_bar = clamp(hunger_bar, 0, 100)
	update_bars()  # Update progress bars
	print("Ate food, hunger bar refilled to ", hunger_bar)

# Example interaction where the player eats food worth 20 points
# eat_food(20)

func sleep_for_hours(hours: int):
	Globals.is_sleeping = true
	sleep_bar += hours * 10  # Refill rate, adjust as needed
	sleep_bar = clamp(sleep_bar, 0, 100)
	skip_time(hours)
	print("Sleep bar refilled to ", sleep_bar)

# Method for attending class to refill grades bar
func attend_class():
	grades_bar += grades_gain_per_class + (Globals.player_intelligence * 0.5)  # Intelligence boosts class effect
	grades_bar = clamp(grades_bar, 0, 100)
	skip_time(2)
	print("Attended class, grades bar refilled to ", grades_bar)

# Method for missing class
func miss_class():
	grades_bar -= grades_loss_per_missed_class - (Globals.player_intelligence * 0.2)  # Intelligence reduces loss
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

# Skip time method
func skip_time(hours: int):
	current_hour += hours
	if current_hour >= 24:
		@warning_ignore("integer_division")
		var days_to_add = int(current_hour / 24)
		current_day_index = (current_day_index + days_to_add) % days_of_week.size()
		current_hour %= 24
	# Drain sleep bar if not sleeping
	if not Globals.is_sleeping:
		var sleep_drain = hours * 60 * sleep_drain_rate  # Calculate sleep drain over the skipped time
		sleep_bar -= sleep_drain
		sleep_bar = clamp(sleep_bar, 0, 100)
	else:
		var hunger_drain = hours * 60 * (hunger_drain_rate / 2)
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
		Globals.is_sleeping = false
	if not Globals.is_eating and not Globals.is_sleeping:
		var hunger_drain = hours * 60 * hunger_drain_rate 
		hunger_bar -= hunger_drain
		hunger_bar = clamp(hunger_bar, 0, 100)
	elif Globals.is_eating:
		Globals.is_eating = false
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
