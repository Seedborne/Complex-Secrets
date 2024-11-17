extends Node

var events = [
	{
		"name": "college_email",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 05,
		"callback": "trigger_email_event"
	},
	{
		"name": "work_email",
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
		"minute": 15,
		"callback": "trigger_email_event"
	},
	{
		"name": "spy_email_1",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 03,
		"hour": 2,
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
		"id": "spy_email_1",
		"sender": "admin@lndigoridgeapartments.com",
		"subject": "Easy Work Opportunity!",
		"content": "Hello again, new resident of Unit 3F!

We are just following up to inform you about some lucrative work available within the building. We know times are tough and we want you to have every opportunity to be successful here.

You will be assigned simple tasks to complete involving other members of our community, with a generous payout accompanying each task! Get paid to simply get to know and help out your neighbors :) 

The AnonHelp app is being automatically downloaded onto your computer now! Check it out to get started making money!
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
		"id": "work_email",
		"sender": "noreply@storedash.com",
		"subject": "Onboarding Complete",
		"content": "Congratulations, you have successfully been onboarded as a bike courier with StoreDash 24HR Food Delivery Service. You can start accepting and completing deliveries at any time.
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

Be aware that this is not high school and there will be no hand-holding. It is your responsibility to know when your classes are and to attend accordingly, you will not be reminded. If your grades fall below passing level you will lose your scholarship and be removed from the program with no warning.",
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
			print("New email received: %s" % email["subject"])
			if get_tree().current_scene != null and get_tree().current_scene.name == "Computer":
				get_tree().current_scene.check_unread_emails()
			if get_tree().current_scene != null and get_tree().current_scene.has_node("ZMailPanel"):
				var zmail_panel = get_tree().current_scene.get_node("ZMailPanel")
				zmail_panel.update_email_list()
			break

func trigger_story_event(_event_name): #remove underscore when adding logic
	print("Story event triggered!")
	# Your story logic here

func reset_events():
	events = [
	{
		"name": "college_email",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 02,
		"hour": 8,
		"minute": 05,
		"callback": "trigger_email_event"
	},
	{
		"name": "work_email",
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
		"minute": 15,
		"callback": "trigger_email_event"
	},
	{
		"name": "spy_email_1",
		"triggered": false,
		"year": 2007,
		"month": 09,
		"day": 03,
		"hour": 2,
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
		"id": "spy_email_1",
		"sender": "admin@lndigoridgeapartments.com",
		"subject": "Easy Work Opportunity!",
		"content": "Hello again, new resident of Unit 3F!

We are just following up to inform you about some lucrative work available within the building. We know times are tough and we want you to have every opportunity to be successful here.

You will be assigned simple tasks to complete involving other members of our community, with a generous payout accompanying each task! Get paid to simply get to know and help out your neighbors :) 

The AnonHelp app is being automatically downloaded onto your computer now! Check it out to get started making money!
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
		"id": "work_email",
		"sender": "noreply@storedash.com",
		"subject": "Onboarding Complete",
		"content": "Congratulations, you have successfully been onboarded as a bike courier with StoreDash 24HR Food Delivery Service. You can start accepting and completing deliveries at any time.
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

Be aware that this is not high school and there will be no hand-holding. It is your responsibility to know when your classes are and to attend accordingly, you will not be reminded. If your grades fall below passing level you will lose your scholarship and be removed from the program with no warning.",
		"read": false,  # Track whether the email has been read
		"sent": false  # For tracking event-related emails
	},
	
	# Add more emails here...
]
