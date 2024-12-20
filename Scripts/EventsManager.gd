extends Node

var weekly_rent = 125.0  # Rent amount
var late_fee = 25.0  # Late fee for overdue rent
var rent_due_day_index = 1  # Monday (0 = Sunday, 1 = Monday, etc.)
var rent_due_time = {"hour": 23, "minute": 59}  # End of Monday
var rent_balance = 0.0  # Total rent owed
var eviction_warning_sent = false  # Track if warning email is sent

var events = [
	{
		"name": "college_email",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 10,
		"callback": "trigger_email_event"
	},
	{
		"name": "apartment_email_1",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 20,
		"callback": "trigger_email_event"
	},
	{
		"name": "work_email",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 30,
		"callback": "trigger_email_event"
	},
	{
		"name": "spy_email_1",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 12,
		"minute": 00,
		"callback": "trigger_email_event"
	},
	{
		"name": "story_event",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 03,
		"hour": 10,
		"minute": 30,
		"callback": "trigger_story_event"
	}
	# Add more events here...
]
# Called when the node enters the scene tree for the first time.

var emails = [
	{
	"id": "eviction_warning",
	"sender": "admin@indigoridgeapartments.com",
	"subject": "Eviction Warning",
	"content": "Dear Resident,
	
	Your rent payment is overdue. A late fee of $25 has been added to your balance. If your overdue balance is not paid in full by EOD next Monday, you will face eviction.
	
	Please make your payment immediately via the online portal to avoid further consequences.",
	"read": false,
	"sent": false
	},
	{
		"id": "spy_email_1",
		"sender": "admin@lndigoridgeapartments.com",
		"subject": "Easy Gig Work Opportunity!",
		"content": "Hello again, new resident of Unit 3F!

We are just following up to inform you about some lucrative gig work available within the building. We know times are tough and we want you to have every opportunity to be successful here.

You will be assigned simple tasks to complete involving other members of our community, with a generous payout accompanying each task! Get paid to simply get to know and anonymously help out your neighbors :) 

The AnonHelp app is being automatically downloaded onto your computer now! You will also notice a new 'Tools' section in Bookazon. Check it out to get started making money!
",
		"read": false,
		"sent": false
	},
	{
		"id": "work_email",
		"sender": "noreply@storedash.com",
		"subject": "Onboarding Complete",
		"content": "Congratulations, you have successfully been onboarded as a bike courier with StoreDash 24HR Food Delivery Service. You can start accepting and completing deliveries at any time. (Do deliveries or go to class by approaching the apartment complex entrance)
",
		"read": false,
		"sent": false
	},
	{
		"id": "apartment_email_1",
		"sender": "admin@indigoridgeapartments.com",
		"subject": "Welcome to the building!",
		"content": "Welcome to the building! We’re thrilled to have you as our newest resident! 

What you need to know:

- Your unit is Unit 3F, it is a single bedroom unit.

- The coffee shop connected to the lobby is open 7 days a week from 6AM to 2PM

- The gym connected to the lobby is open to residents 24/7. Please check your mailbox in the lobby to collect your gym key fob.

- Mail is delivered at 9AM every day except for Sundays.

- Rent is $125/week and is due by EOD each Monday. Your first week was covered by the deposit, so your rent payments will begin next week on Monday, September 10th.

- Rent must be paid through our online payment portal, the payment portal app is being automatically installed on your computer now.

- If you fall behind on rent you will be served an eviction notice. If you fall more than one week behind on rent you will be evicted immediately.
",
		"read": false,
		"sent": false
	},
	{
		"id": "college_email",
		"sender": "admissions@cmu.com",
		"subject": "New Student Information",
		"content": "Congratulations on your admission! You have been admitted on a scholarship so there are no payments required. Your class schedule is provided below. Your first class is on Monday, September 3rd. 

Semester 1 Class Schedule: 

	Monday: 
		- 10:00 AM - Biology 
		- 2:00 PM - Spanish
	Wednesday:
		- 9:00 AM - History of Music
		- 3:00 PM - Chemistry
	Friday: 
		- 1:00 PM - Chemistry Lab

Be aware that it is your responsibility to know when your classes are and to attend accordingly, you will not be reminded. If your grades fall below passing level you will lose your scholarship and be removed from the program with no warning.",
		"read": false,  # Track whether the email has been read
		"sent": false  # For tracking event-related emails
	},
	
	# Add more emails here...
]

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for event in events:
		if not event["triggered"] and is_datetime_or_later(
			event["day"],
			event["month"],
			event["year"],
			event["hour"],
			event["minute"]
		):
			# Call the specified callback function dynamically
			if has_method(event["callback"]):
				call(event["callback"], event["name"])
				event["triggered"] = true  # Mark the event as triggered
			else:
				print("Error: Callback '%s' not found!" % event["callback"])

func is_datetime_or_later(target_day: int, target_month: int, target_year: int, target_hour: int = 0, target_minute: int = 0) -> bool:
	if UI.current_year > target_year:
		return true
	elif UI.current_year == target_year:
		if UI.current_month > target_month:
			return true
		elif UI.current_month == target_month:
			if UI.current_day > target_day:
				return true
			elif UI.current_day == target_day:
				# Compare time if the date matches
				if UI.current_hour > target_hour:
					return true
				elif UI.current_hour == target_hour:
					if UI.current_minute >= target_minute:
						return true
	return false

func check_and_trigger_events():
	for event in events:
		if not event["triggered"]:
			if is_datetime_or_later(event["day"], event["month"], event["year"], event["hour"], event["minute"]):
				call(event["callback"])
				event["triggered"] = true  # Mark as triggered

func trigger_email_event(event_name):
	for email in emails:
		if email["id"] == event_name:  # Match the email ID with the event name
			email["sent"] = true
			UI.show_notification("New email recieved")
			print("New email received: %s" % email["subject"])
			if email["id"] == "college_email":
				UI.add_objective("Use your computer to check your email
(E to interact)")
			if email["id"] == "work_email":
				UI.add_objective("Read new emails")
			if email["id"] == "spy_email_1":
				UI.add_objective("Read new email")
			if get_tree().current_scene != null and get_tree().current_scene.name == "Unit3F":
				get_tree().current_scene.play_email_audio()
			if get_tree().current_scene != null and get_tree().current_scene.name == "Computer":
				get_tree().current_scene.check_unread_emails()
				get_tree().current_scene.play_email_audio()
			if get_tree().current_scene != null and get_tree().current_scene.has_node("ZMailPanel"):
				var zmail_panel = get_tree().current_scene.get_node("ZMailPanel")
				zmail_panel.update_email_list()
			break

func check_all_emails_read():
	# IDs of emails to check for this objective
	var target_emails = ["college_email", "apartment_email_1", "work_email"]

	# Check if all target emails are read
	var all_read = true
	for email in emails:
		if email["id"] in target_emails and not email["read"]:
			all_read = false
			break  # Stop checking if any email isn't read

	# If all emails are read, complete the objective
	if all_read:
		UI.complete_objective("Read new emails")
		UI.remove_completed_objectives()

func trigger_story_event(_event_name): #remove underscore when adding logic
	print("Story event triggered!")
	# Your story logic here

func check_rent_status():
	# Check if rent is overdue
	if UI.current_day_index == 2:
		rent_balance += weekly_rent
		UI.show_notification("New rent bill added")
		if get_tree().current_scene != null and get_tree().current_scene.has_node("RentPortalPanel"):
				var rent_portal_panel = get_tree().current_scene.get_node("RentPortalPanel")
				rent_portal_panel.update_rent_info()
		if rent_balance > weekly_rent:
			# Send eviction notice if not already sent
			if not eviction_warning_sent:
				# Add late fee if rent is overdue
				rent_balance += late_fee
				UI.show_notification("Rent payment overdue")
				print("Rent is overdue! Late fee added. Total owed: $", rent_balance)   
				send_eviction_warning_email()
				eviction_warning_sent = true
			# Check if player is two weeks behind
			else:
				PauseMenu.trigger_eviction()
		# Check if player is two weeks behind
		#if rent_balance > (weekly_rent * 2) + weekly_rent:
			#PauseMenu.trigger_eviction()  # Trigger eviction/game over

func send_eviction_warning_email():
	for email in emails:
		if email["id"] == "eviction_warning":
			email["sent"] = true
			email["read"] = false
			UI.show_notification("New email recieved")
			print("Eviction warning email sent.")
			if get_tree().current_scene != null and get_tree().current_scene.name == "Computer":
				get_tree().current_scene.check_unread_emails()
			if get_tree().current_scene != null and get_tree().current_scene.has_node("ZMailPanel"):
				var zmail_panel = get_tree().current_scene.get_node("ZMailPanel")
				zmail_panel.update_email_list()

func reset_events():
	events = [
	{
		"name": "college_email",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 10,
		"callback": "trigger_email_event"
	},
	{
		"name": "apartment_email_1",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 20,
		"callback": "trigger_email_event"
	},
	{
		"name": "work_email",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 30,
		"callback": "trigger_email_event"
	},
	{
		"name": "spy_email_1",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 12,
		"minute": 00,
		"callback": "trigger_email_event"
	},
	{
		"name": "story_event",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 03,
		"hour": 10,
		"minute": 30,
		"callback": "trigger_story_event"
	}
	# Add more events here...
]
# Called when the node enters the scene tree for the first time.

	emails = [
	{
	"id": "eviction_warning",
	"sender": "admin@indigoridgeapartments.com",
	"subject": "Eviction Warning",
	"content": "Dear Resident,
	
	Your rent payment is overdue. A late fee of $25 has been added to your balance. If your overdue balance is not paid in full by EOD next Monday, you will face eviction.
	
	Please make your payment immediately via the online portal to avoid further consequences.",
	"read": false,
	"sent": false
	},
	{
		"id": "spy_email_1",
		"sender": "admin@lndigoridgeapartments.com",
		"subject": "Easy Gig Work Opportunity!",
		"content": "Hello again, new resident of Unit 3F!

We are just following up to inform you about some lucrative gig work available within the building. We know times are tough and we want you to have every opportunity to be successful here.

You will be assigned simple tasks to complete involving other members of our community, with a generous payout accompanying each task! Get paid to simply get to know and anonymously help out your neighbors :) 

The AnonHelp app is being automatically downloaded onto your computer now! You will also notice a new 'Tools' section in Bookazon. Check it out to get started making money!
",
		"read": false,
		"sent": false
	},
	{
		"id": "work_email",
		"sender": "noreply@storedash.com",
		"subject": "Onboarding Complete",
		"content": "Congratulations, you have successfully been onboarded as a bike courier with StoreDash 24HR Food Delivery Service. You can start accepting and completing deliveries at any time. (Do deliveries or go to class by approaching the apartment complex entrance)
",
		"read": false,
		"sent": false
	},
	{
		"id": "apartment_email_1",
		"sender": "admin@indigoridgeapartments.com",
		"subject": "Welcome to the building!",
		"content": "Welcome to the building! We’re thrilled to have you as our newest resident! 

What you need to know:

- Your unit is Unit 3F, it is a single bedroom unit.

- The coffee shop connected to the lobby is open 7 days a week from 6AM to 2PM

- The gym connected to the lobby is open to residents 24/7. Please check your mailbox in the lobby to collect your gym key fob.

- Mail is delivered at 9AM every day except for Sundays.

- Rent is $125/week and is due by EOD each Monday. Your first week was covered by the deposit, so your rent payments will begin next week on Monday, September 10th.

- Rent must be paid through our online payment portal, the payment portal app is being automatically installed on your computer now.

- If you fall behind on rent you will be served an eviction notice. If you fall more than one week behind on rent you will be evicted immediately.
",
		"read": false,
		"sent": false
	},
	{
		"id": "college_email",
		"sender": "admissions@cmu.com",
		"subject": "New Student Information",
		"content": "Congratulations on your admission! You have been admitted on a scholarship so there are no payments required. Your class schedule is provided below. Your first class is on Monday, September 3rd. 

Semester 1 Class Schedule: 

	Monday: 
		- 10:00 AM - Biology 
		- 2:00 PM - Spanish
	Wednesday:
		- 9:00 AM - History of Music
		- 3:00 PM - Chemistry
	Friday: 
		- 1:00 PM - Chemistry Lab

Be aware that it is your responsibility to know when your classes are and to attend accordingly, you will not be reminded. If your grades fall below passing level you will lose your scholarship and be removed from the program with no warning.",
		"read": false,  # Track whether the email has been read
		"sent": false  # For tracking event-related emails
	},
	
	# Add more emails here...
]
