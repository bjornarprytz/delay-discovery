class_name Tile
extends Node2D

var map: Map

signal state_changed(old_state, new_state)

var is_being_teleported_to: bool = false
@onready var audio: AudioStreamPlayer2D = %Audio

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
						texture.texture = preload("res://assets/img/Forest.jpg")
					TileInfo.TerrainType.Water:
						texture.texture = preload("res://assets/img/Water.jpg")
					TileInfo.TerrainType.Mountain:
						texture.texture = preload("res://assets/img/Mountain.jpg")
					TileInfo.TerrainType.Plains:
						texture.texture = preload("res://assets/img/Plains.jpg")
		
				if (type != TileInfo.TerrainType.Mountain):
					effect_area.gravity_space_override = Area2D.SPACE_OVERRIDE_DISABLED
				border.border_color = Color.WEB_GRAY
				border.border_width = 1
				Utility.jelly_scale(self, 0.69)
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

@onready var border: RegularPolygon = %Border

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

func _ready() -> void:
	assert(map != null)
	scale = Vector2.ONE * .2
	create_tween().tween_property(self, 'scale', Vector2.ONE, .2)
	shape.points_updated.connect(_on_points_updated)
	_on_points_updated(shape.polygon)

func _on_points_updated(points: PackedVector2Array):
	body_shape.polygon = points
	effect_area_shape.polygon = points


func _on_effect_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is Ball):
		if (is_being_teleported_to):
			is_being_teleported_to = false
			return
		apply_effect(body as Ball)

func apply_effect(ball: Ball):
	match type:
		TileInfo.TerrainType.Forest:
			ball.sleeping = true
			ball.hide()
			
			audio.stream = preload("res://assets/audio/086374_shaken-bush-40116.mp3")
			audio.pitch_scale = randf_range(.9, 1.1)
			audio.play()
			
			ball.set_deferred("global_position", global_position)
			Utility.shake(self, 0.69, 4.0)
			await get_tree().create_timer(.69).timeout
			ball.sleeping = false
			ball.show()
			ball.apply_impulse(Utility.random_vector().normalized() * 169.0)
		TileInfo.TerrainType.Water:
			var waters = map.get_tiles_of_type_and_state(TileInfo.TerrainType.Water, Tile.State.Discovered)

			waters.shuffle()
			
			audio.stream = preload("res://assets/audio/water-splash-46402.mp3")
			audio.pitch_scale = randf_range(.9, 1.1)
			audio.play()

			for w in waters:
				if w != self:
					Utility.jiggle(self, -.1)
					w.teleport_to(ball)
					break
		TileInfo.TerrainType.Mountain:
			pass
		TileInfo.TerrainType.Plains:
			ball.linear_velocity *= 1.2

func teleport_to(ball: Ball):
	is_being_teleported_to = true
	var cur_velocity = ball.linear_velocity

	ball.sleeping = true
	ball.hide()
	
	ball.set_deferred("global_position", global_position)
	await get_tree().create_timer(.69).timeout
	Utility.jiggle(self, .1)

	ball.sleeping = false
	ball.show()
	ball.apply_impulse(cur_velocity.normalized().rotated(randf_range(-PI / 16, PI / 16)) * 169.0)
