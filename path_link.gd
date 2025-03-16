class_name PathLink
extends Area2D

#TODO: add path2d
@export var path_sprite: Sprite2D  #TODO: prettify with multiple

@export var inputs: Array[Vector2]
@export var outputs: Array[Vector2]

const _num_ports_distribution = [1, 1, 1, 1, 1, 2, 2, 3]

func get_size():
	return $Sprite2D.texture.get_size() * $Sprite2D.scale

func _snap_y(y):
	return int(y / 64) * 64

func get_closest(p, list_of_points):
	var diffs = Array()
	for i in range(len(list_of_points)):
		diffs.append(list_of_points[i] - p)
	return list_of_points[diffs.find(diffs.min())]
	
func _ready() -> void:
	#print("inputs defined="+str(len(inputs)>0)+", outputs defined="+str(len(outputs)>0))
	$Sprite2D.modulate = Color(randf(), randf(), randf(), clamp(randf(), 0.1, 0.5))
	
	var l = int(get_size()[1])
	if len(inputs) == 0:  # generate inputs if needed
		for i in range(_num_ports_distribution.pick_random()):
			var y  = _snap_y(randi() % l)
			inputs.append(Vector2(0, y))

	if len(outputs) == 0:  # generate outputs if needed
		for i in range(_num_ports_distribution.pick_random()):
			var y  = _snap_y(randi() % l)
			outputs.append(Vector2(0, y))
	#print(inputs, outputs)
	
	# now that inputs/outputs are decided, generate paths
	var has_path = Array()
	has_path.resize(l/64 + (1 if l%64 else 0))
	has_path.fill(false)
	
	# first, have inputs choose an output to path to
	for input_port in inputs:
		has_path[input_port.y/64] = true
		var target_y = get_closest(input_port, outputs).y
		if input_port.y < target_y:
			for i in range(input_port.y, target_y, 64):
				has_path[i/64] = true
		else:
			for i in range(input_port.y, target_y, -64):
				has_path[i/64] = true
	
	# next, have any neglected outputs choose an input to path to
	for output_port in outputs:
		has_path[output_port.y/64] = true
		if not has_path[output_port.y/64]:
			var target_y = get_closest(output_port, inputs).y
			if output_port.y < target_y:
				for i in range(output_port.y, target_y, 64):
					has_path[i/64] = true
			else:
				for i in range(output_port.y, target_y, -64):
					has_path[i/64] = true
	
	for i in range(len(has_path)):
		if has_path[i]:
			var s: Sprite2D = path_sprite.duplicate()
			s.position = Vector2(64/2, i * 64 + 64/2)
			s.visible = true
			s.modulate = $Sprite2D.modulate
			s.modulate.a = 1.0
			add_child(s)
	
