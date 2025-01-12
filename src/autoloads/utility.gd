extends Node

func shake(node: CanvasItem, duration: float, magnitude: float) -> Tween:
	var tween = node.create_tween()
	const shake_duration: float = 0.01
	
	var n_shakes: int = int(duration / shake_duration)
	
	for i in range(n_shakes):
		tween.tween_property(node, "position", node.position + Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude)), shake_duration)
		tween.tween_property(node, "position", node.position, shake_duration)
	
	return tween

func jelly_scale(node: CanvasItem, duration: float) -> Tween:
	var tween = node.create_tween()
	var target_scale = node.scale
	node.scale = Vector2.ZERO
	tween.tween_property(node, "scale", target_scale, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	return tween

func jiggle(node: CanvasItem, magnitude: float, n_jiggles: int = 1, original_scale: Vector2 = Vector2.ONE) -> Tween:
	var tween = node.create_tween()

	var upper_scale = node.scale + Vector2.ONE * magnitude
	var lower_scale = node.scale - Vector2.ONE * magnitude

	for n in range(n_jiggles):
		tween.tween_property(node, "scale", upper_scale, 0.05)
		tween.tween_property(node, "scale", lower_scale, 0.05)
	
	tween.tween_property(node, "scale", original_scale, 0.05)
	
	return tween

# Function to calculate relative luminance of an RGB color
func get_luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b

# Function to get contrast color (either black or white) based on luminance
func get_contrast_color(color: Color) -> Color:
	var luminance = get_luminance(color)
	
	# If luminance is higher than 0.5, return black, otherwise return white
	if luminance > 0.5:
		return Color(0, 0, 0) # Black
	else:
		return Color(1, 1, 1) # White

func random_color() -> Color:
	return Color(
		randf_range(0, 1),
		randf_range(0, 1),
		randf_range(0, 1)
	)

func fade_in(node: CanvasItem, duration: float) -> Tween:
	var tween = node.create_tween()
	node.modulate.a = 0
	tween.tween_property(node, "modulate:a", 1.0, duration)

	return tween

func to_dictionary(o: Variant) -> Dictionary:
	var dict = {}
	
	if o == null:
		return dict
	
	# Get a list of all properties on the object
	var property_list = o.get_property_list()
	
	for prop in property_list:
		var prop_name = prop.name
		match prop_name:
			"script":
				continue
			"RefCounted":
				continue
			"Built-in script":
				continue
			_:
				pass
		
		match prop.type:
			TYPE_OBJECT:
				dict[prop_name] = to_dictionary(o.get(prop_name))
			TYPE_NIL:
				dict[prop_name] = null
			_:
				dict[prop_name] = o.get(prop_name)
				
	
	return dict


static var axialForward: Vector2i = get_axial_neighbors()[0]

static func is_corner_tile(tile: Tile, mapRadius: int) -> bool:
	# TODO: This is a crude way to check if a tile is a corner. It should be improved.
	var cornerCoords = [0, (mapRadius - 1), -(mapRadius - 1)]
	var coords = tile.coordinates

	return coords.q != coords.r and coords.q in cornerCoords and coords.r in cornerCoords

static func is_edge_tile(tile: Tile, mapRadius: int) -> bool:
	var largestCardinal = mapRadius - 1
	var coords = tile.coordinates

	return abs(coords.q) == largestCardinal \
		or abs(coords.r) == largestCardinal \
		or abs(coords.s) == largestCardinal

static func get_axial_neighbors(vector: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	return [
		vector + Vector2i(1, 0),
		vector + Vector2i(0, 1),
		vector + Vector2i(-1, 1),
		vector + Vector2i(-1, 0),
		vector + Vector2i(0, -1),
		vector + Vector2i(1, -1),
	]

## Uses the axial coordinate system as described here: https://www.redblobgames.com/grids/hexagons/#coordinates-axial
static func get_cells(constellation: Array = []) -> Array[Vector2i]:
	# Root (0,0) is given
	var cells: Array[Vector2i] = [Vector2i.ZERO]

	for tuple in constellation:
		var cell = Vector2i(tuple[0], tuple[1])
		assert(!cells.has(cell))

		cells.push_back(cell)

	return cells

static func get_rotated_cells(cells: Array[Vector2i], rotationSteps: int) -> Array[Vector2i]:
	var rotatedCells: Array[Vector2i] = []

	if ((rotationSteps % 6) == 0):
		return cells
	
	for cell in cells:
		var rotated = get_rotated_cell(cell, rotationSteps)
		rotatedCells.push_back(rotated)
	
	return rotatedCells

static func get_rotated_cell(vec: Vector2i, rotationSteps: int) -> Vector2i:
	var q = vec.x
	var r = vec.y
	var s = -q - r
	
	for rot in range(rotationSteps):
		var temp_q = q
		q = -r
		r = -s
		s = -temp_q
	
	return Vector2i(q, r)

static func get_polygon_points(vector: Vector2i = Vector2i(0, 0), nSides: int = 6, radius: float = 1.0) -> PackedVector2Array:
	var angle_increment = 2 * PI / nSides

	var center = axial_to_pixel(vector.x, vector.y, radius)

	var points: PackedVector2Array = []
	for i in range(nSides):
		var angle = i * angle_increment
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		
		points.push_back(center + Vector2(x, y))

	return points

static func axial_to_pixel(q: int, r: int, tileSize: float) -> Vector2:
	var x: float = tileSize * 3.0 / 2.0 * q
	var y: float = tileSize * sqrt(3) * (r + q / 2.0)
	return Vector2(x, y)

static func cube_round(frac: Map.Coordinates) -> Map.Coordinates:
	var q = round(frac.q)
	var r = round(frac.r)
	var s = round(frac.s)

	var q_diff = abs(q - frac.q)
	var r_diff = abs(r - frac.r)
	var s_diff = abs(s - frac.s)

	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	else:
		s = -q - r

	return Map.Coordinates.new(q, r)
