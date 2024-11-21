extends Panel

# Tracks currently selected email
var selected_email = null

func _ready():
	update_email_list()

# Populate the email list
func update_email_list():
	var email_list = $VBoxContainer
	for child in email_list.get_children():
		child.queue_free() #clear old buttons
		
	for email in EventsManager.emails:
		if email["sent"]:  # Only display triggered emails
			var email_button = Button.new()
			if email["read"]:
				email_button.text = email["subject"]
				email_button.add_theme_constant_override("outline_size", 0)
				email_button.connect("pressed", Callable(self, "_on_email_button_pressed").bind(email))
				email_list.add_child(email_button)
			else:
				email_button.text = (email["subject"] + " - UNREAD")
				email_button.add_theme_constant_override("outline_size", 2)
				email_button.add_theme_color_override("font_outline_color", Color(0.82, 0.82, 0.82))
				email_button.connect("pressed", Callable(self, "_on_email_button_pressed").bind(email))
				email_list.add_child(email_button)

# Handle email selection
func _on_email_button_pressed(email):
	selected_email = email
	display_email(email)

# Display email content
func display_email(email):
	var rich_text_label = $RichTextLabel  # Adjust the path if necessary
	rich_text_label.clear()  # Clears any existing content

	# Use push_text() to dynamically add content
	rich_text_label.append_text("[b]From:[/b] %s\n" % email["sender"])
	rich_text_label.append_text("[b]Subject:[/b] %s\n\n" % email["subject"])
	rich_text_label.append_text(email["content"])
	if not email["read"]:
		email["read"] = true  # Mark the email as read
		var computer = get_parent()
		computer.check_unread_emails()
		if email["id"] == "apartment_email_1":
			Globals.schedule_keys_delivery()
	update_email_list()
