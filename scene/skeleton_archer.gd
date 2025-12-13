extends CharacterBody2D

var current_state
enum enemy_states {IDLE, MOVE_RIGHT, MOVE_LEFT, FIGHT, SHOOTING}

const SPEED:int = 50
const JUMP_VELOCITY:int = -400
const MIN_STATE_DURATION:int = 2
const RANDOM_STATE_DURATION:int = 3
const MIN_DIST_PLAYER:int = 150
const MAX_DIST_PLAYER:int = 175

var can_attack:bool = true
var player
var direction = 1
var state:int

func _ready() -> void:
	$skeleton_archer_sprite.play("idle")
	run_random_state_timer()
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if distance_to_player() < 100:
		$JumpRay.enabled = false
	else:
		$JumpRay.enabled = true
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if $JumpRay.is_colliding():
			velocity.y = JUMP_VELOCITY
			velocity.x = direction * 2 * SPEED
	
	match current_state:
		enemy_states.IDLE:
			idle()
		enemy_states.MOVE_RIGHT:
			move_right()
		enemy_states.MOVE_LEFT:
			move_left()
		enemy_states.FIGHT:
			fight_player()

	move_and_slide()

func fight_player():
	$JumpRay.enabled = true
	if distance_to_player() < MIN_DIST_PLAYER:
		if direction_to_player():
			move_right()
		else:
			move_left()
	elif distance_to_player() > MAX_DIST_PLAYER:
		if direction_to_player():
			move_left()
		else:
			move_right()
	else:
		idle()
	
	if $AttackRay1.is_colliding():
		$skeleton_archer_sprite.flip_h = false
		if can_attack:
			shoot_arrow()
			can_attack = false
			$AttackTimer.start()
	elif $AttackRay2.is_colliding():
		$skeleton_archer_sprite.flip_h = true
		if can_attack:
			shoot_arrow()
			can_attack = false
			$AttackTimer.start()

func shoot_arrow():
	current_state = enemy_states.SHOOTING
	velocity.x = 0
	$skeleton_archer_sprite.play("shoot_arrow")

func distance_to_player():
	return abs(self.global_position.x - player.global_position.x)

func direction_to_player():
	return sign(self.global_position.x - player.global_position.x)


func random_state():
	state = randi() % 3
	match state:
		0:
			current_state = enemy_states.IDLE
		1:
			current_state = enemy_states.MOVE_RIGHT
		2:
			current_state = enemy_states.MOVE_LEFT

func move_right():
	$skeleton_archer_sprite.play("walk")
	$skeleton_archer_sprite.flip_h = false
	if current_state == enemy_states.FIGHT:
		velocity.x = 1.5 * SPEED
	else:
		velocity.x = SPEED
	direction = 1
	$JumpRay.enabled = true
	$JumpRay.rotation = -90


func move_left():
	$skeleton_archer_sprite.play("walk")
	$skeleton_archer_sprite.flip_h = true
	if current_state == enemy_states.FIGHT:
		velocity.x = -1.5 * SPEED
	else:
		velocity.x = -SPEED
	direction = -1
	$JumpRay.enabled = true
	$JumpRay.rotation = 90


func idle():
	$skeleton_archer_sprite.play("idle")
	velocity.x = 0
	$JumpRay.enabled = false

func run_random_state_timer():
	var t = (randi() % RANDOM_STATE_DURATION) + MIN_STATE_DURATION
	$StateTimer.start(t)

func _on_state_timer_timeout() -> void:
	random_state()
	run_random_state_timer()

func _on_hostile_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		current_state = enemy_states.FIGHT
		$StateTimer.stop()

func _on_hostile_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		random_state()
		run_random_state_timer()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_skeleton_archer_sprite_animation_finished() -> void:
	if $skeleton_archer_sprite.animation == "shoot_arrow":
		current_state = enemy_states.FIGHT
		
