extends Node

var missions = [
	{
		"id": "an_artistic_inquiry",
		"title": "An Artistic Inquiry",
		"tasks": [
			"Find out what Mateo from 3C has been drawing lately"
		],
		"payout": 50,
		"expiration_date": {"day": 5, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
	{
		"id": "culinary_reconnaissance",
		"title": "Culinary Reconnaissance",
		"tasks": [
			"Find out Elena from 3C's favorite dish"
		],
		"payout": 100,
		"expiration_date": {"day": 7, "month": 9, "year": 2007},
		"status": "available",  # "available", "accepted", "completed", "declined", "failed"
		"all_tasks_completed": false
	},
	{
		"id": "a_scientific_discovery",
		"title": "A Scientific Discovery",
		"tasks": [
			"Find Dr. Cole from 2B's blue binder",
			"Take Dr. Cole’s blue binder",
			"Drop off Dr. Cole’s blue binder at the left potted plant in the lobby"
		],
		"payout": 150,
		"expiration_date": {"day": 9, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
	{
		"id": "a_secret_invasion",
		"title": "A Secret Invasion",
		"tasks": [
			"Find Clara from 1A's diary",
			"Take Clara's diary",
			"Drop off Clara's diary at the left potted plant"
		],
		"payout": 250,
		"expiration_date": {"day": 9, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
	{
		"id": "test_mission",
		"title": "Test Mission",
		"tasks": [
			"Task A",
			"Task B",
		],
		"payout": 50,
		"expiration_date": {"day": 20, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Mark tasks completed dynamically
func mark_task_completed(mission_id: String, task_text: String):
	for mission in missions:
		if mission["id"] == mission_id:
			# Mark the specific task as completed
			for i in range(mission["tasks"].size()):
				if mission["tasks"][i] == task_text:
					# Mark the specific task as completed
					mission["tasks"][i] = "[X] " + mission["tasks"][i]
					print("Task '%s' marked as complete for mission '%s'" % [task_text, mission_id])
					# Check if all tasks are completed
					var all_tasks_completed = true
					for task in mission["tasks"]:
						var objective_text = "%s: %s" % [mission["title"], task.trim_prefix("[X] ")]
						UI.complete_objective(objective_text)
						if not task.begins_with("[X]"):
							all_tasks_completed = false
							break
					if all_tasks_completed:
						mission["all_tasks_completed"] = true
						#if get_tree().current_scene != null and get_tree().current_scene.has_node("SpyAppPanel"):
					#		var spy_app_panel = get_tree().current_scene.get_node("SpyAppPanel")
					#		var missions_container = get_tree().current_scene.get_node("MissionsContainer")
					#		for child in missions_container.get_children():
					#			if child is VBoxContainer and child.name == mission_id:
					#				var complete_button = child.get_node("complete_button")
					#				complete_button.disabled = false
					#				spy_app_panel.populate_missions()
					#				break
					return
			print("Task '%s' not found in mission '%s'" % [task_text, mission_id])
			return
	print("Mission '%s' not found." % mission_id)

	if get_tree().current_scene != null and get_tree().current_scene.has_node("SpyAppPanel"):
		var spy_app_panel = get_tree().current_scene.get_node("SpyAppPanel")
		spy_app_panel.populate_missions()

func check_mission_expirations():
	for mission in missions:
		if mission["status"] == "available" or mission["status"] == "accepted":
			if is_past_date(mission["expiration_date"]):
				mission["status"] = "failed"
				for task in mission["tasks"]:
					var objective_text = "%s: %s" % [mission["title"], task]
					UI.fail_objective(objective_text)
				if get_tree().current_scene != null and get_tree().current_scene.has_node("SpyAppPanel"):
					var spy_app_panel = get_tree().current_scene.get_node("SpyAppPanel")
					spy_app_panel.populate_missions()
	UI.start_objectives_timer()

func is_past_date(expiration_date):
	return EventsManager.is_datetime_or_later(
		expiration_date["day"], expiration_date["month"], expiration_date["year"], 23, 59
	)

func reset_missions():
	missions = [
	{
		"id": "an_artistic_inquiry",
		"title": "An Artistic Inquiry",
		"tasks": [
			"Find out what Mateo from 3C has been drawing lately"
		],
		"payout": 50,
		"expiration_date": {"day": 5, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
	{
		"id": "culinary_reconnaissance",
		"title": "Culinary Reconnaissance",
		"tasks": [
			"Find out Elena from 3C's favorite dish"
		],
		"payout": 100,
		"expiration_date": {"day": 7, "month": 9, "year": 2007},
		"status": "available",  # "available", "accepted", "completed", "declined", "failed"
		"all_tasks_completed": false
	},
	{
		"id": "a_scientific_discovery",
		"title": "A Scientific Discovery",
		"tasks": [
			"Find Dr. Cole from 2B's blue binder",
			"Take Dr. Cole’s blue binder",
			"Drop off Dr. Cole’s blue binder at the left potted plant in the lobby"
		],
		"payout": 150,
		"expiration_date": {"day": 9, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
	{
		"id": "a_secret_invasion",
		"title": "A Secret Invasion",
		"tasks": [
			"Find Clara from 1A's diary",
			"Take Clara's diary",
			"Drop off Clara's diary at the left potted plant"
		],
		"payout": 250,
		"expiration_date": {"day": 9, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
	{
		"id": "test_mission",
		"title": "Test Mission",
		"tasks": [
			"Task A",
			"Task B",
		],
		"payout": 50,
		"expiration_date": {"day": 20, "month": 9, "year": 2007},
		"status": "not_available",
		"all_tasks_completed": false
	},
]
