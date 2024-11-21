extends CharacterBody2D

var can_move = true
var passing_out = false
var facing_direction: Vector2 = Vector2.DOWN
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
			
			# Update facing direction based on input
			facing_direction = input_vector
		else:
			# Smoothly decelerate the player
			velocity.x = move_toward(velocity.x, 0, Globals.player_speed)
			velocity.y = move_toward(velocity.y, 0, Globals.player_speed)
		
	# Determine animation based on facing direction
	if facing_direction.x > 0 and facing_direction.y < 0:  # Diagonal up-right
		animated_sprite.flip_h = false
		animated_sprite.animation = "walk_quarter_up" if can_move and velocity.length() > 0 else "idle_quarter_up"
	elif facing_direction.x < 0 and facing_direction.y < 0:  # Diagonal up-left
		animated_sprite.flip_h = true
		animated_sprite.animation = "walk_quarter_up" if can_move and velocity.length() > 0 else "idle_quarter_up"
	elif facing_direction.x > 0 and facing_direction.y > 0:  # Diagonal down-right
		animated_sprite.flip_h = false
		animated_sprite.animation = "walk_quarter_down" if can_move and velocity.length() > 0 else "idle_quarter_down"
	elif facing_direction.x < 0 and facing_direction.y > 0:  # Diagonal down-left
		animated_sprite.flip_h = true
		animated_sprite.animation = "walk_quarter_down" if can_move and velocity.length() > 0 else "idle_quarter_down"
	elif abs(facing_direction.x) > abs(facing_direction.y):  # Predominantly horizontal
		animated_sprite.flip_h = facing_direction.x < 0
		animated_sprite.animation = "walk_side" if can_move and velocity.length() > 0 else "idle_side"
	elif facing_direction.y < 0:  # Up
		animated_sprite.animation = "walk_up" if can_move and velocity.length() > 0 else "idle_up"
	else:  # Down
		animated_sprite.animation = "walk_down" if can_move and velocity.length() > 0 else "idle_down"

	animated_sprite.play()
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
