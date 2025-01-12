class_name Factory
extends Node2D

# Add factory methods for common scenes here. Access through the Create singleton


@onready var tileSpawner: PackedScene = preload("res://map/tile.tscn")
@onready var ballSpawner: PackedScene = preload("res://ball.tscn")

func tile(tileInfo: TileInfo) -> Tile:
	var tileScene = tileSpawner.instantiate() as Tile

	tileScene.type = tileInfo.terrainType

	return tileScene

func ball() -> Ball:
	var ballScene = ballSpawner.instantiate() as Ball
	
	return ballScene
