class_name BuilderEvent

const IndicatorToSpawn = LevelEvent.IndicatorToSpawn
const EnemyToSpawn = LevelEvent.EnemyToSpawn
const LevelTime = LevelEvent.LevelTime
const EventWithTime = LevelEvent.EventWithTime

class Wait extends BuilderEvent:
	var secs: float
	func _init(t: float):
		secs = t
	func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
		cur_time.secs_after += secs
		return []

class WaitUntilNoEnemies extends BuilderEvent:
	func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
		cur_time.wait_until_no_enemies += 1
		cur_time.secs_after = 0
		return []

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
	func _init(enemy_: EnemyToSpawn, time_: LevelTime):
		self.enemy = enemy_
		self.time = time_

# This is done assuming squares and not circles, because the difference is minimal and the math is way simpler
func move_next_to_screen(cur_time: LevelTime, enemy: EnemyToSpawn) -> EnemyWithTime:
	var time_to_x := intersect_axis(enemy.pos.x - enemy.radius, enemy.pos.x + enemy.radius, 0, LevelBuilder.W, enemy.speed.x)
	var time_to_y := intersect_axis(enemy.pos.y - enemy.radius, enemy.pos.y + enemy.radius, 0, LevelBuilder.H, enemy.speed.y)
	# Must intersect screen at some point. This condition is not sufficient, but a good enough check.
	assert(time_to_x >= 0 && time_to_y >= 0)
	var time_to_screen := maxf(time_to_x, time_to_y)
	var time = cur_time.clone()
	time.secs_after += time_to_screen
	enemy.pos += enemy.speed * time_to_screen
	return EnemyWithTime.new(enemy, time)

# Assumes enemy is already compressed next to screen
func enemy_to_indicator(enemy: EnemyToSpawn) -> IndicatorToSpawn:
	const margin := 10
	var center = enemy.pos.clamp(Vector2(margin, margin), Vector2(LevelBuilder.W - margin, LevelBuilder.H - margin))
	return IndicatorToSpawn.new(center, enemy.speed.angle(), LevelEvent.enemy_type_to_color(enemy.type))

class Spawn extends BuilderEvent:
	var formation: Formation
	var indicator_time: float
	func _init(formation_: Formation, indicator_time_: float):
		formation = formation_
		indicator_time = indicator_time_
	func process_and_update_time(cur_time: LevelTime) -> Array[EventWithTime]:
		var raw_enemies := formation.raw_enemies()
		var enemies: Array[EnemyWithTime] = []
		enemies.assign(raw_enemies.map(func(e): return move_next_to_screen(cur_time, e)))
		enemies.sort_custom(func(a: EnemyWithTime, b: EnemyWithTime): return a.time.lt(b.time))
		# Dummy sentinel at the end so the algorithm below doesn't need special casing
		enemies.append(EnemyWithTime.new(EnemyToSpawn.new(0, Vector2(0, 0), Vector2(0, 0), LevelEvent.EnemyType.Basic1), LevelTime.new(ceili(1e9), INF)))
		var events: Array[EventWithTime] = []
		var last_enemies: Array[EnemyToSpawn] = []
		var last_time := enemies[0].time
		for enemy in enemies:
			if last_time.eq(enemy.time):
				last_enemies.append(enemy.enemy)
			else:
				events.append(EventWithTime.new(LevelEvent.Spawn.new(last_enemies), last_time))
				var ind_time = last_time.clone()
				ind_time.secs_after -= indicator_time
				var indicators: Array[IndicatorToSpawn] = []
				indicators.assign(last_enemies.map(enemy_to_indicator))
				events.append(EventWithTime.new(LevelEvent.Indicator.new(indicators, indicator_time), ind_time))
				last_time = enemy.time
				last_enemies = [enemy.enemy]
		return events

func process_and_update_time(_cur_time: LevelTime) -> Array[EventWithTime]:
	assert(false)
	return []
