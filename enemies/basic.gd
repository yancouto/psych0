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

enum Type { One, Three }

func start(_position: Vector2, _speed: Vector2, _radius: float, _type: Type) -> void:
	self.position = _position
	self.speed = _speed
	self.radius = _radius
	self.type = _type
	match _type:
		Type.One:
			health = 1
		Type.Three:
			health = 3

func draw_filled_arc(start_angle: float, end_angle: float, color: Color) -> void:
	draw_arc(Vector2.ZERO, radius / 2, start_angle, end_angle, 20, color, radius)

func _draw() -> void:
	match type:
		Type.One:
			draw_circle(Vector2.ZERO, radius, Color.SEA_GREEN)
		Type.Three:
			draw_filled_arc((3 - health) * TAU / 3, TAU, Color.YELLOW)
			if health < 3:
				draw_filled_arc(0, (3 - health) * TAU / 3, Color.DIM_GRAY)

func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	position += speed * dt

func create_explosion() -> void:
	# Let's move the particle emitter to the parents (since we're deleting this)
	# which works but we might want to do better later
	var particles := $BallParticles
	# Already died before
	if particles == null:
		return
	remove_child(particles)
	particles.configure(position, Color.SEA_GREEN if type == Type.One else Color.YELLOW, radius)
	get_parent().add_child(particles)

func die() -> void:
	create_explosion()
	queue_free()

func shot() -> void:
	health -= 1
	if health <= 0:
		die()
	else:
		queue_redraw()

func _on_visible_on_screen_notifier_2d_screen_exited():
	die()
