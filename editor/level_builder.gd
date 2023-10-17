class_name LevelBuilder

static var W := 1440.
static var H := 1080.
static var BASE_INDICATOR_TIME := 2.0

var events: Array[BuilderEvent] = []
var cur_indicator_time := BASE_INDICATOR_TIME


func wait_until_no_enemies() -> void:
	events.append(BuilderEvent.WaitUntilNoEnemies.new())

func wait(secs: float) -> void:
	events.append(BuilderEvent.Wait.new(secs))

func spawn(f: Formation) -> void:
	events.append(BuilderEvent.Spawn.new(f, cur_indicator_time))

func set_indicator_time(indicator_time: float) -> void:
	cur_indicator_time = indicator_time

func reset_indicator_time() -> void:
	set_indicator_time(LevelBuilder.BASE_INDICATOR_TIME)

# Debug only. Clears everything before this event.
func reset() -> void:
	events.clear()
	events.append(BuilderEvent.Wait.new(BASE_INDICATOR_TIME))

func build() -> Level:
	var cur_time := LevelEvent.LevelTime.new(0, 0)
	var all_events: Array[LevelEvent.EventWithTime] = []
	for event in events:
		all_events.append_array(event.process_and_update_time(cur_time))
	all_events.append(LevelEvent.EventWithTime.new(LevelEvent.LastEvent.new(), cur_time))
	all_events.sort_custom(func(a, b): return a.time.lt(b.time))
	return Level.new(all_events)
