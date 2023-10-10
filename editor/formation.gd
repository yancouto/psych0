class_name Formation

const EnemyToSpawn = LevelEvent.EnemyToSpawn

const BASE_SPEED := 400.
const BASE_RADIUS := 30.

static func get_speed(speedm: Vector2) -> Vector2:
	return speedm * BASE_SPEED

static func get_radius(radiusm: float) -> float:
	return radiusm * BASE_RADIUS

class Single extends Formation:
	#var enemy: String
	var pos: Vector2
	var speedm: Vector2
	var radiusm: float
	func _init(p: Vector2, sm: Vector2, rm: float):
		pos = p
		speedm = sm
		radiusm = rm
	func raw_enemies() -> Array[EnemyToSpawn]:
		return [EnemyToSpawn.new(Formation.get_radius(radiusm), pos, Formation.get_speed(speedm))]

# Multiple enemies in a line, one after another
class Multiple extends Formation:
	var amount: int
	# Position of the closes enemy to the screen
	var pos: Vector2
	# Speed of the closes enemy to screen
	var speedm: Vector2
	# Distance between enemies
	var spacing: float
	# Enemy radius
	var radiusm: float
	func _init(amount_: int, pos_: Vector2, speedm_: Vector2, spacing_ := 5., radiusm_ := 1.):
		self.amount = amount_
		self.pos = pos_
		self.speedm = speedm_
		self.spacing = spacing_
		self.radiusm = radiusm_
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var dir := -speedm.normalized()
		var speed := Formation.get_speed(speedm)
		var radius := Formation.get_radius(radiusm)
		for i in range(amount):
			enemies.append(EnemyToSpawn.new(radius, pos + dir * i * (spacing + 2 * radius), speed))
		return enemies

class Circle extends Formation:
	var amount: int
	var starting_angle: float
	var speed_len: float
	func _init(amount_: int, starting_angle_ := 0., speed_len_ := 1.):
		self.amount = amount_
		self.starting_angle = starting_angle_
		self.speed_len = speed_len_
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var n := self.amount
		enemies.resize(n)
		var center := Vector2(LevelBuilder.W / 2.0, LevelBuilder.H / 2.0)
		# TODO: Make customisable
		const enemy_radius := BASE_RADIUS
		var circle_radius := center.length() + enemy_radius
		for i in range(n):
			var angle := Vector2(0, -1).rotated(starting_angle + i * (TAU / n))
			var pos := center + angle * circle_radius
			var speed := -angle * speed_len * BASE_SPEED
			enemies[i] = EnemyToSpawn.new(enemy_radius, pos, speed)
		return enemies

enum HorizontalLineSide { Top, Bottom }

class HorizontalLinePlacement:
	# Distribute enemies evenly in the screen
	class Distribute extends HorizontalLinePlacement:
		# Margin from the leftmost and rightmost enemy to the side of the screen
		var margin: float
		func _init(margin_: float = 0):
			self.margin = margin_
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
		func _init(dy_: float, margin_: float = 0):
			self.dy = dy_
			self.margin = margin_
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
		func _init(center_: float, size_: float):
			self.center = center_
			self.size = size_
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
	func positions(_n: int, _radius: float, _len: float) -> Array[Vector2]:
		assert(false, "Must be implemented by all subclasses")
		return []

class HorizontalLine extends Formation:
	var amount: int
	var side: HorizontalLineSide
	var placement: HorizontalLinePlacement
	var speed_len: float
	var radiusm: float
	func _init(amount_: int, side_: HorizontalLineSide, placement_: HorizontalLinePlacement, speed_len_ := 1., radiusm_ := 1.):
		self.amount = amount_
		self.side = side_
		self.placement = placement_
		self.speed_len = speed_len_
		self.radiusm = radiusm_
	# Allows customisable width and height
	func _inner_raw_enemies(w: float, h: float) -> Array[EnemyToSpawn]:
		var radius := Formation.get_radius(radiusm)
		var positions := placement.positions(amount, radius, w)
		var enemies: Array[EnemyToSpawn] = []
		for pos in positions:
			var speed_y: float
			if side == HorizontalLineSide.Top:
				pos.y = -radius - pos.y
				speed_y = speed_len * BASE_SPEED
			else:
				pos.y = h + radius + pos.y
				speed_y = -speed_len * BASE_SPEED
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
		func _init(margin_: float = 0):
			self.margin = margin_
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.Distribute.new(margin)

	# Distribute enemies evenly, and make them V-shaped
	class V extends VerticalLinePlacement:
		# How much to vary x between enemies
		var dx: float
		var margin: float
		func _init(dx_: float, margin_: float = 0):
			self.dx = dx_
			self.margin = margin_
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.V.new(dx, margin)

	# Distribute enemies evenly, with a gap in the middle. Automatically balances enemies left and right.
	class Gap extends VerticalLinePlacement:
		# Center of the gap
		var center: float
		# Size of the gap
		var size: float
		func _init(center_: float, size_: float):
			self.center = center_
			self.size = size_
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
	var radiusm: float
	func _init(amount_: int, side_: VerticalLineSide, placement_: VerticalLinePlacement, speed_len_ := 1., radiusm_ := 1.):
		self.amount = amount_
		self.side = side_
		self.placement = placement_
		self.speed_len = speed_len_
		self.radiusm = radiusm_
	func raw_enemies() -> Array[EnemyToSpawn]:
		var horizontal_side := HorizontalLineSide.Top if side == VerticalLineSide.Left else HorizontalLineSide.Bottom
		var enemies := HorizontalLine.new(amount, horizontal_side, placement.convert(), speed_len, radiusm)._inner_raw_enemies(LevelBuilder.H, LevelBuilder.W)
		for enemy in enemies:
			enemy.pos = Vector2(enemy.pos.y, enemy.pos.x)
			enemy.speed = Vector2(enemy.speed.y, enemy.speed.x)
		return enemies

class Spiral extends Formation:
	var amount_in_circle: int
	var amount: int
	var spacing: float
	var starting_angle: float
	var speed_len: float
	var radiusm: float
	func _init(amount_in_circle_: int, amount_: int, spacing_: float, starting_angle_ := 0., speed_len_ := 1., radiusm_ := 1.):
		self.amount_in_circle = amount_in_circle_
		self.amount = amount_
		self.spacing = spacing_
		self.starting_angle = starting_angle_
		self.speed_len = speed_len_
		self.radiusm = radiusm_
	func raw_enemies() -> Array[EnemyToSpawn]:
		var radius := Formation.get_radius(radiusm)
		var enemies: Array[EnemyToSpawn] = []
		enemies.resize(amount)
		var center := Vector2(LevelBuilder.W / 2, LevelBuilder.H / 2)
		var screen_radius := center.length()
		for i in range(amount):
			var angle := Vector2(0, -1).rotated(i * 2 * PI / amount_in_circle)
			var pos := center + angle * (screen_radius + radius + i * spacing)
			var speed := -angle * speed_len * BASE_SPEED
			enemies[i] = EnemyToSpawn.new(radius, pos, speed)
		return enemies

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[EnemyToSpawn]:
	assert(false)
	return []
