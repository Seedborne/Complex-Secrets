extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.current_location == "Floor1" or Globals.current_location == "Floor2" or Globals.current_location == "Floor3":
		enabled = true
