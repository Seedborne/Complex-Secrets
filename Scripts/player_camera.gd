extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.current_location == "Floor 1" or Globals.current_location == "Floor 2" or Globals.current_location == "Floor 3":
		enabled = true
	else:
		enabled = false
