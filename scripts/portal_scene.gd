extends Area2D

@onready var interaction_area:InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "on_interact")
	$AnimatedSprite2D.play("closed")

func on_interact():
	var player = get_tree().get_first_node_in_group("Player")
	$AnimatedSprite2D.play("open")
	await get_tree().create_timer(0.3).timeout
	player.set_position($DestinationPoint.global_position)
	$AnimatedSprite2D.play("closed")
