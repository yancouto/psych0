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

# Multiple enemies in a line, one after another
class Multiple extends Formation:
	var amount: int
	# Position of the closes enemy to the screen
	var pos: Vector2
	# Speed of the closes enemy to screen
	var speed: Vector2
	# Distance between enemies
	var spacing: float
	# Enemy radius
	var radius: float
	func _init(amount: int, pos: Vector2, speed: Vector2, spacing := 5., radius := 40.):
		self.amount = amount
		self.pos = pos
		self.speed = speed
		self.spacing = spacing
		self.radius = radius
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var dir := -speed.normalized()
		for i in range(amount):
			enemies.append(EnemyToSpawn.new(radius, pos + dir * i * (spacing + 2 * radius), speed))
		return enemies

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
			# Still needs a little work but it's good enough
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
	# Allows customisable width and height
	func _inner_raw_enemies(w: float, h: float) -> Array[EnemyToSpawn]:
		var positions := placement.positions(amount, radius, w)
		var enemies: Array[EnemyToSpawn] = []
		for pos in positions:
			var speed_y: float
			if side == HorizontalLineSide.Top:
				pos.y = -radius - pos.y
				speed_y = speed_len
			else:
				pos.y = h + radius + pos.y
				speed_y = -speed_len
			enemies.append(EnemyToSpawn.new(radius, pos, Vector2(0, speed_y)))
		return enemies
	func raw_enemies() -> Array[EnemyToSpawn]:
		return _inner_raw_enemies(LevelBuilder.W, LevelBuilder.H)

enum VerticalLineSide { Left, Right }

class VerticalLinePlacement:
	# Distribute enemies evenly in the screen
	class Distribute extends VerticalLinePlacement:
		# Margin from the leftmost and rightmost enemy to the side of the screen
		var margin: float
		func _init(margin: float = 0):
			self.margin = margin
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.Distribute.new(margin)

	# Distribute enemies evenly, and make them V-shaped
	class V extends VerticalLinePlacement:
		# How much to vary x between enemies
		var dx: float
		var margin: float
		func _init(dx: float, margin: float = 0):
			self.dx = dx
			self.margin = margin
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.V.new(dx, margin)

	# Distribute enemies evenly, with a gap in the middle. Automatically balances enemies left and right.
	class Gap extends VerticalLinePlacement:
		# Center of the gap
		var center: float
		# Size of the gap
		var size: float
		func _init(center: float, size: float):
			self.center = center
			self.size = size
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.Gap.new(center, size)

	# Convert to Horizontal, to minimise code duplication. Remember to swap x and y
	func convert() -> HorizontalLinePlacement:
		assert(false, "Must be implemented on all subclasses")
		return null

class VerticalLine extends Formation:
	var amount: int
	var side: VerticalLineSide
	var placement: VerticalLinePlacement
	var speed_len: float
	var radius: float
	func _init(amount: int, side: VerticalLineSide, placement: VerticalLinePlacement, speed_len: float = 300, radius: float = 30):
		self.amount = amount
		self.side = side
		self.placement = placement
		self.speed_len = speed_len
		self.radius = radius
	func raw_enemies() -> Array[EnemyToSpawn]:
		var horizontal_side := HorizontalLineSide.Top if side == VerticalLineSide.Left else HorizontalLineSide.Bottom
		var enemies := HorizontalLine.new(amount, horizontal_side, placement.convert(), speed_len, radius)._inner_raw_enemies(LevelBuilder.H, LevelBuilder.W)
		for enemy in enemies:
			enemy.pos = Vector2(enemy.pos.y, enemy.pos.x)
			enemy.speed = Vector2(enemy.speed.y, enemy.speed.x)
		return enemies

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[EnemyToSpawn]:
	assert(false)
	return []
