extends Node2D

var radius: float
var width: float
var color: Color
var speed: float

func start(position_: Vector2, radius_: float, color_: Color, width_: float, speedm := 1.) -> void:
	position = position_
	radius = radius_
	color = Color(color_, 0.2 + randf() * 0.2)
	width = width_
	speed = (100 + randf() * 50) * speedm

func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	queue_redraw()
	radius += dt * speed
	# Too big, won't show up on screen anymore
	if Formation.radius_from_center(position) <= radius - width:
		queue_free()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, ceilf(radius / 10) + 10, color, width)
