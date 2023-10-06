extends Node2D

var ttl: float
var center: Vector2
var angle: float

func start(to_spawn: LevelEvent.IndicatorToSpawn, duration: float) -> void:
	self.ttl = duration
	self.center = to_spawn.center
	self.angle = to_spawn.angle
	

func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	self.ttl -= dt
	if self.ttl <= 0:
		queue_free()

func _draw() -> void:
	var points: PackedVector2Array = [center]
	const angle_range := PI / 6
	const amount := 5
	const radius := 45
	for i in range(amount):
		points.append(center + Vector2.from_angle(angle - angle_range / 2 + (angle_range / amount) * i) * radius)
	self.draw_colored_polygon(points, Color.AQUA)
