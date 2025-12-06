extends Control

@onready var skills = []
@onready var player = get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func _on_button_1_pressed() -> void:
	learn_skill(skills[0])
	exit_skill_ui()


func _on_button_2_pressed() -> void:
	learn_skill(skills[1])
	exit_skill_ui()


func _on_button_3_pressed() -> void:
	learn_skill(skills[2])
	exit_skill_ui()


func learn_skill(skill:String):
	var player = get_tree().get_first_node_in_group("Player")
	
	match skill:
		"dash":
				player.can_use_ability_dash = true
		"wall_jump":
				player.can_use_ability_wall_jump = true
		"slowmo":
			player.can_use_ability_slowmo = true

func set_skills():
	self.skills = generate_random_skills()
	$Menu/Button.text = "[1]\n" + skills[0]
	$Menu/Button2.text = "[2]\n" + skills[1]
	$Menu/Button3.text = "[3]\n" + skills[2]

func exit_skill_ui():
	self.hide()
	get_tree().paused = false

func generate_random_skills():
	return ["dash", "wall_jump", "slowmo"]
