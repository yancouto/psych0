class_name LevelBuilder

static var W := 1600.
static var H := 900.

var events: Array[BuilderEvent] = []


func wait_until_no_enemies() -> void:
	events.append(BuilderEvent.WaitUntilNoEnemies.new())

func wait(secs: float) -> void:
	events.append(BuilderEvent.Wait.new(secs))

func spawn(f: Formation) -> void:
	events.append(BuilderEvent.Spawn.new(f))

# Debug only. Clears everything before this event.
func reset() -> void:
	events.clear()

func build() -> Level:
	var cur_time := LevelEvent.LevelTime.new(0, 0)
	var all_events: Array[LevelEvent.EventWithTime] = []
	for event in events:
		all_events.append_array(event.process_and_update_time(cur_time))
	all_events.append(LevelEvent.EventWithTime.new(LevelEvent.LastEvent.new(), cur_time))
	all_events.sort_custom(func(a, b): return a.time.lt(b.time))
	var events_with_delta: Array[LevelEvent.EventWithDelta] = []
	cur_time = LevelEvent.LevelTime.new(0, 0)
	for event in all_events:
		events_with_delta.append(LevelEvent.EventWithDelta.new(event.event, event.time.sub(cur_time)))
		cur_time = event.time
	return Level.new(events_with_delta)
