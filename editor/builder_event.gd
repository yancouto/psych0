class_name BuilderEvent

class Wait extends BuilderEvent:
	var secs: float
	func _init(t: float):
		secs = t
	func trigger(root: Node, dt: float) -> bool:
		secs -= dt
		return secs <= 0
	func process_and_update_time(cur_time: LevelEvent.LevelTime) -> Array[LevelEvent.EventWithTime]:
		cur_time.secs_after += secs
		return []

class WaitUntilNoEnemies extends BuilderEvent:
	func process_and_update_time(cur_time: LevelEvent.LevelTime) -> Array[LevelEvent.EventWithTime]:
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

func move_next_to_screen(cur_time: LevelEvent.LevelTime, enemy: LevelEvent.EnemyToSpawn) -> LevelEvent.EventWithTime:
	var time_to_x := intersect_axis(enemy.pos.x - enemy.radius, enemy.pos.x + enemy.radius, 0, LevelBuilder.W, enemy.speed.x)
	var time_to_y := intersect_axis(enemy.pos.y - enemy.radius, enemy.pos.y + enemy.radius, 0, LevelBuilder.H, enemy.speed.y)
	# Must intersect screen at some point. This condition is not sufficient, but good enough check.
	assert(time_to_x >= 0 && time_to_y >= 0)
	var time_to_screen: float = max(time_to_x, time_to_y)
	var time = cur_time.clone()
	time.secs_after += time_to_screen
	enemy.pos += enemy.speed * time_to_screen
	return LevelEvent.EventWithTime.new(LevelEvent.Spawn.new([enemy]), time)

class Spawn extends BuilderEvent:
	var formation: Formation
	func _init(f: Formation):
		formation = f
	func trigger(root: Node, dt: float) -> bool:
		return formation.trigger(root, dt)
	func process_and_update_time(cur_time: LevelEvent.LevelTime) -> Array[LevelEvent.EventWithTime]:
		var raw_enemies := formation.raw_enemies()
		# TODO: Create indicators
		var enemies: Array[LevelEvent.EventWithTime]
		enemies.assign(raw_enemies.map(func(e): return move_next_to_screen(cur_time, e)))
		# TODO: "compress" enemies with same time to a single spawn to optimise
		# enemies.sort_custom(func(a, b): return a.time.lt(b.time))
		return enemies

func process_and_update_time(cur_time: LevelEvent.LevelTime) -> Array[LevelEvent.EventWithTime]:
	assert(false)
	return []
