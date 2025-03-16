class_name PathLink
extends Area2D

func get_size():
	return $Sprite2D.texture.get_size() * $Sprite2D.scale

func _ready() -> void:
	modulate = Color(randf(), randf(), randf(), clamp(randf(), 0.5, 1.0))
	
