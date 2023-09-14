extends Area2D

var vel

var radius: float:
	get: return radius
	set(r):
		radius = r
		($CollisionShape2D.shape as CircleShape2D).radius = r
		$VisibleOnScreenNotifier2D.rect.size = Vector2(2 * r, 2 * r)
		$VisibleOnScreenNotifier2D.rect.position = Vector2(-r, -r)

func start(pos, _vel):
	position = pos
	vel = _vel


func _process(delta):
	position += vel * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
