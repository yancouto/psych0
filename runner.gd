extends Node

# Level to run, let's start by hardcoding 1
var level: Level = preload("res://levels/level1.gd").new().build()
var next_event: LevelEvent.EventWithDelta

func _ready() -> void:
	next_event = level.next_event()

func _process(dt: float) -> void:
	if next_event != null && next_event.trigger($AllEnemies, dt):
		next_event = level.next_event()
	if next_event == null:
		$LevelOverText.visible = true

