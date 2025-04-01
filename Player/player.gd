extends CharacterBody2D

const SPEED = 450.0
var _against_path_velocity: Vector2
var _dir: Vector2

func set_path_speed(speed: float):  # the speed the path zooms by towards +x
	_against_path_velocity = Vector2(speed * -1, 0)

func _input(_event: InputEvent) -> void:
	pass

func _ready() -> void:
	_dir = Vector2.ZERO
	
func _process(_delta: float) -> void:
	_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	velocity = (SPEED * _dir + _against_path_velocity)
	var collided = move_and_slide()
	if collided:
		pass#print("collided")
