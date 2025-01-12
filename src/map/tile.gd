class_name Tile
extends Node2D

signal onHovered(tile: Tile)
signal onClicked(tile: Tile)

var map: Map

@onready var shape: RegularPolygon:
	get:
		return $Shape

@onready var size: float:
	get:
		return shape.size
	set(value):
		shape.size = value

var type: TileInfo.TerrainType:
	set(value):

		type = value

		match type:
			TileInfo.TerrainType.Forest:
				shape.modulate = Color.LIGHT_GREEN
			TileInfo.TerrainType.Water:
				shape.modulate = Color.LIGHT_BLUE
			TileInfo.TerrainType.Mountain:
				shape.modulate = Color.ROSY_BROWN
			TileInfo.TerrainType.Plains:
				shape.modulate = Color.LIGHT_YELLOW
		
		baseModulate = shape.modulate

var coordinates: Map.Coordinates:
	set(value):
		coordinates = value

		$Debug/Q.text = str(coordinates.q)
		$Debug/R.text = str(coordinates.r)
		$Debug/S.text = str(coordinates.s)

var isHovered: bool
var baseModulate: Color

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

func _physics_process(_delta: float) -> void:
	if isHovered:
		shape.modulate = baseModulate * (pingpong(Time.get_ticks_msec() / 1000.0, 1.0) + .5)
	else:
		shape.modulate = baseModulate

func _ready() -> void:
	assert(map != null)
	scale = Vector2.ONE * .2
	create_tween().tween_property(self, 'scale', Vector2.ONE, .2)
