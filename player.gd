extends Area2D
signal hit

@export var speed := 400
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	position = screen_size / 2

func _process(delta):
	var vel = Vector2.ZERO
	if Input.is_action_pressed("move_down"):
		vel.y += 1
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	position += vel.normalized() * speed * delta

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_area_entered(area):
	print("IVE BEEEN HIT")
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
