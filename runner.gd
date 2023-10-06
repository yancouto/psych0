extends Node

# Level to run, let's start by hardcoding 1
var level: Level = preload("res://levels/level1.gd").new().build()
var next_event: LevelEvent.EventWithTime

func _process(dt: float) -> void:
	if level != null && level.update($AllEnemies, dt):
		$LevelOverText.visible = true
		level = null
