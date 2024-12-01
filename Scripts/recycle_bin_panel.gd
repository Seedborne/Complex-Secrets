extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_hint_button_pressed():
	$HintPanel.visible = true

func _on_hint_close_button_pressed():
	$HintPanel.visible = false
