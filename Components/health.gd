class_name Health
extends Node

signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted

@export var max_health: int = 5 : set = set_max_health, get = get_max_health
@export var immortality: bool = false : set = set_immortality, get = get_immortality
var immortality_timer: Timer = null
@onready var health: int = max_health : set = set_health, get = get_health

# Max health:
func set_max_health(val: int):
	var clamped_val = 1 if val <= 0 else val
	
	if not clamped_val == max_health:
		var difference = clamped_val - max_health
		max_health = val
		max_health_changed.emit(difference)
		
		if health > max_health:
			health = max_health

func get_max_health() -> int:
	return max_health
	
# Immortality:

func set_immortality(val: bool):
	pass
	
func get_immortality() -> bool:
	return immortality
	
func set_temp_immortality(time: float):
	if immortality_timer == null:
		immortality_timer = Timer.new()
		immortality_timer.one_shot = true
		add_child(immortality_timer)
		
	if immortality_timer.timeout.is_connected(set_immortality):
		immortality_timer.timeout.disconnect(set_immortality)
		
	immortality_timer.set_wait_time(time)
	immortality_timer.timeout.connect(set_immortality.bind(false))
	immortality = true
	immortality_timer.start()

# Health:

func set_health(val: int):
	if val < health and immortality:
		return
		
	var clamped_val = clampi(val, 0, max_health)
	
	if clamped_val != health:
		var difference = clamped_val - health
		health = val
		health_changed.emit(difference)
		
		if health == 0:
			health_depleted.emit()

func get_health() -> int:
	return health
