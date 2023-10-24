class_name LevelEvent

enum EnemyType { Basic1, Basic3 }

class LevelTimeDelta:
	var wait_until_no_enemies: int
	var secs_after: float
	func _init(wait_until_no_enemies_: int, secs_after_: float):
		self.wait_until_no_enemies = wait_until_no_enemies_
		self.secs_after = secs_after_
	func sub(root: Node, dt: float) -> bool:
		if self.wait_until_no_enemies > 0:
			if root.get_child_count() == 0:
				self.wait_until_no_enemies -= 1
		if self.wait_until_no_enemies <= 0:
			self.secs_after -= dt
		return self.wait_until_no_enemies <= 0 && self.secs_after <= 0

class LevelTime:
	var wait_until_no_enemies: int
	var secs_after: float
	func _init(wait_until_no_enemies_: int, secs_after_: float):
		self.wait_until_no_enemies = wait_until_no_enemies_
		self.secs_after = secs_after_
	func clone() -> LevelTime:
		return LevelTime.new(wait_until_no_enemies, secs_after)
	func lt(other: LevelTime) -> bool:
		if self.wait_until_no_enemies == other.wait_until_no_enemies:
			return self.secs_after < other.secs_after
		else:
			return self.wait_until_no_enemies < other.wait_until_no_enemies
	func eq(other: LevelTime) -> bool:
		return self.wait_until_no_enemies == other.wait_until_no_enemies && is_equal_approx(self.secs_after, other.secs_after)
	# If it reached the event, return the excess time, otherwise return -1
	func reaches(root: Node, other: LevelTime) -> float:
		if other.wait_until_no_enemies > wait_until_no_enemies:
			if root.get_child_count() == 0:
				wait_until_no_enemies = other.wait_until_no_enemies
				secs_after = 0
		if other.wait_until_no_enemies <= wait_until_no_enemies:
			if secs_after == 0 && other.secs_after < 0:
				# Makes it work with initial negative times
				secs_after = other.secs_after
		if wait_until_no_enemies >= other.wait_until_no_enemies && secs_after >= other.secs_after:
			return secs_after - other.secs_after
		else:
			return -1.

class EventWithTime:
	var event: LevelEvent
	var time: LevelTime
	func _init(event_: LevelEvent, time_: LevelTime):
		self.event = event_
		self.time = time_

# TODO: On more complex enemies, this will need to be redone because we'll
# need to instantiate a different scene
static func map_enemy_type(type: EnemyType) -> BasicEnemy.Type:
	match type:
		EnemyType.Basic1:
			return BasicEnemy.Type.One
		EnemyType.Basic3:
			return BasicEnemy.Type.Three
		_:
			assert(false, "Unkown enemy type")
			return BasicEnemy.Type.One

static func enemy_type_to_color(type: EnemyType) -> Color:
	match type:
		EnemyType.Basic1:
			return Color.SEA_GREEN
		EnemyType.Basic3:
			return Color.YELLOW
		_:
			assert(false, "Invalid enemy type")
			return Color()

# Speed that may depend on player position
class Speed:
	func length() -> float:
		assert(false, "Must be implemented")
		return 0
	func calc(cur_pos: Vector2, player_pos: Vector2) -> Vector2:
		assert(false, "Must be implemented")
		return Vector2.ZERO
	func multiply(factor: float) -> Speed:
		assert(false, "Must be implemented")
		return Speed.new()
	func swap_coordinates() -> Speed:
		assert(false, "Must be implemented")
		return Speed.new()
	static func from_vec(speed: Vector2) -> Speed:
		return BasicSpeed.new(speed.x, speed.y)

class BasicSpeed extends Speed:
	var speed: Vector2
	func _init(x: float, y: float):
		speed = Vector2(x, y)
	func calc(_cur_pos: Vector2, _player_pos: Vector2) -> Vector2:
		return speed
	func multiply(factor: float) -> Speed:
		return BasicSpeed.new(speed.x * factor, speed.y * factor)
	func swap_coordinates() -> Speed:
		return BasicSpeed.new(speed.y, speed.x)
	func length() -> float:
		return speed.length()

class FollowPlayer extends Speed:
	var speed_len: float
	func _init(speed_len_: float):
		speed_len = speed_len_
	func calc(cur_pos: Vector2, player_pos: Vector2) -> Vector2:
		return (player_pos - cur_pos).normalized() * speed_len
	func multiply(factor: float) -> Speed:
		return FollowPlayer.new(speed_len * factor)
	func swap_coordinates() -> Speed:
		return FollowPlayer.new(speed_len)
	func length() -> float:
		return speed_len

class EnemyToSpawn:
	var radius: float
	var pos: Vector2
	var speed: Speed
	var type: EnemyType
	func _init(radius_: float, pos_: Vector2, speed_: Speed, type_: EnemyType):
		self.radius = radius_
		self.pos = pos_
		self.speed = speed_
		self.type = type_
	func spawn(root: Node, ago: float) -> void:
		var enemy = preload("res://enemies/basic.tscn").instantiate()
		enemy.start(pos, speed.calc(pos, root.get_node('../%Player').position), radius, LevelEvent.map_enemy_type(type))
		enemy.position += enemy.speed * ago
		root.add_child(enemy)

class IndicatorToSpawn:
	# On the edge of the screen
	var center: Vector2
	var speed: Speed
	var color: Color
	func _init(center_: Vector2, speed_: Speed, color_: Color):
		self.center = center_
		self.speed = speed_
		self.color = color_

# Does nothing, just added in the end always, so we can wait for no enemies
class LastEvent extends LevelEvent:
	func trigger(_level: Level, _root: Node, _ago: float) -> bool:
		return true

class LevelPart extends LevelEvent:
	var name: String
	func _init(name_: String):
		name = name_
	func trigger(level: Level, _root: Node, _ago: float) -> bool:
		level.change_level_part.emit(name)
		return true

class Spawn extends LevelEvent:
	var to_spawn: Array[EnemyToSpawn]
	func _init(to_spawn_: Array[EnemyToSpawn]):
		self.to_spawn = to_spawn_
	func trigger(_level: Level, root: Node, ago: float) -> bool:
		for enemy in to_spawn:
			enemy.spawn(root, ago)
		return true

class Indicator extends LevelEvent:
	var to_spawn: Array[IndicatorToSpawn]
	var duration: float
	func _init(to_spawn_: Array[IndicatorToSpawn], duration_: float):
		self.to_spawn = to_spawn_
		self.duration = duration_
	func trigger(_level: Level, root: Node, ago: float) -> bool:
		const IndicatorNode = preload("res://indicator.tscn")
		for ind_to_spawn in to_spawn:
			var indicator = IndicatorNode.instantiate()
			indicator.start(ind_to_spawn, self.duration - ago)
			root.add_child(indicator)
		return true

# Trigger the event, the event should have happened ago seconds ago
func trigger(_level: Level, _root: Node, _ago: float) -> bool:
	assert(false, "Must be implemented by all subclasses")
	return false
