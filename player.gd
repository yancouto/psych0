extends Area2D


const BASE_RADIUS := 30.

enum State { ALIVE, RECOVERING, DEAD }

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
var lives := 10
var state := State.ALIVE
var recovering_cooldown := 0.
var color_a := 1.
var color_a_tween: Tween = null

func _ready() -> void:
	position = Vector2(LevelBuilder.W / 2, LevelBuilder.H / 2)
	radius = BASE_RADIUS
	draw_radius = radius


func _process(dt: float) -> void:
	if !is_visible():
		return
	queue_redraw()
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
	
	if state == State.RECOVERING:
		recovering_cooldown -= dt
		if recovering_cooldown <= 0:
			state = State.ALIVE
			$CollisionShape2D.set_deferred("disabled", false)
			color_a = 1.
			color_a_tween.kill()
	elif state == State.ALIVE:
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


func _draw() -> void:
	if state == State.ALIVE:
		var dir := get_local_mouse_position().normalized()
		draw_line(Vector2.ZERO, dir * (LevelBuilder.H + LevelBuilder.W), Color(0, 0, 0, 0.15), 1, true)
	var color := Color.DEEP_PINK if state == State.ALIVE else Color.DIM_GRAY
	color.a = color_a
	draw_circle(Vector2(), draw_radius, color)

# Hit by an enemy
func _on_area_entered(_area: Area2D) -> void:
	if state != State.ALIVE:
		return
	lives -= 1
	print("IVE BEEEN HIT (now ", lives, " lives)")
	$CollisionShape2D.set_deferred("disabled", true)
	if lives <= 0:
		state = State.DEAD
		hide()
	state = State.RECOVERING
	recovering_cooldown = 2.
	var tween := create_tween().set_loops()
	tween.tween_property(self, 'color_a', 0., 0.1).set_delay(0.25)
	tween.tween_property(self, 'color_a', 1., 0.1).set_delay(0.1)
	color_a_tween = tween

	

func _on_bullet_time_activated():
	radius = BASE_RADIUS * .8
	create_tween().tween_property(self, 'draw_radius', radius, 0.3)

func _on_bullet_time_deactivated():
	radius = BASE_RADIUS
	create_tween().tween_property(self, 'draw_radius', radius, 0.3)
