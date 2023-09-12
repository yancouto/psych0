extends Node

var screen

func _ready():
	screen = get_viewport().get_visible_rect().size

func _on_enemy_timer_timeout():
	var enemy = preload("res://enemy.tscn").instantiate()
	
	var pos = get_node("ScreenEdge").get_curve().samplef(randf() * 4)
	var speed = Vector2(1, 0).rotated(randf() * 2 * PI) * (200 + 200 * randf())
	if (speed.x <= 0 && pos.x == 0) or (speed.x >= 0 && pos.x == screen.x):
		speed.x = -speed.x
	if (speed.y <= 0 && pos.y == 0) or (speed.y >= 0 && pos.y == screen.y):
		speed.y = -speed.y
	enemy.start(pos, speed)
	add_child(enemy)
