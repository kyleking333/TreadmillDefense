extends Node

const cell_size: int = 64
var screen_width: int
var screen_height: int

var _path_offset_from_grid_origin: float = 0
func update_path_offset_by(increment: float):
	_path_offset_from_grid_origin = _path_offset_from_grid_origin + increment

func set_path_offset(val: float):
	_path_offset_from_grid_origin = val

func get_path_offset_from_grid_origin() -> float:
	return _path_offset_from_grid_origin

func get_path_offset_from_cell() -> float:
	var int_part = int(_path_offset_from_grid_origin)
	var decimal_part = _path_offset_from_grid_origin - int_part
	return (int_part % cell_size) + decimal_part

func _ready() -> void:
	var tmp = get_viewport().size
	screen_width = tmp[0]
	screen_height = tmp[1]

func num_rows():
	return int(screen_height / cell_size)
func num_cols():
	return int(screen_width / cell_size)

func random(x_index: int = -1, y_index: int = -1):
	if x_index == -1:
		x_index = randi() % num_cols()
	if y_index == -1:
		y_index = randi() % num_rows()
	return Cell.new(x_index, y_index)
	
func get_surrounding_cells(cell: Cell) -> Array:
	var res: Array
	# has_* 'neighbors' --> false if on border
	var has_left = cell.x > 0
	var has_right = cell.x - 1 < num_cols()
	var has_upper = cell.y > 0
	var has_lower = cell.y - 1 < num_rows()
	
	if has_left:
		res.append(Cell.new(cell.x - 1, cell.y))
		if has_upper:
			res.append(Cell.new(cell.x - 1, cell.y - 1))
		if has_lower:
			res.append(Cell.new(cell.x - 1, cell.y + 1))
	if has_right:
		res.append(Cell.new(cell.x + 1, cell.y))
		if has_upper:
			res.append(Cell.new(cell.x + 1, cell.y - 1))
		if has_lower:
			res.append(Cell.new(cell.x + 1, cell.y + 1))
	if has_upper:
		res.append(Cell.new(cell.x, cell.y - 1))
	if has_lower:
		res.append(Cell.new(cell.x, cell.y + 1))
	return res

static func snap(dim: float) -> float:
	return dim / cell_size * cell_size
	
class Cell:
	var x: int
	var y: int
	func _init(cell_x: int, cell_y: int) -> void:
		self.x = cell_x
		self.y = cell_y
	
	func to_pixel(center=false, snap_to_path=false) -> Vector2:
		var offset = Grid.get_path_offset_from_cell() if snap_to_path else 0.0
		if center:
			return Vector2((x+0.5)*cell_size + offset, (y+0.5)*cell_size)
		return Vector2(x*cell_size + offset, y*cell_size)
	
	static func from_pixel(v: Vector2) -> Cell:
		return Cell.new(int(v.x/ cell_size), int(v.y / cell_size))
	
	func minus(other: Cell):  # in cells
		return Vector2(self.x - other.x, self.y - other.y)
	
	func distance_to(other: Cell):  # in cells
		return Vector2(abs(self.x - other.x), abs(self.y - other.y))
		
	func string():
		return "Cell(%d, %d)" % [x, y]
