extends Area2D
signal hit

const BASE_RADIUS := 30.

@export var SHOT_COOLDOWN := 0.2
@export var speed := 400
var radius : float:
	get:
		return radius
	set(r):
		($CollisionShape2D.shape as CircleShape2D).radius = r
		radius = r
var draw_radius : float
var cur_shot_cooldown := 0.

func _ready() -> void:
	position = Vector2(LevelBuilder.W / 2, LevelBuilder.H / 2)
	radius = BASE_RADIUS
	draw_radius = radius


func _process(dt: float) -> void:
	if !is_visible():
		return
	dt = %BulletTime.fix_delta(dt)
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
		position += vel.normalized() * speed * dt
		position = position.clamp(Vector2(radius, radius), Vector2(LevelBuilder.W - radius, LevelBuilder.H - radius))
	
	# Shooting
	cur_shot_cooldown -= dt
	if cur_shot_cooldown <= 0 && Input.is_action_pressed("shoot"):
		cur_shot_cooldown = SHOT_COOLDOWN
		var shot := preload("res://shot.tscn").instantiate()
		# TODO: Support controller
		var dir := (get_viewport().get_mouse_position() - position).normalized()
		shot.start(position + (radius - shot.radius) * dir, dir * 600)
		# TODO: Make specific node for shots
		self.get_parent().add_child(shot)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(), draw_radius, Color.DEEP_PINK)

func start(position_: Vector2) -> void:
	position = position_
	show()
	$CollisionShape2D.disabled = false

# Hit by an enemy
func _on_area_entered(_area: Area2D) -> void:
	print("IVE BEEEN HIT")
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func _on_bullet_time_activated():
	radius = BASE_RADIUS * .8
	create_tween().tween_property(self, 'draw_radius', radius, 0.3)

func _on_bullet_time_deactivated():
	radius = BASE_RADIUS
	create_tween().tween_property(self, 'draw_radius', radius, 0.3)
