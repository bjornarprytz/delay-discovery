@tool
class_name RegularPolygon
extends Polygon2D

signal clicked
signal hovered(state: bool)

@export var size: float = 25.0:
	get:
		return size
	set(value):
		if value == size:
			return
		if value < 0.0:
			value = 1.0
		
		size = value

@export var n_sides: int = 6:
	get:
		return n_sides
	set(value):
		if value == n_sides:
			return
		
		if (value < 3):
			value = 3
		
		n_sides = value

@export var border_color: Color:
	set(value):
		if (border_color == value):
			return
		border_color = value
		
@export var border_width: float:
	set(value):
		if (border_width == value):
			return
		border_width = value

@export var clickable: bool:
	set(value):
		if (clickable == value):
			return
		clickable = value

@onready var border: Line2D = $Border
@onready var clickableShape: CollisionPolygon2D = $Clickable/Shape

func _ready() -> void:
	_update_polygon()

func _on_clickable_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if !clickable:
		return
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.is_pressed() \
		and !event.is_echo():
		clicked.emit()

func _on_clickable_mouse_entered() -> void:
	hovered.emit(true)
func _on_clickable_mouse_exited() -> void:
	hovered.emit(false)

func _update_polygon():
	border.width = border_width
	border.default_color = border_color

	var angle_increment = 2 * PI / n_sides

	var points: PackedVector2Array = []
	for i in range(n_sides):
		var angle = i * angle_increment
		var x = size * cos(angle)
		var y = size * sin(angle)
		
		points.push_back(Vector2(x, y))
	
	polygon = points
	border.points = points
	clickableShape.polygon = points
	
	queue_redraw()
