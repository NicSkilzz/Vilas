extends Area2D

@onready var interaction_area:InteractionArea = $InteractionArea


func _ready() -> void:
	interaction_area.interact = Callable(self, "on_interact")

func on_interact():
	var player = get_tree().get_first_node_in_group("Player")
	player.can_use_ability_dash = true
	$AnimatedSprite2D.play("open")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.can_use_ability_dash = true
		$AnimatedSprite2D.play("open")
