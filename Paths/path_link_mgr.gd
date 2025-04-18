# Talk about a linked list
# 'links' will be fixed order. We'll interate over it and adjust the positions accordingly
# > we'll keep a variable which points to the first visible link?
# links will be shifted +x over time, until they're relocated to some negative x val once they're fully past the level area


extends Node

# Inspector
@export var level_area: CanvasItem

# Public
var num_fully_visible_pathlinks
var max_num_visible_pathlinks
var path_speed: float = 30

# Private
@onready var _link_template = load("Paths/path_link.tscn")
var _level_width: float
var _links: Array[PathLink]
var _link_width: float = Grid.cell_size
var _first_visible_link_index: int = 0

# Constants
const _min_links_to_insert = 4

# Helpers
func _prev_link_i(i: int) -> int: # get index of previous link
	return (i - 1 + len(_links)) % len(_links)

func _next_link_i(i: int) -> int: # get index of next link
	return _next_n_links_i(i, 1)

func _next_n_links_i(i: int, n: int) -> int: # get index that is n-links ahead
	return (i + n) % len(_links)

func _ready() -> void:
	_level_width = level_area.get_size()[0]
	num_fully_visible_pathlinks = _level_width / _link_width
	max_num_visible_pathlinks = num_fully_visible_pathlinks + 1
	_insert(0, _min_links_to_insert, true)  # first few links
	while len(_links) + _min_links_to_insert < max_num_visible_pathlinks:
		_insert(len(_links)-1, _min_links_to_insert, true)  # more links, don't need to wrap
	_insert(len(_links))  # last links, need to wrap to connect with first link
	
	#var to_idx = func to_idx(c: Grid.Cell): return c.y
	#for link in _links:
		#print(", ".join(link.left_ports.map(to_idx)) + " -> " + ", ".join(link.right_ports.map(to_idx)))

func insert():
	_insert(len(_links))  #TODO: not constant value, random index into hidden links

func _insert(pathlink_index: int, num_links=_min_links_to_insert, ignore_output_matching=false):
	for i in range(pathlink_index, len(_links)):
		_links[i].position += Vector2(_link_width * num_links, 0)  # shift olds out of the way
	for i in range(num_links):
		var next_link = _link_template.instantiate()
		var new_index = pathlink_index + i
		_links.insert(new_index, next_link)
		if len(_links) == 1:  # first ever link
			next_link.position = level_area.position
		else:
			var prev_link = _links[_prev_link_i(new_index)]
			next_link.position = prev_link.position + Vector2(_link_width, 0)
			next_link.left_ports = prev_link.right_ports.duplicate()
			if i+1 == num_links and not ignore_output_matching:  # last iter
				next_link.right_ports = _links[_next_link_i(new_index)].left_ports.duplicate()
		add_child(next_link)
		
func _process(delta: float) -> void:
	var path_looped = false
	var increment_vector = Vector2(path_speed * delta, 0)
	for link in _links:
		link.position += increment_vector
	if _links[_first_visible_link_index].position.x > level_area.position.x:  # left a gap at the front
		var index_before_first: int = _prev_link_i(_first_visible_link_index)
		if index_before_first == 0:
			path_looped = true
		_links[index_before_first].position = _links[_first_visible_link_index].position - Vector2(_link_width, 0)
		_first_visible_link_index = index_before_first
	if path_looped:
		Grid.set_path_offset(_links[0].position.x)
	else:
		Grid.update_path_offset_by(increment_vector.x)

func get_link_at(x_pixel: float):
	var first_vis_link_x = _links[_first_visible_link_index].position.x
	var num_links_from_first_vis = int((x_pixel - first_vis_link_x) / Grid.cell_size)
	return _links[_next_n_links_i(_first_visible_link_index, num_links_from_first_vis)]
	
func is_path_at(cell: Grid.Cell):
	var link = get_link_at(cell.to_pixel().x)
	return link.cell_has_path[cell.y]

func get_enemy_spawn_locations() -> Array: # where can an enemy spawn *right now*
	var res = Array()
	 # Choose the second-to-last visible cell so they don't fall off the back on spawn
	print("spawning from link"+str(_next_n_links_i(_first_visible_link_index, num_fully_visible_pathlinks - 1)))
	var l = _links[_next_n_links_i(_first_visible_link_index, num_fully_visible_pathlinks - 1)]
	#return l.left_ports
	for lp in l.left_ports:
		res.append(lp.to_pixel(true, true))
		print(lp.to_pixel(true, true))
	return res
	
func get_enemy_next_location(current_position: Vector2):
	var link = get_link_at(current_position.x)
	if link.is_left_port(Grid.Cell.new(current_position.x, current_position.y)):  # done with this link
		link = _links[_prev_link_i(_links.find(link))]  # set link to 'previous' (left) link
	return link.paths.pick_random().curve.get_point_position(-1) + link.position # pick a path and go to the end (assumes x=0 is beginning of game)
	
