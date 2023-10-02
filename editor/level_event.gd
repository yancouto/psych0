class_name LevelEvent


class LevelTimeDelta:
	var wait_until_no_enemies: int
	var secs_after: float
	func _init(wait_until_no_enemies: int, secs_after: float):
		self.wait_until_no_enemies = wait_until_no_enemies
		self.secs_after = secs_after
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
	func _init(wait_until_no_enemies: int, secs_after: float):
		self.wait_until_no_enemies = wait_until_no_enemies
		self.secs_after = secs_after
	func clone() -> LevelTime:
		return LevelTime.new(wait_until_no_enemies, secs_after)
	func sub(other: LevelTime) -> LevelTimeDelta:
		if self.wait_until_no_enemies > other.wait_until_no_enemies:
			return LevelTimeDelta.new(wait_until_no_enemies - other.wait_until_no_enemies, self.secs_after)
		else:
			assert(self.wait_until_no_enemies == other.wait_until_no_enemies)
			return LevelTimeDelta.new(0, self.secs_after - other.secs_after)

class EventWithTime:
	var event: LevelEvent
	var time: LevelTime
	func _init(event: LevelEvent, time: LevelTime):
		self.event = event
		self.time = time

class EventWithDelta:
	var event: LevelEvent
	var delta: LevelTimeDelta
	func _init(event: LevelEvent, delta: LevelTimeDelta):
		self.event = event
		self.delta = delta
	func trigger(root: Node, dt: float) -> bool:
		var trigger_now := self.delta.sub(root, dt)
		if trigger_now:
			self.event.trigger(root)
		return trigger_now

class EnemyToSpawn:
	var radius: float
	var pos: Vector2
	var speed: Vector2
	func _init(radius: float, pos: Vector2, speed: Vector2):
		self.radius = radius
		self.pos = pos
		self.speed = speed
	func spawn(root: Node) -> void:
		var enemy = preload("res://enemy.tscn").instantiate()
		enemy.radius = radius
		enemy.start(pos, speed)
		root.add_child(enemy)

# Does nothing, just added in the end always, so we can wait for no enemies
class LastEvent extends LevelEvent:
	func trigger(root: Node) -> bool:
		return true

class Spawn extends LevelEvent:
	var to_spawn: Array[EnemyToSpawn]
	func _init(to_spawn: Array[EnemyToSpawn]):
		self.to_spawn = to_spawn
	func trigger(root: Node) -> bool:
		for enemy in to_spawn:
			enemy.spawn(root)
		return true

func trigger(_root: Node) -> bool:
	# must be implemented
	assert(false)
	return false
