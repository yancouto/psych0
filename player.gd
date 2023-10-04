extends Area2D
signal hit

@export var SHOT_COOLDOWN := 0.2
@export var speed := 400
@export var radius := 20
var screen_size
var cur_shot_cooldown := 0.

var CLAMP_LEFT := Vector2(radius, radius)
var CLAMP_RIGHT := Vector2(LevelBuilder.W - radius, LevelBuilder.H - radius)

func _ready():
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	($CollisionShape2D.shape as CircleShape2D).radius = radius

func _process(delta):
	if !is_visible():
		return
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
	
	# Shooting
	cur_shot_cooldown -= delta
	if cur_shot_cooldown <= 0 && Input.is_action_pressed("shoot"):
		cur_shot_cooldown = SHOT_COOLDOWN
		var shot := preload("res://shot.tscn").instantiate()
		# TODO: Support controller
		var dir := (get_viewport().get_mouse_position() - position).normalized()
		shot.start(position + (radius - shot.radius) * dir, dir * 600)
		# TODO: Make specific node for shots
		self.get_parent().add_child(shot)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Hit by an enemy
func _on_area_entered(area):
	print("IVE BEEEN HIT")
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
