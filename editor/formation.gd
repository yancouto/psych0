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

enum HorizontalLineSide { Top, Bottom }

class HorizontalLinePlacement:
	# Distribute enemies evenly in the screen
	class Distribute extends HorizontalLinePlacement:
		# Margin from the leftmost and rightmost enemy to the side of the screen
		var margin: float
		func _init(margin: float = 0):
			self.margin = margin
		func positions(n: int, radius: float, len: float) -> Array[Vector2]:
			if n == 1:
				return [Vector2(len / 2, 0)]
			var pos: Array[Vector2] = []
			len -= margin * 2
			for i in range(n):
				var dist := (len - 2 * n * radius) / (n - 1)
				var x := i * dist + radius * (2 * i + 1)
				pos.append(Vector2(x + margin, 0))
			return pos

	# Distribute enemies evenly, and make them V-shaped
	class V extends HorizontalLinePlacement:
		# How much to vary y between enemies
		var dy: float
		var margin: float
		func _init(dy: float, margin: float = 0):
			self.dy = dy
			self.margin = margin
		func positions(n: int, radius: float, len: float) -> Array[Vector2]:
			# Let's reuse the math from Distribute, and only change the y
			var pos := Distribute.new(margin).positions(n, radius, len)
			for i in range(n):
				pos[i].y = floorf(absf(i - ((n - 1.) / 2.))) * dy
			return pos

	# Distribute enemies evenly, with a gap in the middle. Automatically balances enemies left and right.
	class Gap extends HorizontalLinePlacement:
		# Center of the gap
		var center: float
		# Size of the gap
		var size: float
		func _init(center: float, size: float):
			self.center = center
			self.size = size
		func positions(n: int, radius: float, len: float) -> Array[Vector2]:
			var n_left := roundi(n * ((center - size / 2) / (len - size)))
			# Adjust center a little to make balls look good on both sides
			center = (float(n_left) / n) * (len - size) + size / 2
			var n_right := n - n_left
			var pos_left := Distribute.new(0).positions(n_left, radius, center - size / 2)
			var pos_right := Distribute.new(0).positions(n_right, radius, len - (center + size / 2))
			var pos := pos_left
			for p in pos_right:
				pos.append(Vector2(p.x + center + size / 2, p.y))
			return pos

	# Position of enemies, assuming screen horizontal size is len
	# y will start at 0 and go torwards positive
	func positions(n: int, radius: float, len: float) -> Array[Vector2]:
		assert(false, "Must be implemented by all subclasses")
		return []

class HorizontalLine extends Formation:
	var amount: int
	var side: HorizontalLineSide
	var placement: HorizontalLinePlacement
	var speed_len: float
	var radius: float
	func _init(amount: int, side: HorizontalLineSide, placement: HorizontalLinePlacement, speed_len: float = 300, radius: float = 30):
		self.amount = amount
		self.side = side
		self.placement = placement
		self.speed_len = speed_len
		self.radius = radius
	func raw_enemies() -> Array[EnemyToSpawn]:
		var positions := placement.positions(amount, radius, LevelBuilder.W)
		var enemies: Array[EnemyToSpawn] = []
		for pos in positions:
			var speed_y: float
			if side == HorizontalLineSide.Top:
				pos.y = -radius - pos.y
				speed_y = speed_len
			else:
				pos.y = LevelBuilder.H + radius + pos.y
				speed_y = -speed_len
			enemies.append(EnemyToSpawn.new(radius, pos, Vector2(0, speed_y)))
		return enemies

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[EnemyToSpawn]:
	assert(false)
	return []
