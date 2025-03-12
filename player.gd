extends CharacterBody2D

const SPEED = 25000.0

var _dir: Vector2

func _input(_event: InputEvent) -> void:
	pass

func _ready() -> void:
	_dir = Vector2.ZERO
	
func _process(delta: float) -> void:
	_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	velocity = SPEED * _dir * delta
	var collided = move_and_slide()
	if collided:
		print("collided")
