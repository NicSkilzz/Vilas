extends CharacterBody2D

var current_state
enum enemy_states {IDLE, MOVE_RIGHT, MOVE_LEFT}

const SPEED:int = 50
const JUMP_VELOCITY:int = -400
const MIN_STATE_DURATION = 2
const RANDOM_STATE_DURATION = 3

var direction = 1
var state:int

func _ready() -> void:
	$skeleton_archer_sprite.play("idle")
	run_random_state_timer()

func _physics_process(delta: float) -> void:
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

	move_and_slide()

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
	velocity.x = SPEED
	direction = 1
	$JumpRay.enabled = true
	$JumpRay.rotation = -90

func move_left():
	$skeleton_archer_sprite.play("walk")
	$skeleton_archer_sprite.flip_h = true
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
