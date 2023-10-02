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

class Spawn extends BuilderEvent:
	var formation: Formation
	func _init(f: Formation):
		formation = f
	func trigger(root: Node, dt: float) -> bool:
		return formation.trigger(root, dt)
	func process_and_update_time(cur_time: LevelEvent.LevelTime) -> Array[LevelEvent.EventWithTime]:
		var raw_enemies := formation.raw_enemies()
		# TODO: "compress" enemies to get them close to screen, and also create indicators
		return [LevelEvent.EventWithTime.new(LevelEvent.Spawn.new(raw_enemies), cur_time.clone())]

func process_and_update_time(cur_time: LevelEvent.LevelTime) -> Array[LevelEvent.EventWithTime]:
	assert(false)
	return []
