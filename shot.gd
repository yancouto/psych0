extends Area2D

@export var radius := 7
var speed: Vector2

func start(position: Vector2, speed: Vector2) -> void:
	self.position = position
	self.speed = speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($CollisionShape2D.shape as CircleShape2D).radius = radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	dt = get_node("../%BulletTime").fix_delta(dt)
	position += speed * dt

# Hit an enemy
func _on_area_entered(enemy) -> void:
	enemy.shot()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
