extends Area2D
signal hit

@export var speed := 400
@export var radius := 20
var screen_size

var CLAMP_LEFT := Vector2(radius, radius)
var CLAMP_RIGHT := Vector2(LevelBuilder.W - radius, LevelBuilder.H - radius)

func _ready():
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	($CollisionShape2D.shape as CircleShape2D).radius = radius

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
	if !vel.is_zero_approx():
		position += vel.normalized() * speed * delta
		position = position.clamp(CLAMP_LEFT, CLAMP_RIGHT)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_area_entered(area):
	print("IVE BEEEN HIT")
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
