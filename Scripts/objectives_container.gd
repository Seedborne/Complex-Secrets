extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func update_objectives_list():
	# Clear old objectives
	for child in get_children():
		if child.name != "ObjectivesLabel":
			child.queue_free()

	# Add objectives dynamically
	for objective in UI.objectives:
		var label = Label.new()
		if objective["completed"]:
			label.text = "[Completed] %s" % objective["text"]
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))  # Gray out completed objectives
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
			label.add_theme_constant_override("outline_size", 6)
			label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
			add_child(label)
			#remove_child(label)
			#objectives = objectives.filter(func(obj): return obj["text"] != objective_text)
		elif objective["failed"]:
			label.text = "[Failed] %s" % objective["text"]
			label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red for failed objectives
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
			label.add_theme_constant_override("outline_size", 6)
			label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
			add_child(label)
		else:
			label.add_theme_color_override("font_color", Color(1, 1, 1))
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
			label.add_theme_constant_override("outline_size", 6)
			label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
			label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
			label.text = objective["text"]
			add_child(label)
