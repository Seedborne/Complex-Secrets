extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_cart_button_pressed():
	$CartPanel.visible = true

func _on_close_cart_button_pressed():
	$CartPanel.visible = false
