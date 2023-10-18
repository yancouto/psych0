class_name LevelBuilder

const W := 1440.
const H := 1080.
const TOP_LEFT := Vector2.ZERO
const TOP_RIGHT := Vector2(W, 0)
const BOTTOM_RIGHT := Vector2(W, H)
const BOTTOM_LEFT := Vector2(0, H)
const CORNERS: Array[Vector2] = [TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT]
const MIDDLE := BOTTOM_RIGHT / 2.
const BASE_INDICATOR_TIME := 2.0

var events: Array[BuilderEvent] = []
var cur_indicator_time := BASE_INDICATOR_TIME


func wait_until_no_enemies() -> void:
	events.append(BuilderEvent.WaitUntilNoEnemies.new())

func wait(secs: float) -> void:
	events.append(BuilderEvent.Wait.new(secs))

func level_part(name: String) -> void:
	events.append(BuilderEvent.LevelPart.new(name))

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
