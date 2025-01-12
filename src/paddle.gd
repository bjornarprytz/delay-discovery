class_name Paddle
extends Control

const BOUNDS_GRACE = 20.0

@export var center: Node2D
@export var radius: float = 300.0

var _ball : Ball = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = center.global_position + (Vector2.DOWN * radius)
	pivot_offset = Vector2.UP * radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation_degrees += (20.0 * delta)

func _input(event: InputEvent) -> void:
	if _ball != null and event is InputEventMouseButton and event.is_pressed():
		_ball.sleeping = false
		_ball.reparent(get_tree().root)
		var impulse = center.global_position - global_position
		_ball.apply_impulse( impulse)
		_ball = null

func prime() -> Ball:
	var ball = Create.ball()
	
	add_child(ball)
	ball.sleeping = true
	ball.center = center
	ball.bounds_radius = radius + BOUNDS_GRACE
	
	_ball = ball
	
	return ball
