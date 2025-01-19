class_name Map
extends Node2D

class Coordinates:
	## North-South line
	var q: int
	## UpperLeft-LowerRight line
	var r: int
	## LowerLeft-UpperRight line
	var s: int
	
	var _neighbours: Array[Coordinates]

	func _init(qq, rr):
		q = qq
		r = rr
		s = -qq - rr

	static func from_vec(vec: Vector2i) -> Coordinates:
		return Coordinates.new(vec.x, vec.y)

	func get_neighbours() -> Array[Coordinates]:
		if _neighbours != null:
			_neighbours = []
			for nVec in Utility.get_axial_neighbors(Vector2i(q, r)):
				_neighbours.push_back(Coordinates.from_vec(nVec))
		
		return _neighbours
	
	func get_rotated(steps: int) -> Coordinates:
		var vec = self.to_vec()
		var rotated = Utility.get_rotated_cell(vec, steps)
		return Coordinates.from_vec(rotated)
		
	func get_key() -> String:
		return str(q) + "," + str(r)
	func add_coord(other: Coordinates) -> Coordinates:
		return Coordinates.new(q + other.q, r + other.r)
	func add_vec(vec: Vector2i) -> Coordinates:
		return Coordinates.new(q + vec.x, r + vec.y)
	func diff(other: Coordinates) -> Coordinates:
		return Coordinates.new(q - other.q, r - other.r)
	func to_vec() -> Vector2i:
		return Vector2i(q, r)

signal tileHovered(tile: Tile)
signal tileClicked(tile: Tile)

@export var tileSize: float:
	set(value):
		if value <= 1.0:
			value = 1.0
		if tileSize == value:
			return
		tileSize = value

@onready var tiles = $Tiles

@export var radius: int = 5

## Key -> Tile
var tilesLookup: Dictionary = {}
## Key -> Coordinate
var undiscoveredTiles: Dictionary = {}

func _ready() -> void:
	_initialize_map()

func get_tiles() -> Array[Tile]:
	var result: Array[Tile] = []

	for c in tiles.get_children():
		if c is Tile:
			result.push_back(c)

	return result

## Add tile to the edge of the map, mute the returned tile to configure it
func discover_tile(coords: Coordinates) -> Tile:
	assert(undiscoveredTiles.has(coords.get_key()))
	
	return _add_tile(coords.q, coords.r)

func get_tile(coords: Coordinates) -> Tile:
	var key = coords.get_key()
	if tilesLookup.has(key):
		return tilesLookup[key]
	return null

func get_tile_from_mouse_pointer() -> Tile:
	var coords = point_to_coords(get_local_mouse_position())
	return get_tile(coords)

func _initialize_map():
	for q in range(radius):
		for r in range(radius):
			_add_tile(-q, r)
			_add_tile(q, -r)
			
			if abs(q + r) >= radius:
				continue
			
			_add_tile(q, r)
			if (q != 0 or r != 0):
				_add_tile(-q, -r)
	
func _add_tile(q: int, r: int) -> Tile:
	var coords = Coordinates.new(q, r)
	var key = coords.get_key()
	
	if tilesLookup.has(key):
		return null
	
	undiscoveredTiles.erase(key)
	for n in coords.get_neighbours():
		var nKey = n.get_key()
		if !tilesLookup.has(nKey):
			undiscoveredTiles[nKey] = n

	var newTile = Create.tile(TileInfo.random())
	newTile.coordinates = coords
	newTile.map = self
	
	tilesLookup[key] = newTile
	
	newTile.position = Utility.axial_to_pixel(q, r, tileSize)
	newTile.size = tileSize
	
	tiles.add_child(newTile)
	newTile.state = Tile.State.Hidden

	return newTile

func point_to_coords(point: Vector2) -> Coordinates:
	var q = (2.0 / 3.0 * point.x) / tileSize
	var r = (-1.0 / 3.0 * point.x + sqrt(3) / 3.0 * point.y) / tileSize
	return Utility.cube_round(Coordinates.new(q, r))


func get_tiles_of_type_and_state(type: TileInfo.TerrainType, state: Tile.State) -> Array[Tile]:
	var result: Array[Tile] = []
	for t in get_tiles():
		if t.type == type and t.state == state:
			result.push_back(t)
	return result
