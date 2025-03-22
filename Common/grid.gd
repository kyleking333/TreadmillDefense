extends Node

const cell_size: int = 64
var screen_width: int
var screen_height: int

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
	
class Cell:
	var x: int
	var y: int
	func _init(x: int, y: int) -> void:
		self.x = x
		self.y = y
	
	func to_pixel(center=false) -> Vector2:
		if center:
			return Vector2((x+0.5)*cell_size, (y+0.5)*cell_size)
		return Vector2(x*cell_size, y*cell_size)
	
	static func from_pixel(v: Vector2) -> Cell:
		return Cell.new(int(v.x / cell_size), int(v.y / cell_size))
	
	static func snap(dim: float) -> float:
		return dim / cell_size * cell_size
	
	func minus(other: Cell):  # in cells
		return Vector2(self.x - other.x, self.y - other.y)
	
	func distance_to(other: Cell):  # in cells
		return Vector2(abs(self.x - other.x), abs(self.y - other.y))
	
	func string():
		return "Cell(%d, %d)" % [x, y]
