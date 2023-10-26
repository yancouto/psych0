class_name Player
extends Area2D

signal player_dead

const BASE_RADIUS := 30.
const ARC_COOLDOWN := 1.
# Lives before resetting to nearest checkpoint
const BASE_LIVES := 1

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
var lives
var state
var recovering_cooldown := 0.
var color_a := 1.
var color_a_tween: Tween = null
var arc_cooldown := 0.

func _ready() -> void:
	spawn()

func spawn() -> void:
	position = LevelBuilder.MIDDLE
	radius = BASE_RADIUS
	draw_radius = radius
	state = State.ALIVE
	lives = BASE_LIVES
	cur_shot_cooldown = 0
	show()

func respawn() -> void:
	spawn()
	set_recovering()

func _process(dt: float) -> void:
	if !is_visible():
		return
	queue_redraw()
	dt = %BulletTime.fix_delta(dt)
	var vel := ShootingInput.dir_from_inputs(&"move_up", &"move_down", &"move_left", &"move_right")
	if !vel.is_zero_approx():
		position += vel * speed * dt
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
		if cur_shot_cooldown <= 0:
			var dir := ShootingInput.shooting_direction(get_viewport(), position)
			if !dir.is_zero_approx():
				cur_shot_cooldown = SHOT_COOLDOWN
				var shot := preload("res://shot.tscn").instantiate()
				shot.start(position + (radius - shot.radius) * dir, dir * 600, $ColorChanger.get_color())
				# TODO: Make specific node for shots
				self.get_parent().add_child(shot)
		# Arcs
		arc_cooldown -= dt
		if arc_cooldown <= 0:
			arc_cooldown = ARC_COOLDOWN
			var arc := preload("res://arc.tscn").instantiate()
			arc.start(position, radius, $ColorChanger.get_color(), 2) 
			self.get_parent().add_child(arc)


func _draw() -> void:
	if state == State.ALIVE:
		var dir := get_local_mouse_position().normalized()
		draw_line(Vector2.ZERO, dir * (LevelBuilder.H + LevelBuilder.W), Color(0, 0, 0, 0.15), 1, true)
	var color: Color = $ColorChanger.get_color() if state == State.ALIVE else Color.DIM_GRAY
	color.a = color_a
	draw_circle(Vector2(), draw_radius, color)

func set_recovering() -> void:
	state = State.RECOVERING
	arc_cooldown = 0. # Throw an arc right away after recovering
	recovering_cooldown = 2.
	var tween := create_tween().set_loops()
	tween.tween_property(self, 'color_a', 0., 0.1).set_delay(0.25)
	tween.tween_property(self, 'color_a', 1., 0.1).set_delay(0.1)
	color_a_tween = tween

func create_explosion() -> void:
	var emitter := preload("res://ball_particles.tscn").instantiate()
	emitter.configure(position, $ColorChanger.get_color(), radius)
	get_parent().add_child(emitter)

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
		player_dead.emit()
		create_explosion()
		return
	set_recovering()

func _on_bullet_time_activated():
	radius = BASE_RADIUS * .8
	create_tween().tween_property(self, 'draw_radius', radius, 0.3)

func _on_bullet_time_deactivated():
	radius = BASE_RADIUS
	create_tween().tween_property(self, 'draw_radius', radius, 0.3)
