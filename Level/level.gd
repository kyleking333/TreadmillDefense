extends Node

var tower_spawn_area = load("res://Towers/tower_spawn_area.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_released("spawn_tower"):
		for n in get_tree().get_nodes_in_group("TowerSpawnArea"):
			n.free()
		highlight_spawnable_areas()

func highlight_spawnable_areas():
	var base = Grid.Cell.from_pixel($Player.position)
	var cells = Grid.get_surrounding_cells(base)
	for cell in cells:
		var target_pixel = cell.to_pixel(false, true)
		if not $PathLinkMgr.is_path_at(cell):
			var tower_spawn_instance = tower_spawn_area.instantiate()
			tower_spawn_instance.position = target_pixel
			add_child(tower_spawn_instance)

func _process(delta: float) -> void:
	var path_shift =Vector2($PathLinkMgr.path_speed * delta, 0)
	for n in get_tree().get_nodes_in_group("TowerSpawnArea"):
		n.position += path_shift
		if n.position.x + Grid.cell_size >= $EastWall/CollisionShape2D.position.x:
			n.free()
