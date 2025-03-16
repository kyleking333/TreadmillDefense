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
var path_speed: float = 100

# Private
@onready var _link_template = load("path_link.tscn")
var _level_width: float
var _links: Array[PathLink]
var _link_width: float = 64
var _first_visible_link_index = 0

# Constants
const _min_links_to_insert = 4

# Helpers

func _prev_link_i(i):
	return (i - 1 + len(_links)) % len(_links)

func _next_link_i(i):
	return (i + 1) % len(_links)


func _ready() -> void:
	_level_width = level_area.get_size()[0]
	num_fully_visible_pathlinks = _level_width / _link_width
	max_num_visible_pathlinks = num_fully_visible_pathlinks + 1
	_insert(0, _min_links_to_insert, true)  # first few links
	while len(_links) + _min_links_to_insert < max_num_visible_pathlinks:
		_insert(len(_links)-1, _min_links_to_insert, true)  # more links, don't need to wrap
	_insert(len(_links))  # last links, need to wrap to connect with first link
	
	var to_idx = func to_idx(v: Vector2): return int(v.y / 64)
	for link in _links:
		print(", ".join(link.inputs.map(to_idx)) + " -> " + ", ".join(link.outputs.map(to_idx)))

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
			next_link.inputs = prev_link.outputs.duplicate()
			if i+1 == num_links and not ignore_output_matching:  # last iter
				next_link.outputs = _links[_next_link_i(new_index)].inputs.duplicate()
		add_child(next_link)
		
func _process(delta: float) -> void:
	for link in _links:
		link.position += Vector2(path_speed * delta, 0)
	if _links[_first_visible_link_index].position.x > level_area.position.x:  # left a gap at the front
		var index_before_first = _prev_link_i(_first_visible_link_index)
		_links[index_before_first].position = _links[_first_visible_link_index].position - Vector2(_link_width, 0)
		_first_visible_link_index = index_before_first
