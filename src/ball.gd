class_name Ball
extends RigidBody2D

@export var center: Node2D
@export var bounds_radius: float = 300.0

signal out_of_bounds
signal hit_tile(tile: Tile, from_coord: Map.Coordinates)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (global_position.distance_to(center.global_position) > bounds_radius):
		out_of_bounds.emit()
		queue_free()

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.owner is Tile:
		var tile = body.owner as Tile
		
		var vec = global_position - tile.global_position

		var coord = tile.coordinates.diff(tile.map.point_to_coords(global_position + (vec.normalized() * tile.size)))

		hit_tile.emit(tile, coord)
