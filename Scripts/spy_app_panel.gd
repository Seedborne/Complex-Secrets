extends Panel

func _ready():
	populate_missions()

# Populate the VBoxContainer with mission details
func populate_missions():
	var missions_container = $MissionsContainer
	for child in missions_container.get_children():
		child.queue_free()

	for mission in MissionsManager.missions:
		if mission["status"] == "available" or mission["status"] == "accepted":
			var mission_box = VBoxContainer.new()

			# Mission Title
			var title_label = Label.new()
			title_label.text = mission["title"]
			title_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
			title_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			title_label.add_theme_color_override("font_color", Color(0, 0, 0))
			mission_box.add_child(title_label)

			# Tasks
			var tasks_label = Label.new()
			tasks_label.text = "Tasks:\n - " + String("\n - ").join(mission["tasks"])
			tasks_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
			tasks_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			tasks_label.add_theme_color_override("font_color", Color(0, 0, 0))
			mission_box.add_child(tasks_label)

			# Payout
			var payout_label = Label.new()
			payout_label.text = "Payout: $%d" % mission["payout"]
			payout_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			payout_label.add_theme_color_override("font_color", Color(0, 0, 0))
			mission_box.add_child(payout_label)

			# Expiration Date
			var expiration_label = Label.new()
			expiration_label.text = "Expires: %d/%d/%d" % [
				mission["expiration_date"]["month"],
				mission["expiration_date"]["day"],
				mission["expiration_date"]["year"]
			]
			expiration_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			expiration_label.add_theme_color_override("font_color", Color(0, 0, 0))
			mission_box.add_child(expiration_label)

			# Buttons
			if mission["status"] == "available":
				# Accept Button
				var accept_button = Button.new()
				accept_button.text = "Accept"
				accept_button.connect("pressed", Callable(self, "_on_accept_mission").bind(mission["id"]))
				mission_box.add_child(accept_button)

				# Decline Button
				var decline_button = Button.new()
				decline_button.text = "Decline"
				decline_button.connect("pressed", Callable(self, "_on_decline_mission").bind(mission["id"]))
				mission_box.add_child(decline_button)

			elif mission["status"] == "accepted":
				# Complete Mission Button
				var complete_button = Button.new()
				complete_button.text = "Complete Mission"
				complete_button.name = "complete_button"  # Add a name for lookup
				if mission["all_tasks_completed"]:
					complete_button.disabled = false
				else:
					complete_button.disabled = true  # Initially disabled
				complete_button.connect("pressed", Callable(self, "_on_complete_mission").bind(mission["id"]))
				mission_box.add_child(complete_button)
						
			missions_container.add_child(mission_box)

# Accept Mission
func _on_accept_mission(mission_id):
	for mission in MissionsManager.missions:
		if mission["id"] == mission_id:
			mission["status"] = "accepted"
			for task in mission["tasks"]:
				var objective_text = "%s: %s" % [mission["title"], task]
				UI.add_objective(objective_text)
			break
	populate_missions()

# Decline Mission
func _on_decline_mission(mission_id):
	for mission in MissionsManager.missions:
		if mission["id"] == mission_id:
			mission["status"] = "declined"
			break
	populate_missions()

# Complete Mission
func _on_complete_mission(mission_id):
	for mission in MissionsManager.missions:
		if mission["id"] == mission_id:
			Globals.increase_player_money(mission["payout"])
			mission["status"] = "completed"
			UI.remove_completed_objectives()
			break
	populate_missions()
