class_name Formation

const EnemyToSpawn = LevelEvent.EnemyToSpawn
const EnemyType = LevelEvent.EnemyType
const Speed = LevelEvent.Speed

const BASE_SPEED := 400.
const BASE_RADIUS := 30.
const SQ2 := sqrt(2)

static func get_speed(speedm: Speed) -> Speed:
	return speedm.multiply(BASE_SPEED)


static func get_radius(radiusm: float) -> float:
	return radiusm * BASE_RADIUS

static func single() -> Single:
	return Single.new()

class Single extends Formation:
	var position_ := Vector2.ZERO
	var speedm_ := Speed.from_vec(Vector2(SQ2, SQ2))
	var radiusm_ := 1.
	var type_ := EnemyType.Basic1
	func position(position__: Vector2) -> Single:
		position_ = position__
		return self
	func speedm(speedm__: Speed) -> Single:
		speedm_ = speedm__
		return self
	func radiusm(radiusm__: float) -> Single:
		radiusm_ = radiusm__
		return self
	func type(type__: EnemyType) -> Single:
		type_ = type__
		return self
	func raw_enemies() -> Array[EnemyToSpawn]:
		return [EnemyToSpawn.new(Formation.get_radius(radiusm_), position_, Formation.get_speed(speedm_), type_)]

static func get_enemy(enemies: Array[EnemyType], i: int) -> EnemyType:
	if enemies.is_empty():
		return EnemyType.Basic1
	else:
		return enemies[i % enemies.size()]

static func multiple(amount: int) -> Multiple:
	return Multiple.new(amount)

# Multiple enemies in a line, one after another
class Multiple extends Formation:
	var _amount: int
	# Position of the closest enemy to the screen
	var _pos := Vector2.ZERO
	# Speed of all enemies
	var _speedm := Speed.from_vec(Vector2(SQ2, SQ2))
	# Direction the line should spawn to (usually, opposite of speed)
	var _dir := Vector2(-SQ2, -SQ2)
	# Distance between enemies
	var _spacing := 100.
	# Enemy radius
	var _radiusm := 1.
	var _types: Array[EnemyType]
	func _init(amount_: int):
		_amount = amount_
	func pos(pos_: Vector2) -> Multiple:
		_pos = pos_
		return self
	func speedm(speedm_: Speed) -> Multiple:
		_speedm = speedm_
		return self
	func dir(dir_: Vector2) -> Multiple:
		_dir = dir_.normalized()
		return self
	func spacing(spacing_: float) -> Multiple:
		_spacing = spacing_
		return self
	func radiusm(radiusm_: float) -> Multiple:
		_radiusm = radiusm_
		return self
	func types(types_: Array[EnemyType]) -> Multiple:
		_types = types_
		return self
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var speed := Formation.get_speed(_speedm)
		var radius := Formation.get_radius(_radiusm)
		for i in range(_amount):
			enemies.append(EnemyToSpawn.new(radius, _pos + _dir * i * (_spacing + 2 * radius), speed, Formation.get_enemy(_types, i)))
		return enemies

static func radius_from_center(center: Vector2) -> float:
	if center == LevelBuilder.MIDDLE:
		return center.length()
	else:
		var biggest := 0.0
		for corner in LevelBuilder.CORNERS:
			biggest = maxf(biggest, (center - corner).length_squared())
		return sqrt(biggest)

static func circle(amount: int) -> Circle:
	return Circle.new(amount)

class Circle extends Formation:
	var _amount: int
	var _starting_angle := 0.
	var _speedm_len := 1.
	var _types: Array[EnemyType]
	var _follow_player := false
	var _center := LevelBuilder.MIDDLE
	func _init(amount_: int) -> void:
		_amount = amount_
	func starting_angle(starting_angle_: float) -> Circle:
		_starting_angle = starting_angle_
		return self
	func speedm_len(speedm_len_: float) -> Circle:
		_speedm_len = speedm_len_
		return self
	func types(types_: Array[EnemyType]) -> Circle:
		_types = types_
		return self
	func follow_player(follow_player_ := true) -> Circle:
		_follow_player = follow_player_
		return self
	func center(center_: Vector2) -> Circle:
		_center = center_
		return self
	func center_x(x: float) -> Circle:
		_center.x = x
		return self
	func raw_enemies() -> Array[EnemyToSpawn]:
		var enemies: Array[EnemyToSpawn] = []
		var n := _amount
		enemies.resize(n)
		# TODO: Make customisable
		const enemy_radius := BASE_RADIUS
		var circle_radius := enemy_radius + radius_from_center(_center)
		for i in range(n):
			var angle := Vector2(0, -1).rotated(_starting_angle + i * (TAU / n))
			var pos := _center + angle * circle_radius
			var speed: Speed
			if _follow_player:
				speed = LevelEvent.FollowPlayer.new(_speedm_len * BASE_SPEED)
			else:
				speed = LevelEvent.Speed.from_vec(-angle * _speedm_len * BASE_SPEED)
			enemies[i] = EnemyToSpawn.new(enemy_radius, pos, speed, Formation.get_enemy(_types, i))
		return enemies


enum HorizontalLineSide { Top, Bottom }

class HorizontalLinePlacement:
	# Distribute enemies evenly in the screen
	class Distribute extends HorizontalLinePlacement:
		# Margin from the leftmost and rightmost enemy to the side of the screen
		var margin_left: float
		var margin_right: float
		func _init(margin_left_: float = 0, margin_right_: float = -1.):
			self.margin_left = margin_left_
			if margin_right_ == -1.:
				margin_right_ = margin_left_
			self.margin_right = margin_right_
		func positions(n: int, radius: float, len: float) -> Array[Vector2]:
			if n == 1:
				return [Vector2(len / 2, 0)]
			var pos: Array[Vector2] = []
			len -= margin_left + margin_right
			for i in range(n):
				var dist := (len - 2 * n * radius) / (n - 1)
				var x := i * dist + radius * (2 * i + 1)
				pos.append(Vector2(x + margin_left, 0))
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
		func _init(size_: float, center_: float) -> void:
			self.size = size_
			self.center = center_
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

static func horizontal_line(amount: int) -> HorizontalLine:
	return HorizontalLine.new(amount)

class HorizontalLine extends Formation:
	var _amount: int
	var _side := HorizontalLineSide.Top
	var _placement: HorizontalLinePlacement = HorizontalLinePlacement.Distribute.new()
	var _speedm_len := 1.
	var _radiusm := 1.
	var _types: Array[EnemyType]
	var _follow_player := false
	func _init(amount_: int):
		_amount = amount_
	func side(side_: HorizontalLineSide) -> HorizontalLine:
		_side = side_
		return self
	func top() -> HorizontalLine:
		return side(HorizontalLineSide.Top)
	func bottom() -> HorizontalLine:
		return side(HorizontalLineSide.Bottom)
	func placement(placement_: HorizontalLinePlacement) -> HorizontalLine:
		_placement = placement_
		return self
	func distribute(left_margin := 0., right_margin := -1.) -> HorizontalLine:
		return placement(HorizontalLinePlacement.Distribute.new(left_margin, right_margin))
	func v(dy: float, margin := 0.) -> HorizontalLine:
		return placement(HorizontalLinePlacement.V.new(dy, margin))
	func gap(size: float, center := LevelBuilder.W / 2) -> HorizontalLine:
		return placement(HorizontalLinePlacement.Gap.new(size, center))
	func speedm_len(speedm_len_: float) -> HorizontalLine:
		_speedm_len = speedm_len_
		return self
	func radiusm(radiusm_: float) -> HorizontalLine:
		_radiusm = radiusm_
		return self
	func types(types_: Array[EnemyType]) -> HorizontalLine:
		_types = types_
		return self
	func follow_player(follow_player_ := true) -> HorizontalLine:
		_follow_player = follow_player_
		return self
	# Allows customisable width and height
	func _inner_raw_enemies(w: float, h: float) -> Array[EnemyToSpawn]:
		var radius := Formation.get_radius(_radiusm)
		var positions := _placement.positions(_amount, radius, w)
		var enemies: Array[EnemyToSpawn] = []
		for i in positions.size():
			var pos := positions[i]
			var speed_y: float
			if _side == HorizontalLineSide.Top:
				pos.y = -radius - pos.y
				speed_y = _speedm_len * BASE_SPEED
			else:
				pos.y = h + radius + pos.y
				speed_y = -_speedm_len * BASE_SPEED
			var speed: Speed = LevelEvent.BasicSpeed.new(0, speed_y) if !_follow_player else LevelEvent.FollowPlayer.new(absf(speed_y))
			enemies.append(EnemyToSpawn.new(radius, pos, speed, Formation.get_enemy(_types, i)))
		return enemies
	func raw_enemies() -> Array[EnemyToSpawn]:
		return _inner_raw_enemies(LevelBuilder.W, LevelBuilder.H)

enum VerticalLineSide { Left, Right }

class VerticalLinePlacement:
	# Distribute enemies evenly in the screen
	class Distribute extends VerticalLinePlacement:
		# Margin from the topmost and bottommost enemy to the side of the screen
		var margin_top: float
		var margin_bottom: float
		func _init(margin_top_: float = 0, margin_bottom_: float = -1.):
			self.margin_top = margin_top_
			if margin_bottom_ == -1.:
				margin_bottom_ = margin_top_
			self.margin_bottom = margin_bottom_
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.Distribute.new(margin_top, margin_bottom)

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
		func _init(size_: float, center_: float) -> void:
			self.center = center_
			self.size = size_
		func convert() -> HorizontalLinePlacement:
			return HorizontalLinePlacement.Gap.new(size, center)

	# Convert to Horizontal, to minimise code duplication. Remember to swap x and y
	func convert() -> HorizontalLinePlacement:
		assert(false, "Must be implemented on all subclasses")
		return null

static func vertical_line(amount: int) -> VerticalLine:
	return VerticalLine.new(amount)

class VerticalLine extends Formation:
	var _amount: int
	var _side: VerticalLineSide = VerticalLineSide.Left
	var _placement: VerticalLinePlacement = VerticalLinePlacement.Distribute.new()
	var _speedm_len := 1.
	var _radiusm := 1.
	var _types: Array[EnemyType]
	var _follow_player := false
	func _init(amount_: int) -> void:
		_amount = amount_
	func side(side_: VerticalLineSide) -> VerticalLine:
		_side = side_
		return self
	func left() -> VerticalLine:
		return side(VerticalLineSide.Left)
	func right() -> VerticalLine:
		return side(VerticalLineSide.Right)
	func placement(placement_: VerticalLinePlacement) -> VerticalLine:
		_placement = placement_
		return self
	func distribute(top_margin := 0., bottom_margin := -1.) -> VerticalLine:
		return placement(VerticalLinePlacement.Distribute.new(top_margin, bottom_margin))
	func v(dx: float, margin := 0.) -> VerticalLine:
		return placement(VerticalLinePlacement.V.new(dx, margin))
	func gap(size: float, center := LevelBuilder.H / 2) -> VerticalLine	:
		return placement(VerticalLinePlacement.Gap.new(size, center))
	func speedm_len(speedm_len_: float) -> VerticalLine:
		_speedm_len = speedm_len_
		return self
	func radiusm(radiusm_: float) -> VerticalLine:
		_radiusm = radiusm_
		return self
	func types(types_: Array[EnemyType]) -> VerticalLine:
		_types = types_
		return self
	func follow_player(follow_player_ := true) -> VerticalLine:
		_follow_player = follow_player_
		return self
	func raw_enemies() -> Array[EnemyToSpawn]:
		var horizontal_side := HorizontalLineSide.Top if _side == VerticalLineSide.Left else HorizontalLineSide.Bottom
		var enemies := Formation.horizontal_line(_amount).side(horizontal_side).placement(_placement.convert()).speedm_len(_speedm_len).radiusm(_radiusm).types(_types).follow_player(_follow_player)._inner_raw_enemies(LevelBuilder.H, LevelBuilder.W)
		for enemy in enemies:
			enemy.pos = Vector2(enemy.pos.y, enemy.pos.x)
			enemy.speed = enemy.speed.swap_coordinates()
		return enemies

static func spiral(amount: int) -> Spiral:
	return Spiral.new(amount)

class Spiral extends Formation:
	var _amount: int
	# How many balls in the original circle the spiral is based on
	var _circle_amount: int
	# TODO: Does spacing need a multiplier?
	var _spacing := 100.
	var _starting_angle := 0.
	var _speedm_len := 1.
	var _radiusm := 1.
	var _types: Array[EnemyType]
	var _dir: float = 1.
	var _center := LevelBuilder.MIDDLE
	func _init(amount_: int) -> void:
		_amount = amount_
		_circle_amount = amount_
	func circle_amount(circle_amount_: int) -> Spiral:
		_circle_amount = circle_amount_
		return self
	func spacing(spacing_: float) -> Spiral:
		_spacing = spacing_
		return self
	func starting_angle(starting_angle_: float) -> Spiral:
		_starting_angle = starting_angle_
		return self
	func speedm_len(speedm_len_: float) -> Spiral:
		_speedm_len = speedm_len_
		return self
	func radiusm(radiusm_: float) -> Spiral:
		_radiusm = radiusm_
		return self
	func types(types_: Array[EnemyType]) -> Spiral:
		_types = types_
		return self
	func invert() -> Spiral:
		_dir = -_dir
		return self
	func center(center_: Vector2) -> Spiral:
		_center = center_
		return self
	func raw_enemies() -> Array[EnemyToSpawn]:
		var radius := Formation.get_radius(_radiusm)
		var enemies: Array[EnemyToSpawn] = []
		enemies.resize(_amount)

		var screen_radius := radius_from_center(_center)
		for i in _amount:
			var angle := Vector2(0, -1).rotated(_starting_angle + i * 2 * PI * _dir / _circle_amount)
			var pos := _center + angle * (screen_radius + radius + i * _spacing)
			var speed := -angle * _speedm_len * BASE_SPEED
			enemies[i] = EnemyToSpawn.new(radius, pos, LevelEvent.BasicSpeed.from_vec(speed), Formation.get_enemy(_types, i))
		return enemies

# All enemies that should be spawned at exactly the same time
func raw_enemies() -> Array[EnemyToSpawn]:
	assert(false, "Must be implemented")
	return []

# Let's trust our formations are immutable, though there will be bugs if they're not
func clone() -> Formation:
	return self
