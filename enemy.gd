extends Area2D

var speed: Vector2

var radius: float:
	get: return radius
	set(r):
		radius = r
		($CollisionShape2D.shape as CircleShape2D).radius = r
		$VisibleOnScreenNotifier2D.rect.size = Vector2(2 * r, 2 * r)
		$VisibleOnScreenNotifier2D.rect.position = Vector2(-r, -r)

func start(_position: Vector2, _speed: Vector2, _radius: float) -> void:
	self.position = _position
	self.speed = _speed
	self.radius = _radius

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.FIREBRICK)

func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	position += speed * dt

func shot() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
