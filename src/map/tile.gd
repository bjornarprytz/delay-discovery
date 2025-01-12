class_name Tile
extends Node2D

var map: Map

signal state_changed(old_state, new_state)

enum State {
	Init,
	Hidden,
	Placed,
	Discovered
}

var state: State:
	get:
		return state
	set(value):
		if (value == state):
			return
		var old_state = state
		state = value
		match (state):
			State.Hidden:
				visible = false
				body_shape.set_deferred("disabled", true)
				effect_area_shape.set_deferred("disabled", true)
			State.Placed:
				visible = true
				body_shape.set_deferred("disabled", false)
				effect_area_shape.set_deferred("disabled", true)
			State.Discovered:
				body_shape.set_deferred("disabled", true)
				effect_area_shape.set_deferred("disabled", false)
				
				match type:
					TileInfo.TerrainType.Forest:
						texture.texture = preload("res://assets/img/Forest.jpeg")
					TileInfo.TerrainType.Water:
						texture.texture = preload("res://assets/img/Water.jpeg")
					TileInfo.TerrainType.Mountain:
						texture.texture = preload("res://assets/img/Mountain.jpeg")
					TileInfo.TerrainType.Plains:
						texture.texture = preload("res://assets/img/Plains.jpeg")
		
				texture.position += (Utility.random_vector() * 50.0)
		state_changed.emit(old_state, state)

@onready var shape: RegularPolygon:
	get:
		return $Shape

@onready var size: float:
	get:
		return shape.size
	set(value):
		shape.size = value

@onready var body: StaticBody2D = %Body
@onready var body_shape: CollisionPolygon2D = %Body/Shape

@onready var effect_area: Area2D = %EffectArea
@onready var effect_area_shape: CollisionPolygon2D = %EffectArea/Shape

@onready var texture: TextureRect = %Texture

var type: TileInfo.TerrainType:
	set(value):
		type = value

var coordinates: Map.Coordinates:
	get:
		return coordinates
	set(value):
		coordinates = value

		$Debug/Q.text = str(coordinates.q)
		$Debug/R.text = str(coordinates.r)
		$Debug/S.text = str(coordinates.s)

var isHovered: bool

func get_neighbours() -> Array[Tile]:
	var neighbours: Array[Tile] = []

	for nCoord in coordinates.get_neighbours():
		var n = map.get_tile(nCoord)

		if (n != null):
			neighbours.push_back(n)

	return neighbours

func get_relative_tile(displacement: Vector2i) -> Tile:
	var targetCoords = coordinates.add_vec(displacement)
	return map.get_tile(targetCoords)

func is_corner() -> bool:
	return Utility.is_corner_tile(self, map.radius)

func is_edge() -> bool:
	return Utility.is_edge_tile(self, map.radius)

func _ready() -> void:
	assert(map != null)
	scale = Vector2.ONE * .2
	create_tween().tween_property(self, 'scale', Vector2.ONE, .2)
	shape.points_updated.connect(_on_points_updated)
	_on_points_updated(shape.polygon)

func _on_points_updated(points: PackedVector2Array):
	body_shape.polygon = points
	effect_area_shape.polygon = points
