class_name BuilderEvent

const IndicatorToSpawn = LevelEvent.IndicatorToSpawn
const EnemyToSpawn = LevelEvent.EnemyToSpawn
const LevelTime = LevelEvent.LevelTime
const EventWithTime = LevelEvent.EventWithTime

class Wait extends BuilderEvent:
	var secs: float
	func _init(t: float):
		secs = t
	func trigger(root: Node, dt: float) -> bool:
		secs -= dt
		return secs <= 0
	func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
		cur_time.secs_after += secs
		return []

class WaitUntilNoEnemies extends BuilderEvent:
	func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
		cur_time.wait_until_no_enemies += 1
		return []
	func trigger(root: Node, _dt: float) -> bool:
		return root.get_child_count() == 0

# In 1D, when will segment s1 intersect segment s2 if it moves with speed speed
func intersect_axis(s1l: float, s1r: float, s2l: float, s2r: float, speed: float) -> float:
	if s1r < s2l:
		# Totally to the left
		return (s2l - s1r) / speed
	elif s1l > s2r:
		# Totally to the right
		return (s1l - s2r) / -speed
	else:
		# already intersects
		return 0

class EnemyWithTime:
	var enemy: EnemyToSpawn
	var time: LevelTime
	func _init(enemy: EnemyToSpawn, time: LevelTime):
		self.enemy = enemy
		self.time = time

# This is done assuming squares and not circles, because the difference is minimal and the math is way simpler
func move_next_to_screen(cur_time: LevelTime, enemy: EnemyToSpawn) -> EnemyWithTime:
	var time_to_x := intersect_axis(enemy.pos.x - enemy.radius, enemy.pos.x + enemy.radius, 0, LevelBuilder.W, enemy.speed.x)
	var time_to_y := intersect_axis(enemy.pos.y - enemy.radius, enemy.pos.y + enemy.radius, 0, LevelBuilder.H, enemy.speed.y)
	# Must intersect screen at some point. This condition is not sufficient, but good enough check.
	assert(time_to_x >= 0 && time_to_y >= 0)
	var time_to_screen: float = max(time_to_x, time_to_y)
	var time = cur_time.clone()
	time.secs_after += time_to_screen
	enemy.pos += enemy.speed * time_to_screen
	return EnemyWithTime.new(enemy, time)

class Spawn extends BuilderEvent:
	var formation: Formation
	func _init(f: Formation):
		formation = f
	func trigger(root: Node, dt: float) -> bool:
		return formation.trigger(root, dt)
	func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
		var raw_enemies := formation.raw_enemies()
		# TODO: Create indicators
		var enemies: Array[EnemyWithTime]
		enemies.assign(raw_enemies.map(func(e): return move_next_to_screen(cur_time, e)))
		enemies.sort_custom(func(a: EnemyWithTime, b: EnemyWithTime): return a.time.lt(b.time))
		if enemies.is_empty():
			return []
		var events: Array[EventWithTime] = []
		var last_enemies: Array[EnemyToSpawn] = []
		var last_time := enemies[0].time
		for enemy in enemies:
			if last_time.eq(enemy.time):
				last_enemies.append(enemy.enemy)
			else:
				events.append(EventWithTime.new(LevelEvent.Spawn.new(last_enemies), last_time))
				last_time = enemy.time
				last_enemies = [enemy.enemy]
		events.append(EventWithTime.new(LevelEvent.Spawn.new(last_enemies), last_time))
		return events

func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
	assert(false)
	return []
