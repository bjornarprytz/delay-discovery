extends Node2D

@export var max_lives : int = 3

@onready var map: Map = %Map

@onready var paddle: Paddle = %Paddle
@onready var lives_text: RichTextLabel = %LivesText
var lives = max_lives;

var live_ball : Ball = null

func _ready() -> void:
	live_ball = paddle.prime()
	live_ball.out_of_bounds.connect(_on_out_of_bounds)
	live_ball.hit_tile.connect(_on_ball_hit_tile)
	map.get_tile(Map.Coordinates.from_vec(Vector2.ZERO)).state = Tile.State.Placed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ball_hit_tile(tile: Tile, diff: Map.Coordinates):
	
	tile.state = Tile.State.Discovered
	
	var coords = tile.coordinates
	
	var newTileCoords = coords.add_coord(diff)
	
	var newTile = map.get_tile(newTileCoords)
	
	if (newTile == null):
		return
	
	var newTiles = [newTile]
	
	var n1 = newTile.get_neighbours()
	var n2 = tile.get_neighbours()
	
	for t in n1:
		if t in n2:
			newTiles.append(t)
	
	for t in newTiles:
		t.state = Tile.State.Placed
	
	

func _on_out_of_bounds():
	lives -= 1
	
	lives_text.text = "%d/%d" % [lives, max_lives]
	
	print(lives)
	
	if lives <= 0:
		Events.game_over.emit()
		return
	
	live_ball = paddle.prime()
	live_ball.out_of_bounds.connect(_on_out_of_bounds)
	live_ball.hit_tile.connect(_on_ball_hit_tile)
