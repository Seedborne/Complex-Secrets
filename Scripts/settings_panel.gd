extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_bgm_button_toggled(toggled_on):
	if toggled_on:
		UI.play_bgm()
		SettingsManager.bgm_on = true
	else:
		UI.stop_bgm()
		SettingsManager.bgm_on = false

func _on_close_button_pressed():
	visible = false

func _on_visibility_changed():
	if SettingsManager.bgm_on:
		$BGMButton.set_pressed(true)
	else:
		$BGMButton.set_pressed(false)
