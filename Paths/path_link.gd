class_name PathLink
extends Area2D

#TODO: add path2d
@export var path_sprite: Sprite2D  #TODO: prettify with multiple

@export var left_ports: Array  # Grid.Cell
@export var right_ports: Array  # Grid.Cell

var paths: Array

var cell_has_path: Array

const _num_ports_distribution = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3]

func get_size():
	return $Sprite2D.texture.get_size() * $Sprite2D.scale

func get_closest(starting_cell: Grid.Cell, list_of_cells: Array):
	var diffs = Array()
	for i in range(len(list_of_cells)):
		diffs.append(starting_cell.distance_to(list_of_cells[i]))
	return list_of_cells[diffs.find(diffs.min())]
	
func _ready() -> void:
	#print("left_ports defined="+str(len(left_ports)>0)+", right_ports defined="+str(len(right_ports)>0))
	$Sprite2D.modulate = Color(randf(), randf(), randf(), clamp(randf(), 0.1, 0.5))
	var cell_x_val = Grid.Cell.from_pixel(position).x
	
	if len(left_ports) == 0:  # generate left_ports if needed
		for i in range(_num_ports_distribution.pick_random()):
			left_ports.append(Grid.random(cell_x_val, -1))

	if len(right_ports) == 0:  # generate right_ports if needed
		for i in range(_num_ports_distribution.pick_random()):
			right_ports.append(Grid.random(cell_x_val, -1))
	#print(left_ports, right_ports)
	
	# now that left_ports/right_ports are decided, generate paths
	paths = Array()
	cell_has_path = Array()
	cell_has_path.resize(Grid.num_rows())
	cell_has_path.fill(false)
	
	# Time to generate paths. We will do this right to left, modeling enemies
	
	# First, make sure every right_port maps to a left_port
	for right_port in right_ports:
		var curve = Curve2D.new()
		var target = get_closest(right_port, left_ports)
		if right_port.y < target.y: # in->downscreen->out
			for i in range(right_port.y, target.y+1): #+1 to make inclusive
				cell_has_path[i] = true
				curve.add_point(Grid.Cell.new(target.x, i).to_pixel(true))
		else: # in->upscreen->out
			for i in range(right_port.y, target.y-1, -1): #-1 to make inclusive
				cell_has_path[i] = true
				curve.add_point(Grid.Cell.new(target.x, i).to_pixel(true))
		var p = Path2D.new()
		p.curve = curve
		paths.append(p)
	
	# Next, make sure every left_port maps to a right port
	for left_port in left_ports:
		if not cell_has_path[left_port.y]:
			var curve = Curve2D.new()
			var target = get_closest(left_port, right_ports)
			if target.y <= left_port.y: # in->downscreen->out
				for i in range(target.y, left_port.y+1): #+1 to make inclusive
					cell_has_path[i] = true
					curve.add_point(Grid.Cell.new(target.x, i).to_pixel(true))
			else: # in->upscreen->out
				for i in range(target.y, left_port.y-1, -1): #-1 to make inclusive
					cell_has_path[i] = true
					curve.add_point(Grid.Cell.new(target.x, i).to_pixel(true))
			var p = Path2D.new()
			p.curve = curve
			paths.append(p)
		
	for i in range(len(cell_has_path)):
		if cell_has_path[i]:
			var s: Sprite2D = path_sprite.duplicate()
			s.position = Grid.Cell.new(0, i).to_pixel(true)
			s.visible = true
			s.modulate = $Sprite2D.modulate
			s.modulate.a = 1.0
			add_child(s)

func is_left_port(c: Grid.Cell) -> bool:
	if c.x != left_ports[0].x:
		return false
	for lp in left_ports:
		if c.y == lp.y:
			return true
	return false
