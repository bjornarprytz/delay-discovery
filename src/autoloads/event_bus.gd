class_name EventBus
extends Node2D


# Add signals here for game-wide events. Access through the Events singleton

signal game_over()

signal hit_paddle()
signal hit_tile(tile: Tile)
signal out_of_bounds()
