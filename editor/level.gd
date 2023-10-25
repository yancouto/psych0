class_name Level

var events: Array[LevelEvent.EventWithTime] = []
var cur_event: int = 0
var cur_time := LevelEvent.LevelTime.new(0, 0)

func _init(events_: Array[LevelEvent.EventWithTime]):
	self.events = events_

signal change_level_part(name: String)

func update(root: Node, dt: float) -> bool:
	cur_time.secs_after += dt
	while cur_event < events.size():
		var excess = cur_time.reaches(root, events[cur_event].time)
		# Event not reached
		if excess == -1:
			break
		events[cur_event].event.trigger(self, root, excess)
		cur_event += 1
	return cur_event == events.size()

func clone() -> Level:
	var events2: Array[LevelEvent.EventWithTime]
	events2.assign(events.map(func(e): return e.clone()))
	return Level.new(events2)

func skip_till_level_part(name: String) -> bool:
	for i in events.size():
		if events[i].event is LevelEvent.LevelPart and (events[i].event as LevelEvent.LevelPart).name == name:
			events = events.slice(i)
			return true
	return false
