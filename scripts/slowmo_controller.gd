extends Node

@export var normal_time_scale:float = 1.0
@export var slowmo_time_scale:float = 0.5

@onready var tween = get_tree().create_tween()

func start_slowmo():
	#enter_slowmo_animation()
	Engine.time_scale = slowmo_time_scale
	$Timer.start()

#func enter_slowmo_animation():
	#tween.stop()
	#Tween.interpolate_value(Engine.time_scale, -slowmo_time_scale, 0, 5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	#tween.play()
#
#func exit_slowmo_animation():
	#tween.stop()
	#Tween.interpolate_value(Engine.time_scale, slowmo_time_scale, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	#tween.play()

func _on_timer_timeout() -> void:
	#exit_slowmo_animation()
	Engine.time_scale = normal_time_scale
