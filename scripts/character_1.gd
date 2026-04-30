extends CharacterBody2D

@onready var animation_player := $AnimationPlayer
@onready var health_component = $Health

const SPEED : float = 200.0
const JUMP_VELOCITY : float = -500.0
const GRAVITY_MULTIPLIER : float = 2.0
const DASH : float = 850.0

var immortality_duration : float = 1.0

var hearts_list : Array [TextureRect]
var knockback_force: int = 200

var can_use_ability_dash : bool = false
var can_use_ability_wall_jump : bool = false
var can_use_ability_slowmo : bool = false

var double_jump : bool = true
var attacking : bool = false
var dashing : bool = false
var is_ready_dash : bool = true
var is_ready_slowmo : bool = true
var is_hurt : bool = false
var can_attack : bool = true
var is_dead: bool = false

func _ready() -> void:
	$blue_guy_sprite/Hurtbox.collision_layer = 0
	$blue_guy_sprite/Hurtbox.collision_mask = 2
	$blue_guy_sprite/Hitbox.collision_layer = 8
	$blue_guy_sprite/Hitbox.collision_mask = 0
	
	$blue_guy_sprite/Hitbox.set_active_frame(3, 4)
	
	var hearts_parent = $"Health Bar/HBoxContainer"
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	#print(hearts_list)
	health_component.health_depleted.connect(_on_health_depleted)
	
	$blue_guy_sprite.animation_finished.connect(_on_blue_guy_sprite_animation_finished)
	$HurtTimer.timeout.connect(_on_hurt_timer_timeout)
	$HurtTimer.wait_time = 0.3
	
	#print($blue_guy_sprite/Hurtbox.get_signal_connection_list("area_entered"))

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# Gravity
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
	# Resetting double jump flag
	elif is_on_floor():
		double_jump = true

	# Get the input direction and handle the movement/deceleration.
	# < 0 if moving left, > 0 if moving right
	var direction := Input.get_axis("move left", "move right") 
	if not dashing and not attacking and not is_hurt:
		if direction < 0:
			$blue_guy_sprite.flip_h = true
		elif direction > 0:
			$blue_guy_sprite.flip_h = false
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif is_hurt:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Double jump
		elif can_use_ability_wall_jump and is_on_wall_only() and (Input.is_action_pressed("move left") or Input.is_action_pressed("move right")):
			velocity.y = JUMP_VELOCITY
			$blue_guy_sprite.frame = 0
		elif not is_on_floor() and double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false
			$blue_guy_sprite.frame = 0
	
	# Attack
	if Input.is_action_just_pressed("attack") and not dashing and can_attack:
		attacking = true
		velocity.x = 0
		$blue_guy_sprite.play("attack")
		print("attack")
	
	if can_use_ability_dash:
		if Input.is_action_just_pressed("dash") and is_ready_dash and not attacking:
			dashing = true
			is_ready_dash = false
			velocity.y = 0
			if $blue_guy_sprite.flip_h:
				velocity.x = (-1) * DASH
			else:
				velocity.x = DASH
			$blue_guy_sprite.play("dash")
			
	if can_use_ability_slowmo and is_ready_slowmo:
		if Input.is_action_just_pressed("slowmo"):
			$"../SlowmoController".start_slowmo()
			
	update_animation()
	move_and_slide()

func take_damage(knockback_direction: Vector2 = Vector2.ZERO) -> void:
	print("take_damage called, is_hurt: ", is_hurt, " direction: ", knockback_direction)
	print(get_stack())  # ← this shows exactly what called take_damage
	if is_hurt:
		return
	is_hurt = true
	$blue_guy_sprite/Hurtbox.set_deferred("monitoring", false)
	if knockback_direction != Vector2.ZERO:
		velocity = knockback_direction * knockback_force
	health_component.set_health(health_component.get_health() - 1)
	update_heart_display()
	if health_component.get_health() > 0:
		is_hurt = true
		$blue_guy_sprite.play("hurt")
		$HurtTimer.start()
		health_component.set_temp_immortality(immortality_duration)
		

func update_animation():
	if not attacking and not dashing and not is_hurt:
		if is_on_floor():
			if velocity.x == 0:
				$blue_guy_sprite.play("idle")
			elif velocity.x < 0:
				$blue_guy_sprite.play("run")
			elif velocity.x > 0:
				$blue_guy_sprite.play("run")
		if velocity.y < 0:
			$blue_guy_sprite.play("jump")

		
func update_heart_display() -> void:
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health_component.get_health()
		print(i < health_component.get_health())
		

func _on_blue_guy_sprite_animation_finished() -> void:
	if $blue_guy_sprite.animation == 'hurt':
		is_hurt = false
	if $blue_guy_sprite.animation == "death": # For restarting or quitting the game after death
		pass
	if $blue_guy_sprite.animation == "attack":
		attacking = false
	if $blue_guy_sprite.animation == "dash":
		velocity.x = 0
		$Timer.start()
		dashing = false


func _on_timer_timeout() -> void:
	is_ready_dash = true

func _on_health_depleted():
	die()
	
func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	$blue_guy_sprite/Hurtbox.set_deferred("monitoring", true)

func die():
	is_dead = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	$blue_guy_sprite/Hurtbox.set_deferred("monitoring", false)
	$blue_guy_sprite/Hurtbox.set_deferred("monitorable", false)
	
	$blue_guy_sprite/Hitbox.set_deferred("monitorable", false)
	$blue_guy_sprite/Hitbox.set_deferred("monitoring", false)
	
	$blue_guy_sprite.play("death")
	$CollisionShape2D.disabled = true
	
	await $blue_guy_sprite.animation_finished
