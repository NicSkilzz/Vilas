extends CharacterBody2D


const SPEED = 400
const JUMP_VELOCITY = -600.0
const GRAVITY_MULTIPLIER = 2
const ACCELERATION = 50

var double_jump = true
var attacking = false

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
	# Resetting double jump flag
	elif is_on_floor():
		double_jump = true

	# Get the input direction and handle the movement/deceleration.
	# < 0 if moving left, > 0 if moving right
	var direction := Input.get_axis("move left", "move right") 
	if direction < 0:
		$blue_guy_sprite.flip_h = true
	elif direction > 0:
		$blue_guy_sprite.flip_h = false 	 	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Double jump
		elif not is_on_floor() and double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false
			$blue_guy_sprite.frame = 0
	
	# Attack
	if Input.is_action_just_pressed("attack"):
		attacking = true
		$blue_guy_sprite.play("attack")
		
	update_animation()
	move_and_slide()

func update_animation():
	if not attacking:
		if is_on_floor():
			if velocity.x == 0:
				$blue_guy_sprite.play("idle")
			elif velocity.x < 0:
				$blue_guy_sprite.play("run")
			elif velocity.x > 0:
				$blue_guy_sprite.play("run")
		if velocity.y < 0:
			$blue_guy_sprite.play("jump")


func _on_blue_guy_sprite_animation_finished() -> void:
	if $blue_guy_sprite.animation == "attack":
		attacking = false
