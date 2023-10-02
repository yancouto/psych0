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
	func raw_enemies() -> Array[LevelEvent.EnemyToSpawn]:
		return [LevelEvent.EnemyToSpawn.new(radius, pos, speed)]

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[LevelEvent.EnemyToSpawn]:
	assert(false)
	return []
