extends Area2D

@onready var interaction_area:InteractionArea = $InteractionArea

@export var skill_name:String = "skill"

func _ready() -> void:
	interaction_area.interact = Callable(self, "on_interact")

func on_interact():
	var player = get_tree().get_first_node_in_group("Player")
	
	match skill_name:
		"dash":
				player.can_use_ability_dash = true
		"wall_jump":
				player.can_use_ability_wall_jump = true
	$AnimatedSprite2D.play("open")
