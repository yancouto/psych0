extends Area2D

@export var radius := 7
var speed: Vector2
var color: Color

func start(position_: Vector2, speed_: Vector2, color_: Color) -> void:
	self.position = position_
	self.speed = speed_
	self.color = color_

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($CollisionShape2D.shape as CircleShape2D).radius = radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	position += speed * dt

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func create_explosion() -> void:
	var particles := $BallParticles
	# Already died before
	if particles == null:
		return
	remove_child(particles)
	particles.configure(position, color, radius)
	get_parent().add_child(particles)

func die() -> void:
	create_explosion()
	queue_free()

# Hit an enemy
func _on_area_entered(enemy) -> void:
	enemy.shot()
	die()


func _on_visible_on_screen_notifier_2d_screen_exited():
	die()
