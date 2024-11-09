extends CharacterBody2D

var can_move = true

func _physics_process(_delta):
	if can_move:
		var input_vector = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			velocity = input_vector * Globals.player_speed
		else:
			velocity.x = move_toward(velocity.x, 0, Globals.player_speed)
			velocity.y = move_toward(velocity.y, 0, Globals.player_speed)
		move_and_slide()
