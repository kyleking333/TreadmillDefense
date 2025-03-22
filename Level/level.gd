extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_released("spawn_tower"):
		print("spawn")

func highlight_spawnable_areas():
	$Player.position
