extends CharacterBody2D

class_name Arrow

enum arrow_states {FLYING, STOPPED}

const SPEED: int = 500

var direction:int
var current_state = arrow_states.FLYING


func _physics_process(delta: float) -> void:
	match current_state: 
		arrow_states.FLYING:
			velocity.x = self.direction * SPEED
			move_and_slide()
			if velocity.x == 0:
				current_state = arrow_states.STOPPED
				set_collision_mask_value(1, false)

func flip():
	$arrow_sprite.flip_h = true
