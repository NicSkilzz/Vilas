extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@export var direction_right = true

func _ready() -> void:
	$slime_sprite.play("walk")
	update_animation()
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Movement
	if direction_right:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED

	move_and_slide()
	
	if is_on_wall():
		if direction_right:
			direction_right = false
		else:
			direction_right = true
	
	update_animation()


func update_animation():
	if direction_right:
		$slime_sprite.flip_h = false
	else:
		$slime_sprite.flip_h = true
