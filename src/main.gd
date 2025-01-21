extends Node2D

const TILES_TO_PLACE_UPON_DISCOVERY = 2

enum State {PLAYING, WON, LOST}

@export var max_lives: int = 5

@onready var map: Map = %Map

@onready var paddle: Paddle = %Paddle
@onready var lives_text: RichTextLabel = %LivesText
@onready var score_text: RichTextLabel = %ScoreText
@onready var bounds: RegularPolygon = %Bounds
@onready var air_time_text: RichTextLabel = %AirTimeText
@onready var velocity_text: RichTextLabel = %VelocityText
@onready var compas: TextureRect = %Compas

@onready var game_over_modulate: ColorRect = %GameOverModulate
@onready var lost_text: RichTextLabel = %LostText
@onready var won_text: RichTextLabel = %WonText
@onready var lost_container: VBoxContainer = %LostContainer
@onready var won_container: VBoxContainer = %WonContainer

var lives = max_lives;

var live_ball: Ball = null
var current_air_time: float = 0.0
var state: State = State.PLAYING

var score: int = 0:
    set(value):
        if score == value:
            return
        score = value

        score_text.text = str(score)
        score_text.modulate = Color.LIME_GREEN
        var tween = create_tween()
        tween.tween_property(score_text, "modulate", Color.WHITE, 0.4)

var combo: int = 0

func _ready() -> void:
    score = Events.score
    live_ball = paddle.prime()
    live_ball.out_of_bounds.connect(_on_out_of_bounds)
    map.get_tile(Map.Coordinates.from_vec(Vector2.ZERO)).state = Tile.State.Placed

    Events.hit_tile.connect(_on_hit_tile)
    Events.hit_paddle.connect(_on_hit_paddle)
    Events.game_over.connect(_on_game_over)

func _on_hit_tile(tile: Tile):
    score += 1
    combo += 1

    tile.state = Tile.State.Discovered

    var tiles = map.get_tiles()

    tiles.shuffle()

    var placedTiles = 0
    var undiscoveredTiles = 0
    for t in tiles:
        if (t.state == Tile.State.Hidden and placedTiles < TILES_TO_PLACE_UPON_DISCOVERY):
            t.state = Tile.State.Placed
            placedTiles += 1
        
        if (t.state != Tile.State.Discovered):
            undiscoveredTiles += 1
        
    
    if undiscoveredTiles == 0:
        score += combo
        combo = 0
        live_ball.sleeping = true
        Events.game_over.emit(true)

func _on_hit_paddle():
    score += combo
    if combo > 0:
        paddle.splash(combo)
    combo = 0

    current_air_time = 0.0

func _on_game_over(won: bool):
    game_over_modulate.show()
    if (won):
        state = State.WON
        won_container.show()
        won_text.append_text(": %d" % score)
    else:
        state = State.LOST
        lost_container.show()

func _process(delta: float) -> void:
    if live_ball != null:
        var target_angle: float = 0.0;
        if paddle.ball == null and state == State.PLAYING:
            current_air_time += delta
            target_angle = paddle.rotation
        else:
            target_angle = live_ball.linear_velocity.angle() + PI / 2
        
        compas.rotation = lerp_angle(compas.rotation, target_angle, 0.069)
        velocity_text.text = "%.2f" % live_ball.linear_velocity.length()
        air_time_text.text = "%.2f" % current_air_time

func _input(event: InputEvent) -> void:
    if (state == State.PLAYING):
        return
    
    if (event.is_action_pressed("launch")):
        var won = state == State.WON
        var current_score = score
        get_tree().reload_current_scene()
        
        if (won):
            Events.score = current_score
        else:
            Events.score = 0

func _on_out_of_bounds():
    lives -= 1
    
    bounds.border_color = Color.FIREBRICK
    lives_text.modulate = Color.FIREBRICK
    var tween = create_tween().set_parallel()
    tween.tween_property(bounds, "border_color", Color.BLACK, 0.4)
    tween.tween_property(lives_text, "modulate", Color.WHITE, 0.4)
    
    lives_text.text = "%d/%d" % [lives, max_lives]
    
    if lives <= 0:
        Events.game_over.emit(false)
        return
    
    live_ball = paddle.prime()
    live_ball.out_of_bounds.connect(_on_out_of_bounds)
