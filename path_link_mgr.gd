# Talk about a linked list
# 'links' will be fixed order. We'll interate over it and adjust the positions accordingly
# > we'll keep a variable which points to the first visible link?
# links will be shifted +x over time, until they're relocated to some negative x val once they're fully past the level area


extends Node

# Inspector
@export var level_area: CanvasItem

# Public
var num_fully_visible_pathlinks

# Private
@onready var _link_template = load("path_link.tscn")
var _level_width: float
var _links: Array[PathLink]
var _link_width: float
const _min_links_to_insert = 4


func _ready() -> void:
	var first_link = _link_template.instantiate()
	_link_width =first_link.get_size()[0]
	first_link.position = level_area.position
	_links.append(first_link)
	_level_width = level_area.get_size()[0]
	num_fully_visible_pathlinks = _level_width / _link_width
	for i in range(num_fully_visible_pathlinks-1):
		var next_link = _link_template.instantiate()
		next_link.position = level_area.position + Vector2(i * _link_width, 0)
		_links.append(next_link)
	
	insert()  # should have more than the bare minimum
	
func _process(delta: float) -> void:
	pass  #TODO: move all links +x, check for past-visible, move to -x

func insert():
	_insert(0)  #TODO: not constant value, random index into hidden links

func _insert(pathlink_index: int):
	pass  #TODO: insert and configure '_min_links_to_insert' links
