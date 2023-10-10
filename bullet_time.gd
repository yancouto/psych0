extends Node2D

var size := Vector2(50, 30)
var border := 3.
var active := false

const MAX_SECS := 2.0
const RECOVER := 0.4
var secs_left := MAX_SECS

func _draw() -> void:
	draw_rect(Rect2(position, size), Color.BLACK, false, 2)
	var inner_size := size - 2 * Vector2(border, border)
	inner_size.x *= secs_left / MAX_SECS
	draw_rect(Rect2(position + Vector2(border, border), inner_size), Color.BLACK, true)

func _process(dt: float) -> void:
	var prev_secs_left := secs_left
	var prev_active := active
	if Input.is_action_pressed("bullet_time"):
		secs_left = maxf(secs_left - dt, 0.)
		active = secs_left > 0
	else:
		secs_left = minf(MAX_SECS, secs_left + dt * RECOVER)
		active = false
	if !prev_active && active:
		activated.emit()
	if prev_active && !active:
		deactivated.emit()
	if secs_left != prev_secs_left:
		queue_redraw()

func fix_delta(delta: float) -> float:
	var multiplier := 0.3 if active else 1.0
	return delta * multiplier

signal activated
signal deactivated
