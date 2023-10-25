extends Node2D

var ttl: float
var center: Vector2
var speed: LevelEvent.Speed
var color: Color

func start(to_spawn: LevelEvent.IndicatorToSpawn, duration: float) -> void:
	self.ttl = duration
	self.center = to_spawn.center
	self.speed = to_spawn.speed
	self.color = to_spawn.color
	

func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	self.ttl -= dt
	queue_redraw()
	if self.ttl <= 0:
		queue_free()

func _draw() -> void:
	var points: PackedVector2Array = [center]
	var angle_range := (ttl / 5) * PI / 2
	var amount := ceili(ttl) + 3
	var radius := smoothstep(0, Formation.BASE_SPEED * 2, speed.length()) * 60 + 20
	var angle := speed.calc(center, get_node('../%Player').position).angle()
	for i in range(amount):
		points.append(center + Vector2.from_angle(angle - angle_range / 2 + (angle_range / amount) * i) * radius)
	self.draw_colored_polygon(points, color)

# This pretends to be an enemy sometimes
func die(_reason) -> void:
	queue_free()
