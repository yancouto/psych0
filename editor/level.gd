class_name Level

var events: Array[LevelEvent.EventWithDelta] = []
var cur_event: int = 0

func _init(events: Array[LevelEvent.EventWithDelta]):
	self.events = events

func next_event() -> LevelEvent.EventWithDelta:
	if cur_event == events.size():
		return null
	else:
		cur_event += 1
		return events[cur_event - 1]
