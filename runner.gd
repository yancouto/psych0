extends Node

# Level to run, let's start by hardcoding 1
var builder: LevelBuilder = preload("res://levels/level1.gd").new()
var level: Level = builder.clone().build()
var next_event: LevelEvent.EventWithTime
var time_passed := 0.
var cur_level_part: String

func _ready() -> void:
	level.change_level_part.connect(_on_change_level_part)
	$Pausing.do_pause_unpause() # Start paused to show instructions
	fix_bg_color()

func fix_bg_color() -> void:
	var back_color: Color = $Player/ColorChanger.get_color()
	back_color.h = fmod(back_color.h + .5, 1.)
	back_color.v = 0.1
	back_color.s = 0.9
	RenderingServer.set_default_clear_color(back_color)
	
func _process(dt: float) -> void:
	dt = %BulletTime.fix_delta(dt)
	time_passed += dt
	$DebugTimePassed.text = "%.02fs" % time_passed
	if level != null && level.update($AllEnemies, dt):
		$LevelOverText.visible = true
		level = null
	fix_bg_color()

func _on_change_level_part(name: String) -> void:
	print("Reaching %s" % name)
	cur_level_part = name
	var tween = create_tween()
	tween.tween_property($LevelPart, 'position:y', -$LevelPart.size.y, 0 if $LevelPart.text.is_empty() else 0.5)
	tween.tween_callback(func(): $LevelPart.text = name)
	tween.tween_property($LevelPart, 'position:y', 10, 0.5)

func restart_to_level_part(part: String) -> void:
	$DeadText.hide()
	$Player.respawn()
	for enemy in $AllEnemies.get_children():
		BasicEnemy.Type
		enemy.die(BasicEnemy.DieReason.Reset)
	level.change_level_part.disconnect(_on_change_level_part)
	var build := builder.clone()
	if !build.skip_till_level_part(cur_level_part):
		print("Couldn't find part %s, starting from scratch" % cur_level_part)
		cur_level_part = ""
	level = build.build()
	level.change_level_part.connect(_on_change_level_part)


func _on_player_player_dead() -> void:
	var dead_text := $DeadText
	dead_text.text = "You died. Bummer.\nRestarting from %s\nCurrent difficulty: Hard" % cur_level_part
	dead_text.show()
	dead_text.label_settings.font_color.a = 0
	var tween := create_tween()
	tween.tween_property(dead_text.label_settings, 'font_color:a', 1, 1)
	tween.tween_property(dead_text.label_settings, 'font_color:a', 0, 1).set_delay(3)
	tween.tween_callback(restart_to_level_part.bind(cur_level_part))
