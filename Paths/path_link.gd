class_name PathLink
extends Area2D

#TODO: add path2d
@export var path_sprite: Sprite2D  #TODO: prettify with multiple

@export var inputs: Array  # Grid.Cell
@export var outputs: Array  # Grid.Cell

const _num_ports_distribution = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3]

func get_size():
	return $Sprite2D.texture.get_size() * $Sprite2D.scale

func get_closest(starting_cell: Grid.Cell, list_of_cells: Array):
	var diffs = Array()
	for i in range(len(list_of_cells)):
		diffs.append(starting_cell.distance_to(list_of_cells[i]))
	return list_of_cells[diffs.find(diffs.min())]
	
func _ready() -> void:
	#print("inputs defined="+str(len(inputs)>0)+", outputs defined="+str(len(outputs)>0))
	$Sprite2D.modulate = Color(randf(), randf(), randf(), clamp(randf(), 0.1, 0.5))
	
	if len(inputs) == 0:  # generate inputs if needed
		for i in range(_num_ports_distribution.pick_random()):
			inputs.append(Grid.random(0, -1))

	if len(outputs) == 0:  # generate outputs if needed
		for i in range(_num_ports_distribution.pick_random()):
			outputs.append(Grid.random(0, -1))
	#print(inputs, outputs)
	
	# now that inputs/outputs are decided, generate paths
	var has_path = Array()
	has_path.resize(Grid.num_rows())
	has_path.fill(false)
	
	# first, have inputs choose an output to path to
	for input_port in inputs:
		has_path[input_port.y] = true
		var target_y = get_closest(input_port, outputs).y
		if input_port.y < target_y:
			for i in range(input_port.y, target_y):
				has_path[i] = true
		else:
			for i in range(input_port.y, target_y, -1):
				has_path[i] = true
	
	# next, have any neglected outputs choose an input to path to
	for output_port in outputs:
		if not has_path[output_port.y]:
			has_path[output_port.y] = true
			var target_y = get_closest(output_port, inputs).y
			if output_port.y < target_y:
				for i in range(output_port.y, target_y):
					has_path[i] = true
			else:
				for i in range(output_port.y, target_y, -1):
					has_path[i] = true
	
	for i in range(len(has_path)):
		if has_path[i]:
			var s: Sprite2D = path_sprite.duplicate()
			s.position = Grid.Cell.new(0, i).to_pixel(true)
			s.visible = true
			s.modulate = $Sprite2D.modulate
			s.modulate.a = 1.0
			add_child(s)
	
