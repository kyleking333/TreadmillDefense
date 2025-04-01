extends CharacterBody2D

@export var _path_velocity: Vector2

const SPEED = 3000.0
signal hit_target

func _ready() -> void:
	$Target.monitoring = true

func set_target(v: Vector2):
	$Target.position = v

func set_path_speed(s: float):
	_path_velocity = Vector2(s, 0)

func _physics_process(delta: float) -> void:
	var path_movement = _path_velocity * delta
	$Target.position += path_movement
	var to_goal = $Target.position - position
	velocity = to_goal.normalized() * (SPEED*delta) + path_movement
	move_and_slide()

func _on_target_body_entered(body: Node2D) -> void:
	hit_target.emit(self, $Target.position)
