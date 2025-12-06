extends CharacterBody2D

@onready var animation_player := $AnimationPlayer

const SPEED = 200
const JUMP_VELOCITY = -500.0
const GRAVITY_MULTIPLIER = 2
const DASH = 850

var can_use_ability_dash = false
var can_use_ability_wall_jump = false
var can_use_ability_slowmo = false

var double_jump = true
var attacking = false
var dashing = false
var is_ready_dash = true
var is_ready_slowmo = true

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
	# Resetting double jump flag
	elif is_on_floor():
		double_jump = true

	# Get the input direction and handle the movement/deceleration.
	# < 0 if moving left, > 0 if moving right
	var direction := Input.get_axis("move left", "move right") 
	if not dashing and not attacking:
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
		elif can_use_ability_wall_jump and is_on_wall_only() and (Input.is_action_pressed("move left") or Input.is_action_pressed("move right")):
			velocity.y = JUMP_VELOCITY
			$blue_guy_sprite.frame = 0
		elif not is_on_floor() and double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false
			$blue_guy_sprite.frame = 0
	
	# Attack
	if Input.is_action_just_pressed("attack") and not dashing:
		attacking = true
		velocity.x = 0
		$blue_guy_sprite.play("attack")
		animation_player.play("Pierce")
	
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

func update_animation():
	if not attacking and not dashing:
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
	elif $blue_guy_sprite.animation == "dash":
		velocity.x = 0
		$Timer.start()
		dashing = false


func _on_timer_timeout() -> void:
	is_ready_dash = true
