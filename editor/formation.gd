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
	var starting_angle: float
	var speed_len: float
	func _init(amount: int, starting_angle: float = 0, speed_len: float = 200):
		self.amount = amount
		self.starting_angle = starting_angle
		self.speed_len = speed_len
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var n := self.amount
		enemies.resize(n)
		var center := Vector2(LevelBuilder.W / 2.0, LevelBuilder.H / 2.0)
		const enemy_radius := 20
		var circle_radius := center.length() + enemy_radius
		for i in range(n):
			var angle := Vector2(0, -1).rotated(starting_angle + i * (TAU / n))
			var pos := center + angle * circle_radius
			var speed := -angle * speed_len
			enemies[i] = EnemyToSpawn.new(enemy_radius, pos, speed)
		return enemies

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[EnemyToSpawn]:
	assert(false)
	return []
