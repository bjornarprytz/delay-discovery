class_name Paddle
extends Control

const BOUNDS_GRACE = 50.0

@export var center: Node2D
@export var radius: float = 300.0
@onready var score_splash: CPUParticles2D = %ScoreSplash

var _ball: Ball = null

var move_factor: float = 0.0
var inertia: float = 0.0

const MOVE_SPEED: float = 20.0
const MAX_SPEED: float = 25.0
const accel: float = 4.0
const decel: float = 10.0

var target_rotation: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = center.global_position + (Vector2.DOWN * radius)
	pivot_offset = Vector2.UP * radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var inputVector = Vector2.ZERO
	
	if (Input.get_connected_joypads().size() > 0):
		inputVector = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	else:
		inputVector = (center.global_position - get_global_mouse_position())
		inputVector.x *= -1

	
	if (inputVector.length() > .8):
		target_rotation = -rad_to_deg(inputVector.angle()) - 90.0
	
	# Move the paddle, but as it crosses from 0 to 360, we need to adjust the rotation
	var current_rotation = fmod(rotation_degrees, 360.0)
	var diff = target_rotation - current_rotation
	
	if diff > 180:
		diff -= 360
	elif diff < -180:
		diff += 360
	
	rotation_degrees = lerp(current_rotation, current_rotation + diff, 0.1)

func _input(event: InputEvent) -> void:

	var joyPadConnected = Input.get_connected_joypads().size() > 0

	if event.is_action_pressed("ui_left") or event.is_action_released("ui_right"):
		move_factor += 1.0
	if event.is_action_pressed("ui_right") or event.is_action_released("ui_left"):
		move_factor -= 1.0
	
		
	if _ball != null:
		if joyPadConnected && event is InputEventJoypadButton and event.is_pressed() and event.button_index == JOY_BUTTON_A:
			launch_ball()
		elif !joyPadConnected && event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			launch_ball()

func launch_ball():
	_ball.sleeping = false
	_ball.reparent(get_tree().root)
	var impulse = center.global_position - global_position
	_ball.apply_impulse(impulse)
	_ball = null

func splash(amount: int):
	score_splash.amount = amount
	score_splash.emitting = true

func prime() -> Ball:
	var ball = Create.ball()
	
	add_child(ball)
	ball.sleeping = true
	ball.center = center
	ball.bounds_radius = radius + BOUNDS_GRACE
	
	_ball = ball
	
	return ball
