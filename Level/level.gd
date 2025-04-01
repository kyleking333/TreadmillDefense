extends Node

var tower_spawn_area = load("res://Towers/tower_spawn_area.tscn")
var enemy_template = load("res://Enemies/enemy.tscn")

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

func _ready() -> void:
	$Player.set_path_speed($PathLinkMgr.path_speed)

func _process(delta: float) -> void:
	var path_shift =Vector2($PathLinkMgr.path_speed * delta, 0)
	for n in get_tree().get_nodes_in_group("TowerSpawnArea"):
		n.position += path_shift
		if n.position.x + Grid.cell_size >= $EastWall/CollisionShape2D.position.x:
			n.free()

func _handle_enemy_reaching_destination(enemy: CharacterBody2D, prev_target: Vector2):
	enemy.set_target($PathLinkMgr.get_enemy_next_location(prev_target))

func _on_enemy_spawn_timer_timeout() -> void:
	var loc = $PathLinkMgr.get_enemy_spawn_locations().pick_random()
	var enemy_instance = enemy_template.instantiate()
	enemy_instance.position = loc
	enemy_instance.hit_target.connect(_handle_enemy_reaching_destination)
	enemy_instance.set_path_speed($PathLinkMgr.path_speed)
	add_child(enemy_instance)
