extends Panel

@onready var achievements_container = $VBoxContainer

func _ready():
	# Populate the achievements panel when the scene is ready
	update_achievements_list()

func update_achievements_list():
	# Clear any existing entries in the container
	for child in achievements_container.get_children():
		child.queue_free() #clear old buttons

	# Iterate over all achievements and display them
	for achievement_key in Achievements.achievements.keys():
		var achievement_data = Achievements.achievements[achievement_key]

		# Create a new Label for each achievement
		var achievement_label = Label.new()

		if achievement_data["unlocked"]:
			achievement_label.text = achievement_data["name"]  # Show the name for unlocked achievements
			achievement_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green for unlocked
		else:
			achievement_label.text = "Locked"  # Replace locked achievements with "Locked"
			achievement_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))  # Gray for locked

		# Customize the font size
		achievement_label.add_theme_font_size_override("font_size", 32)
		achievement_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)

		# Add the label to the VBoxContainer
		achievements_container.add_child(achievement_label)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			visible = false

func _on_close_button_pressed():
	if visible:
			visible = false

func _on_reset_achievement_button_pressed():
	Achievements.delete_achievements_data()
	Achievements.reset_achievements()
	update_achievements_list()
