extends CharacterBody2D


const SPEED = 450
const JUMP_VELOCITY = -800.0
const GRAVITY_MULTIPLIER = 4

var double_jump = true

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
	# Resetting double jump flag
	elif is_on_floor():
		double_jump = true

	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Double jump
		elif not is_on_floor() and double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false
		
		

	# Get the input direction and handle the movement/deceleration.
	# < 0 if moving left, > 0 if moving right
	var direction := Input.get_axis("move left", "move right") 
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false 	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
