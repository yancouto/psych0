class_name LevelEvent


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

class EnemyToSpawn:
	var radius: float
	var pos: Vector2
	var speed: Vector2
	func _init(radius_: float, pos_: Vector2, speed_: Vector2):
		self.radius = radius_
		self.pos = pos_
		self.speed = speed_
	func spawn(root: Node, ago: float) -> void:
		var enemy = preload("res://enemy.tscn").instantiate()
		enemy.start(pos, speed, radius)
		enemy.position += enemy.speed * ago
		root.add_child(enemy)

class IndicatorToSpawn:
	# On the edge of the screen
	var center: Vector2
	var angle: float
	func _init(center_: Vector2, angle_: float):
		self.center = center_
		self.angle = angle_

# Does nothing, just added in the end always, so we can wait for no enemies
class LastEvent extends LevelEvent:
	func trigger(_root: Node, _ago: float) -> bool:
		return true

class Spawn extends LevelEvent:
	var to_spawn: Array[EnemyToSpawn]
	func _init(to_spawn_: Array[EnemyToSpawn]):
		self.to_spawn = to_spawn_
	func trigger(root: Node, ago: float) -> bool:
		for enemy in to_spawn:
			enemy.spawn(root, ago)
		return true

class Indicator extends LevelEvent:
	var to_spawn: Array[IndicatorToSpawn]
	var duration: float
	func _init(to_spawn_: Array[IndicatorToSpawn], duration_: float):
		self.to_spawn = to_spawn_
		self.duration = duration_
	func trigger(root: Node, ago: float) -> bool:
		const IndicatorNode = preload("res://indicator.tscn")
		for ind_to_spawn in to_spawn:
			var indicator = IndicatorNode.instantiate()
			indicator.start(ind_to_spawn, self.duration - ago)
			root.add_child(indicator)
		return true

# Trigger the event, the event should have happened ago seconds ago
func trigger(_root: Node, _ago: float) -> bool:
	assert(false, "Must be implemented by all subclasses")
	return false
