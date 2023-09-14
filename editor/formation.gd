class_name Formation

class Single extends Formation:
	#var enemy: String
	var pos: Vector2
	var speed: Vector2
	var radius: float
	func _init(p: Vector2, s: Vector2, r: float):
		pos = p
		speed = s
		radius = r
	func trigger(root: Node, dt: float) -> bool:
		var enemy = preload("res://enemy.tscn").instantiate()
		enemy.radius = radius
		enemy.start(pos, speed)
		root.add_child(enemy)
		return true

func trigger(_root: Node, _dt: float) -> bool:
	assert(false)
	return false
