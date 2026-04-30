extends CharacterBody2D

class_name Arrow

enum arrow_states {FLYING, STOPPED}

const SPEED: int = 500

var direction:int
var current_state = arrow_states.FLYING

func _ready() -> void:
	var hitbox = $Hitbox
	if hitbox:
		hitbox.connect("area_entered", _on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	match current_state: 
		arrow_states.FLYING:
			velocity.x = self.direction * SPEED
			move_and_slide()
			if velocity.x == 0:
				current_state = arrow_states.STOPPED
				set_collision_mask_value(1, false)

func _on_hitbox_area_entered(area):
	if area is Hurtbox:
		queue_free()

func flip():
	$arrow_sprite.flip_h = true
