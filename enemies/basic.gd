class_name BasicEnemy
extends Area2D

var speed: Vector2

var radius: float:
	get: return radius
	set(r):
		radius = r
		($CollisionShape2D.shape as CircleShape2D).radius = r
		$VisibleOnScreenNotifier2D.rect.size = Vector2(2 * r, 2 * r)
		$VisibleOnScreenNotifier2D.rect.position = Vector2(-r, -r)
var type: Type
var health: int
var color: Color

enum Type { One, Three }
enum DieReason { Shot, Reset, Other }

func start(_position: Vector2, _speed: Vector2, _radius: float, _type: Type) -> void:
	self.position = _position
	self.speed = _speed
	self.radius = _radius
	self.type = _type
	match _type:
		Type.One:
			health = 1
			color = Color.SEA_GREEN
		Type.Three:
			health = 3
			color = Color.YELLOW
			color.s = 0.9
			color.v = 0.8
	color.s = clampf(color.s + randf() * 0.4 - 0.2, 0, 1)
	color.v = clampf(color.v + randf() * 0.4 - 0.2, 0, 1)

func draw_filled_arc(start_angle: float, end_angle: float, colora: Color) -> void:
	draw_arc(Vector2.ZERO, radius / 2, start_angle, end_angle, 20, colora, radius)

func _draw() -> void:
	match type:
		Type.One:
			draw_circle(Vector2.ZERO, radius, color)
		Type.Three:
			draw_filled_arc((3 - health) * TAU / 3 - .05, TAU + .05, color)
			if health < 3:
				draw_filled_arc(0, (3 - health) * TAU / 3, Color.DIM_GRAY)

func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	position += speed * dt

func create_explosion(reason: DieReason) -> void:
	# Let's move the particle emitter to the parents (since we're deleting this)
	# which works but we might want to do better later
	var particles := $BallParticles
	# Already died before
	if particles == null:
		return
	remove_child(particles)
	particles.configure(position, color, radius)
	get_parent().add_child(particles)
	if reason == DieReason.Shot:
		var arc := preload("res://arc.tscn").instantiate()
		arc.start(position, radius, color, 1, 1)
		self.get_parent().get_parent().add_child(arc)

func die(reason: DieReason = DieReason.Other) -> void:
	if reason != DieReason.Reset:
		create_explosion(reason)
	queue_free()

func shot() -> void:
	health -= 1
	if health <= 0:
		die(DieReason.Shot)
	else:
		queue_redraw()

func _on_visible_on_screen_notifier_2d_screen_exited():
	die()
