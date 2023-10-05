extends Area2D

var speed: Vector2

var radius: float:
	get: return radius
	set(r):
		radius = r
		($CollisionShape2D.shape as CircleShape2D).radius = r
		$VisibleOnScreenNotifier2D.rect.size = Vector2(2 * r, 2 * r)
		$VisibleOnScreenNotifier2D.rect.position = Vector2(-r, -r)

func start(position: Vector2, speed: Vector2, radius: float) -> void:
	self.position = position
	self.speed = speed
	self.radius = radius


func _process(delta):
	position += speed * delta

func shot() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
