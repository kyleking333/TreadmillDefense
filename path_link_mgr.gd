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
var _link_width: float
var _first_visible_link_index = 0


# Constants
const _min_links_to_insert = 4



func _ready() -> void:
	var first_link = _link_template.instantiate()
	_link_width =first_link.get_size()[0]
	first_link.position = level_area.position
	_links.append(first_link)
	add_child(first_link)
	_level_width = level_area.get_size()[0]
	num_fully_visible_pathlinks = _level_width / _link_width
	max_num_visible_pathlinks = num_fully_visible_pathlinks + 1
	for i in range(num_fully_visible_pathlinks-1):
		var next_link = _link_template.instantiate()
		next_link.position = level_area.position + Vector2(i * _link_width, 0)
		_links.append(next_link)
		add_child(next_link)
	
	_insert_after(len(_links)-1)  # should have more than the bare minimum #links

func insert():
	_insert_after(len(_links)-1)  #TODO: not constant value, random index into hidden links

# assumes always called on hidden indexes
func _insert_after(pathlink_index: int, num_links=_min_links_to_insert):
	for i in range(pathlink_index, len(_links)):
		_links[i].position += Vector2(_link_width * num_links, 0)  # shift olds out of the way
	for i in range(_min_links_to_insert):
		var next_link = _link_template.instantiate()
		next_link.position = level_area.position + Vector2(i * _link_width, 0)
		_links.insert(pathlink_index + i, next_link)
		add_child(next_link)
		
func _process(delta: float) -> void:
	for link in _links:
		link.position += Vector2(path_speed * delta, 0)
	if _links[_first_visible_link_index].position.x > level_area.position.x:  # left a gap at the front
		var index_before_first = (_first_visible_link_index - 1 + len(_links)) % len(_links)
		_links[index_before_first].position = _links[_first_visible_link_index].position - Vector2(_link_width, 0)
		_first_visible_link_index = index_before_first
