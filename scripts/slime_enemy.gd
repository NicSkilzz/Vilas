extends CharacterBody2D

@onready var animation_player := $AnimationPlayer
@onready var health_component = $Health

const SPEED: int = 50
var current_speed: int
var knockback_force: int = 100

var can_target_player: bool = true
var is_attacking: bool = false
var is_hurt: bool = false
@export var direction_right: bool = true

func _ready() -> void:
	$slime_sprite/Hurtbox.collision_layer = 0
	$slime_sprite/Hurtbox.collision_mask = 8
	$slime_sprite/Hitbox.collision_layer = 2
	$slime_sprite/Hitbox.collision_mask = 0
	current_speed = SPEED
	$slime_sprite.connect("animation_finished", _on_animation_finished)
	$slime_sprite.play("walk")
	$HurtTimer.wait_time = 1.0
	$HurtTimer.connect("timeout", _on_hurt_timer_timeout)
	update_animation()
	
	health_component.health_depleted.connect(_on_health_depleted)
	health_component.health_changed.connect(_on_health_changed)
	$slime_sprite/Hitbox.set_active_frame(6, 9)
	
func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		can_target_player = false
	# Handle Movement
	if not is_attacking and not is_hurt:
		if direction_right:
			velocity.x = current_speed
			$slime_sprite/Ray_Detect_Player.target_position = Vector2(40, 0)
		else:
			velocity.x = -current_speed
			$slime_sprite/Ray_Detect_Player.target_position = Vector2(-40, 0)
	
	move_and_slide()

	if can_target_player and $slime_sprite/Ray_Detect_Player.is_colliding():
		velocity.x = 0
		$slime_sprite.play("attack")
		can_target_player = false
		is_attacking = true
	
	if not can_target_player and $CanAttackTimer.time_left == 0:
		$CanAttackTimer.start()
		
	if is_on_wall():
		if direction_right:
			direction_right = false
		else:
			direction_right = true
			
	update_animation()

# Incase doing something when hurt
func _on_animation_finished() -> void:
	if $slime_sprite.animation == "hurt":
		$slime_sprite.play("walk")
	if $slime_sprite.animation == "attack":
		$slime_sprite.play("walk")
		is_attacking = false
		$CanAttackTimer.start()

# Damage handling
func take_damage(knockback_direction: Vector2 = Vector2.ZERO) -> void:
	# Applying knockback
	if knockback_direction != Vector2.ZERO:
		velocity = knockback_direction * knockback_force
	
	if $slime_sprite.animation == "hurt":
		$slime_sprite.frame = 0
	$slime_sprite.play("hurt")
	is_attacking = false
	is_hurt = true
	
	$HurtTimer.start()
	
# Deal damage
func deal_damage():
	var player = $slime_sprite/Ray_Detect_Player.get_collider()
	if player.has_method("take_damage"):
		player.take_damage()

func _on_health_changed(diff: int):
	if diff < 0:  
		$slime_sprite.play("hurt")

func _on_health_depleted():
	die()

func die():
	$slime_sprite/Hurtbox.set_deferred("monitoring", false)
	$slime_sprite/Hurtbox.set_deferred("monitorable", false)
	
	$slime_sprite/Hitbox.set_deferred("monitoring", false)
	
	$slime_sprite.play("death")
	$CollisionShape2D.disabled = true
	
	await $slime_sprite.animation_finished
	queue_free()

func update_animation():
	if direction_right:
		$slime_sprite.flip_h = false
	else:
		$slime_sprite.flip_h = true

func _on_can_attack_timer_timeout() -> void:
	can_target_player = true

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
