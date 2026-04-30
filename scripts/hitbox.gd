class_name Hitbox
extends Area2D

@export var active_animation: String = "attack"
@export var active_frames: Array[int] = [2, 3]
@onready var collision_shape = get_child(0) as CollisionShape2D
	
var already_hit: Array = []  # ← track what's been hit this attack	

func _init() -> void:
	collision_layer = 2
	collision_mask = 0

func _ready() -> void:
	# disable hitbox by default
	collision_shape.disabled = true
	
	var animated_sprite = _find_animated_sprite()
	if animated_sprite:
		animated_sprite.frame_changed.connect(_on_frame_change)
		animated_sprite.animation_changed.connect(_on_animation_changed)

func _find_animated_sprite():
	for child in owner.get_children():
		if child is AnimatedSprite2D:
			return child
			
func _on_animation_changed() -> void:
	already_hit.clear()  # reset each new animation

func _on_frame_change() -> void:
	var animated_sprite = _find_animated_sprite()
	if not animated_sprite:
		return
	
	if animated_sprite.animation == active_animation and animated_sprite.frame <= active_frames.back() and animated_sprite.frame >= active_frames[0]:
		collision_shape.disabled = false
	else:
		collision_shape.disabled = true
		
func set_active_frame(x: int, y: int) -> void:
	active_frames = [x, y]

func register_hit(area: Area2D) -> bool:
	if area in already_hit:
		return false
	already_hit.append(area)
	return true
	
