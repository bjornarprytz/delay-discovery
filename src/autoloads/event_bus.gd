class_name EventBus
extends Node2D


var score: int = 0

signal game_over(won: bool)

signal hit_paddle()
signal hit_tile(tile: Tile)
signal out_of_bounds()
