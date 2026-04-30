class_name Hurtbox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2
	
func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	if not hitbox.register_hit(self):  # only proceed if not already hit
		return
	
	if owner.has_method("take_damage"):
		var knockback_direction = (global_position - hitbox.global_position).normalized()
		owner.take_damage(knockback_direction)
