extends Node2D

var window_size
export var direction : Vector2 = Vector2(0,0)
var next

func _ready():
	window_size = get_viewport().size

func move():
	position += direction * 32
	if position.x < 0:
		position.x = window_size.x - 32
	if position.y < 0:
		position.y = window_size.y - 32
	if position.x >= window_size.x:
		position.x = 0
	if position.y >= window_size.y:
		position.y = 0

func collides_with_self(pos: Vector2):
	if pos == position:
		return true
	elif next == null:
		return false
	else:
		return next.collides_with_self(pos)

func free_body():
	if next != null:
		next.free_body()
	queue_free()
