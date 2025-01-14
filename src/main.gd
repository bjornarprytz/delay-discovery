extends Node2D

const TILES_TO_PLACE_UPON_DISCOVERY = 2

@export var max_lives: int = 5

@onready var map: Map = %Map

@onready var paddle: Paddle = %Paddle
@onready var lives_text: RichTextLabel = %LivesText
@onready var bounds: RegularPolygon = %Bounds
var lives = max_lives;

var live_ball: Ball = null

func _ready() -> void:
	live_ball = paddle.prime()
	live_ball.out_of_bounds.connect(_on_out_of_bounds)
	live_ball.hit_tile.connect(_on_ball_hit_tile)
	map.get_tile(Map.Coordinates.from_vec(Vector2.ZERO)).state = Tile.State.Placed

func _on_ball_hit_tile(tile: Tile):
	
	tile.state = Tile.State.Discovered

	var tiles = map.get_tiles()

	tiles.shuffle()

	var placedTiles = 0
	var undiscoveredTiles=0
	for t in tiles:
		if (t.state == Tile.State.Hidden and placedTiles < TILES_TO_PLACE_UPON_DISCOVERY):
			t.state = Tile.State.Placed
			placedTiles += 1
		
		if (t.state != Tile.State.Discovered):
			undiscoveredTiles += 1
		
	
	if undiscoveredTiles == 0:
		$CanvasLayer/WinText.show()
		live_ball.sleeping = true

func _on_out_of_bounds():
	lives -= 1
	
	bounds.border_color = Color.FIREBRICK
	lives_text.modulate = Color.FIREBRICK
	var tween = create_tween().set_parallel()
	tween.tween_property(bounds, "border_color", Color.BLACK, 0.4)
	tween.tween_property(lives_text, "modulate", Color.WHITE, 0.4)
	
	lives_text.text = "%d/%d" % [lives, max_lives]
	
	if lives <= 0:
		Events.game_over.emit()
		$CanvasLayer/GameOverText.show()
		return
	
	live_ball = paddle.prime()
	live_ball.out_of_bounds.connect(_on_out_of_bounds)
	live_ball.hit_tile.connect(_on_ball_hit_tile)
