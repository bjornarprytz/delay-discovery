extends Control

const FOREST = preload("res://assets/img/Forest.jpg")
const MOUNTAIN = preload("res://assets/img/Mountain.jpg")
const PLAINS = preload("res://assets/img/Plains.jpg")
const WATER = preload("res://assets/img/Water.jpg")

@onready var texture: TextureRect = %Texture
@onready var title: PanelContainer = %Title
@onready var tip: PanelContainer = %Tip

func _ready() -> void:
	texture.texture = [FOREST, MOUNTAIN, PLAINS, WATER].pick_random()
	title.show()
	title.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 1.69)
	
	await get_tree().create_timer(4.0).timeout
	tip.show()
	tip.modulate.a = 0.0
	var tween2 = create_tween()
	tween2.tween_property(tip, "modulate:a", 1.0, 1.69)

func _input(event: InputEvent) -> void:
	if (event is not InputEventMouseMotion):
		get_tree().change_scene_to_file("res://main.tscn")
