class_name Event

class Wait extends Event:
	var secs: float
	func _init(t: float):
		secs = t
	func trigger(root: Node, dt: float) -> bool:
		secs -= dt
		return secs <= 0

class WaitUntilNoEnemies extends Event:
	pass

class Spawn extends Event:
	var formation: Formation
	func _init(f: Formation):
		formation = f
	func trigger(root: Node, dt: float) -> bool:
		return formation.trigger(root, dt)

func trigger(_root: Node, _dt: float) -> bool:
	# must be implemented
	assert(false)
	return false
