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
