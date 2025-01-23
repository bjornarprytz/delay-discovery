class_name Ball
extends RigidBody2D

@export var center: Node2D
@export var bounds_radius: float = 300.0
@onready var audio: AudioStreamPlayer2D = %Audio
@onready var polygon: RegularPolygon = %Polygon

signal out_of_bounds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio.stream = preload("res://assets/audio/bubble-pop-283674.mp3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (center == null):
		return
	if (global_position.distance_to(center.global_position) > bounds_radius):
		out_of_bounds.emit()
		queue_free()

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var hit_something = false
	if body.owner is Tile:
		var tile = body.owner as Tile
		Events.hit_tile.emit(tile)
		hit_something = true
	
	if body.owner is Paddle:
		Events.hit_paddle.emit()
		hit_something = true
		
	if hit_something:
		audio.pitch_scale = randf_range(.9, 1.1)
		audio.play()

		polygon.modulate = Utility.random_color()
