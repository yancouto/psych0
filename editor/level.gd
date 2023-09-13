class_name Level

static var W = 1600
static var H = 900

var events: Array[Event] = []
var cur_event: int = 0

func wait_until_no_enemies() -> void:
	events.append(Event.WaitUntilNoEnemies.new())

func wait(secs: float) -> void:
	events.append(Event.Wait.new(secs))

func spawn(f: Formation) -> void:
	events.append(Event.Spawn.new(f))

func next_event() -> Event:
	if cur_event == events.size():
		return null
	else:
		cur_event += 1
		return events[cur_event - 1]
