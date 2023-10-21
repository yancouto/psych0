extends Node

# Level to run, let's start by hardcoding 1
var level: Level = preload("res://levels/level1.gd").new().build()
var next_event: LevelEvent.EventWithTime
var time_passed := 0.

func _ready() -> void:
	level.change_level_part.connect(_on_change_level_part)
	$Pausing.do_pause_unpause() # Start paused to show instructions

func _process(dt: float) -> void:
	dt = %BulletTime.fix_delta(dt)
	time_passed += dt
	$DebugTimePassed.text = "%.02fs" % time_passed
	if level != null && level.update($AllEnemies, dt):
		$LevelOverText.visible = true
		level = null

func _on_change_level_part(name: String) -> void:
	var tween = create_tween()
	tween.tween_property($LevelPart, 'position:y', -$LevelPart.size.y, 0 if $LevelPart.text.is_empty() else 0.5)
	tween.tween_callback(func(): $LevelPart.text = name)
	tween.tween_property($LevelPart, 'position:y', 10, 0.5)
