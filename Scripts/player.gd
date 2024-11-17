extends CharacterBody2D

var can_move = true
var passing_out = false
@onready var animated_sprite = $PlayerSprite

func _physics_process(_delta):
	if can_move:
		var input_vector = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			velocity = input_vector * Globals.player_speed
			animated_sprite.speed_scale = Globals.player_speed / 50.0
			if abs(input_vector.x) > 0:  # Moving sideways
				animated_sprite.flip_h = input_vector.x < 0
				animated_sprite.animation = "walk_side"
			elif input_vector.y < 0:  # Moving up
				animated_sprite.animation = "walk_up"
			else:  # Moving down
				animated_sprite.animation = "walk_down" 
			animated_sprite.play()
		else:
			# Handle idle animations based on last direction
			animated_sprite.speed_scale = 1.0  # Reset to default speed
			if animated_sprite.animation == "walk_side":
				animated_sprite.animation = "idle_side"
			elif animated_sprite.animation == "walk_up":
				animated_sprite.animation = "idle_up"
			elif animated_sprite.animation == "walk_down":
				animated_sprite.animation = "idle_down"
			animated_sprite.play()
			velocity.x = move_toward(velocity.x, 0, Globals.player_speed)
			velocity.y = move_toward(velocity.y, 0, Globals.player_speed)
		move_and_slide()

func _process(_delta):
	if UI.sleep_bar <= 0.9 and not passing_out:
		passing_out = true
		pass_out()

func pass_out():
	print("Passing out")
	can_move = false
	await Globals.create_tracked_timer(0.5).timeout
	UI.pause_time()
	UI.fade_to_black()
	await Globals.create_tracked_timer(5.0).timeout
	UI.resume_time()
	UI.sleep_for_hours(12)
	UI.fade_from_black()
	can_move = true
	passing_out = false
