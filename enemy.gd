extends Area2D

var vel

func start(pos, _vel):
	position = pos
	vel = _vel

func _process(delta):
	position += vel * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
