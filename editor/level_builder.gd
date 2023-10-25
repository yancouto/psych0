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

var prev_checkpoints := {}

# pos should be in the [0,4[ interval
# It will return a point around the screen, at distance from it
static func point_around_screen(pos: float, distance: float) -> Vector2:
	if pos < 1:
		return Vector2(pos * W, -distance)
	elif pos < 2:
		return Vector2(W + distance, (pos - 1) * H)
	elif pos < 3:
		return Vector2((3 - pos) * W, H + distance)
	else:
		assert(pos < 4)
		return Vector2(-distance, (4 - pos) * H)

func wait_until_no_enemies() -> void:
	events.append(BuilderEvent.WaitUntilNoEnemies.new())

func wait(secs: float) -> void:
	events.append(BuilderEvent.Wait.new(secs))

func checkpoint(name: StringName) -> void:
	assert(!prev_checkpoints.has(name), "No repeated checkpoints: %s" % name)
	prev_checkpoints[name] = true
	events.append(BuilderEvent.Checkpoint.new(name))

func level_part(name: String) -> void:
	# Every level part is also a checkpoint
	checkpoint(name)
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

# Probably not even necessary, but let's be safe as types can't guarantee
# the builder isn't modified when building
func clone() -> LevelBuilder:
	var builder := LevelBuilder.new()
	builder.events.assign(events.map(func(x): return x.clone()))
	builder.cur_indicator_time = cur_indicator_time
	return builder

func build() -> Level:
	var cur_time := LevelEvent.LevelTime.new(0, 0)
	var all_events: Array[LevelEvent.EventWithTime] = []
	for event in events:
		all_events.append_array(event.process_and_update_time(cur_time))
	all_events.append(LevelEvent.EventWithTime.new(LevelEvent.LastEvent.new(), cur_time))
	all_events.sort_custom(func(a, b): return a.time.lt(b.time))
	return Level.new(all_events)

func skip_till_checkpoint(checkpoint: StringName) -> bool:
	for i in events.size():
		if events[i] is BuilderEvent.Checkpoint and (events[i] as BuilderEvent.Checkpoint).name == checkpoint:
			events = events.slice(i)
			return true
	return false
