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
		
	var health_component = owner.get_node_or_null("Health")
	if health_component:
		health_component.health -= 1
	
	if owner.has_method("take_damage"):
		var knockback_direction = (global_position - hitbox.global_position).normalized()
		owner.take_damage(knockback_direction)
