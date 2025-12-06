extends Area2D

@onready var interaction_area:InteractionArea = $InteractionArea

var opened = false

#@export var skill_name:String = "skill"

func _ready() -> void:
	interaction_area.interact = Callable(self, "on_interact")

func on_interact():
	if not opened:
		get_tree().paused = true
		var UI = $"../Character1/Camera2D/SkillUI"
		UI.set_skills()
		UI.show()
		
		$AnimatedSprite2D.play("open")
		opened = true
		$InteractionArea.free()
