extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$VBoxContainer/AccountBalanceLabel.text = "Account Balance... $" + String("%.2f" % Globals.player_money)
