class_name Formation

const EnemyToSpawn = LevelEvent.EnemyToSpawn

class Single extends Formation:
	#var enemy: String
	var pos: Vector2
	var speed: Vector2
	var radius: float
	func _init(p: Vector2, s: Vector2, r: float):
		pos = p
		speed = s
		radius = r
	func raw_enemies() -> Array[EnemyToSpawn]:
		return [EnemyToSpawn.new(radius, pos, speed)]

class Circle extends Formation:
	var amount: int
	func _init(amount: int):
		self.amount = amount
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var n := self.amount
		enemies.resize(n)
		var center := Vector2(LevelBuilder.W / 2.0, LevelBuilder.H / 2.0)
		const enemy_radius := 20
		var circle_radius := center.length() + enemy_radius
		const speed_len := 200
		for i in range(n):
			var angle := Vector2(0, -1).rotated(i * (TAU / n))
			var pos := center + angle * circle_radius
			var speed := -angle * speed_len
			enemies[i] = EnemyToSpawn.new(enemy_radius, pos, speed)
		return enemies

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[EnemyToSpawn]:
	assert(false)
	return []
