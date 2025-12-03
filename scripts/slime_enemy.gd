extends CharacterBody2D

@onready var animation_player := $AnimationPlayer

const SPEED : float = 100.0
const JUMP_VELOCITY : float = -400.0
var current_speed: float
var knockback_force = 500

@export var direction_right = true

func _ready() -> void:
	current_speed = SPEED
	$slime_sprite.connect("animation_finished", _on_animation_finished)
	$slime_sprite.play("walk")
	update_animation()
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Movement
	if direction_right:
		velocity.x = current_speed
	else:
		velocity.x = -current_speed

	move_and_slide()
	
	if is_on_wall():
		if direction_right:
			direction_right = false
		else:
			direction_right = true
	
	update_animation()

# Incase doing something when hurt
func _on_animation_finished() -> void:
	if $slime_sprite.animation == "hurt":
		pass

# Damage handling
func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	$slime_sprite.play("hurt")
	# Applying knockback (Not working just yet)
	if knockback_direction != Vector2.ZERO:
		velocity = knockback_direction * knockback_force
	# Reduce speed when taking damage
	current_speed *= 0.5
	await get_tree().create_timer(0.5).timeout
	current_speed = SPEED
		
	$slime_sprite.sprite_frames.set_animation_loop("hurt", false)
	
	print("Damage: ", amount)

func update_animation():
	if direction_right:
		$slime_sprite.flip_h = false
	else:
		$slime_sprite.flip_h = true
