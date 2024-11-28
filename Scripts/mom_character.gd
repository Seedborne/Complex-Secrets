extends CharacterBody2D

var target_position: Vector2
var target_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var movement_speed: float = 150.0  # Adjust as needed
var arrival_threshold: float = 25.0
var can_move: bool = true
var input_received = false

@onready var animated_sprite = $MomSprite

func _ready():
	pass

func _physics_process(_delta):
	if can_move and target_position:
		# Calculate the direction and move toward the target
		target_direction = (target_position - global_position).normalized()
		velocity = target_direction * movement_speed
		animated_sprite.speed_scale = movement_speed / 50.0
		facing_direction = target_direction
		# Stop if within the arrival threshold
		if global_position.distance_to(target_position) < arrival_threshold:
			velocity = Vector2.ZERO  # Stop movement
			target_direction = Vector2.ZERO  # Idle animation
		
		update_animation()
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func set_target(new_position: Vector2):
	target_position = new_position

func update_animation():
	if velocity.length() > 0:
		# Moving animations
		if target_direction.x > 0 and target_direction.y < 0:  # Diagonal up-right
			animated_sprite.flip_h = false
			animated_sprite.animation = "walk_quarter_up"
		elif target_direction.x < 0 and target_direction.y < 0:  # Diagonal up-left
			animated_sprite.flip_h = true
			animated_sprite.animation = "walk_quarter_up"
		elif target_direction.x > 0 and target_direction.y > 0:  # Diagonal down-right
			animated_sprite.flip_h = false
			animated_sprite.animation = "walk_quarter_down"
		elif target_direction.x < 0 and target_direction.y > 0:  # Diagonal down-left
			animated_sprite.flip_h = true
			animated_sprite.animation = "walk_quarter_down"
		elif abs(target_direction.x) > abs(target_direction.y):  # Predominantly horizontal
			animated_sprite.flip_h = target_direction.x < 0
			animated_sprite.animation = "walk_side"
		elif target_direction.y < 0:  # Up
			animated_sprite.animation = "walk_up"
		else:  # Down
			animated_sprite.animation = "walk_down"
	else:
		# Idle animations based on the last facing direction
		if facing_direction.x > 0 and facing_direction.y < 0:  # Diagonal up-right
			animated_sprite.flip_h = false
			animated_sprite.animation = "idle_quarter_up"
		elif facing_direction.x < 0 and facing_direction.y < 0:  # Diagonal up-left
			animated_sprite.flip_h = true
			animated_sprite.animation = "idle_quarter_up"
		elif facing_direction.x > 0 and facing_direction.y > 0:  # Diagonal down-right
			animated_sprite.flip_h = false
			animated_sprite.animation = "idle_quarter_down"
		elif facing_direction.x < 0 and facing_direction.y > 0:  # Diagonal down-left
			animated_sprite.flip_h = true
			animated_sprite.animation = "idle_quarter_down"
		elif abs(facing_direction.x) > abs(facing_direction.y):  # Predominantly horizontal
			animated_sprite.flip_h = facing_direction.x < 0
			animated_sprite.animation = "idle_side"
		elif facing_direction.y < 0:  # Up
			animated_sprite.animation = "idle_up"
		else:  # Down
			animated_sprite.animation = "idle_down"

	animated_sprite.play()

func mom_intro():
	await Globals.create_tracked_timer(1.0).timeout
	self.set_target(Vector2(960, 900))
	await Globals.create_tracked_timer(1.0).timeout
	$DialogueLabel.text = "..."
	$DialogueLabel.visible = true
	UI.play_dialogue_audio()
	await wait_for_input()
	$DialogueLabel.text = "I still don’t understand why a fully furnished 
	apartment in the city would be only $500/month."
	UI.play_dialogue_audio()
	await wait_for_input()
	$DialogueLabel.text = "I know you looked up the crime statistics and the 
	reviews for this place and it all looked fine but…"
	UI.play_dialogue_audio()
	await wait_for_input()
	$DialogueLabel.text = "I’m sorry honey, I still don’t trust it."
	UI.play_dialogue_audio()
	await wait_for_input()
	$DialogueLabel.visible = false
	if get_tree().current_scene != null and get_tree().current_scene.has_node("Player"):
		var player_node = get_tree().current_scene.get_node("Player")
		#await Globals.create_tracked_timer(0.5).timeout
		player_node.dialogue_label.text = "Mom, we’ve already had this conversation."
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.text = "This is the only apartment I could possibly 
		afford within walking distance of the campus."
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.text = "I did all of the research you wanted. 
		I don’t know what else you want me to do."
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.text = "Don’t you want me to go to college?"
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		#await Globals.create_tracked_timer(0.5).timeout
		$DialogueLabel.text = "Of course I do, you know how proud I 
		am of you for getting that scholarship."
		$DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.text = "It’s just…"
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.text = "I don’t know, I’m sorry, 
		you know how I worry."
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.visible = false
		await Globals.create_tracked_timer(1.0).timeout
		$DialogueLabel.text = "Just be careful, okay?"
		$DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.visible = false
		#await Globals.create_tracked_timer(0.7).timeout
		player_node.dialogue_label.text = "I’m ALWAYS careful! It’ll be FINE!"
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		#await Globals.create_tracked_timer(0.7).timeout
		$DialogueLabel.text = "OKAY!"
		$DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.visible = false
		await Globals.create_tracked_timer(1.5).timeout
		$DialogueLabel.text = "..."
		$DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.text = "*sigh* Okay. I love you sweetie."
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.visible = false
		#await Globals.create_tracked_timer(0.5).timeout
		player_node.dialogue_label.text = "I love you too."
		player_node.dialogue_label.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		player_node.dialogue_label.visible = false
		await Globals.create_tracked_timer(0.8).timeout
		self.set_target(player_node.position)
		await Globals.create_tracked_timer(1.0).timeout
		$DialogueLabel.text = "..."
		$DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await wait_for_input()
		$DialogueLabel.visible = false
		await Globals.create_tracked_timer(0.8).timeout
		$DialogueLabel.text = "*hug*"
		$DialogueLabel.visible = true
		UI.play_dialogue_audio()
		await Globals.create_tracked_timer(1.0).timeout
		$DialogueLabel.visible = false
		self.set_target(Vector2(-1000, 2000))
		await Globals.create_tracked_timer(0.6).timeout
		self.set_target(Vector2(920, 2000))
		await Globals.create_tracked_timer(1.0).timeout
		self.can_move = false
		self.visible = false

func wait_for_input() -> void:
	input_received = false
	while not input_received:
		#await get_tree().idle_frame
		await get_tree().process_frame

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		input_received = true
