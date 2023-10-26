extends Node

const RESPAWN_TIMEOUT := 4.

enum Difficulty { Medium, Hard }
enum State { Playing, WaitingForRestart }

# Level to run, let's start by hardcoding 1
var builder: LevelBuilder = preload("res://levels/level1.gd").new()
var level: Level = builder.clone().build()
var next_event: LevelEvent.EventWithTime
var time_passed := 0.
var cur_level_part: String
var last_checkpoint: StringName
var difficulty: Difficulty = Difficulty.Medium
var state := State.Playing
var dead_text_a_tween: Tween
var timeout_for_respawn: float = 0


func _ready() -> void:
	connect_level()
	$Pausing.do_pause_unpause() # Start paused to show instructions
	fix_bg_color()

func connect_level() -> void:
	level.change_level_part.connect(_on_change_level_part)
	level.new_checkpoint.connect(_on_checkpoint)

func disconnect_level() -> void:
	level.change_level_part.disconnect(_on_change_level_part)
	level.new_checkpoint.disconnect(_on_checkpoint)

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
	if state == State.WaitingForRestart && timeout_for_respawn > 0:
		timeout_for_respawn -= dt
		if timeout_for_respawn <= 0 or ((RESPAWN_TIMEOUT - timeout_for_respawn) > 0.5 and Input.is_action_just_pressed(&"skip_dead_text")):
			dead_text_a_tween.kill()
			dead_text_a_tween = create_tween()
			dead_text_a_tween.tween_property($DeadText.label_settings, 'font_color:a', 0, 1)
			dead_text_a_tween.tween_callback(restart_to_checkpoint.bind(checkpoint_from_difficulty()))


func _on_change_level_part(name: String) -> void:
	if state != State.Playing:
		return
	cur_level_part = name
	var tween = create_tween()
	tween.tween_property($LevelPart, 'position:y', -$LevelPart.size.y, 0 if $LevelPart.text.is_empty() else 0.5)
	tween.tween_callback(func(): $LevelPart.text = name)
	tween.tween_property($LevelPart, 'position:y', 10, 0.5)

func _on_checkpoint(name: StringName) -> void:
	if state != State.Playing:
		return
	last_checkpoint = name
	print("Checkpoint: %s" % name)

func restart_to_checkpoint(checkpoint: StringName) -> void:
	print("Restart to %s" % checkpoint)
	$DeadText.hide()
	$Player.respawn()
	for enemy in $AllEnemies.get_children():
		BasicEnemy.Type
		enemy.die(BasicEnemy.DieReason.Reset)
	disconnect_level()
	var build := builder.clone()
	if !build.skip_till_checkpoint(checkpoint):
		print("Couldn't find checkpoint %s, starting from scratch" % checkpoint)
	level = build.build()
	connect_level()
	cur_level_part = ""
	state = State.Playing

func restart_from_text() -> String:
	match difficulty:
		Difficulty.Medium:
			return "the latest checkpoint"
		Difficulty.Hard:
			return cur_level_part
		_:
			assert(false, "Unknown difficulty")
			return ""

func difficulty_name() -> String:
	match difficulty:
		Difficulty.Medium:
			return "Medium"
		Difficulty.Hard:
			return "Hard"
		_:
			assert(false, "Unknown difficulty")
			return ""

func checkpoint_from_difficulty() -> StringName:
	match difficulty:
		Difficulty.Medium:
			return last_checkpoint
		Difficulty.Hard:
			return cur_level_part
		_:
			assert(false, "Unknown difficulty")
			return ""

func _on_player_player_dead() -> void:
	state = State.WaitingForRestart
	var dead_text := $DeadText
	dead_text.text = "You died. Bummer.\nRestarting from %s\nCurrent difficulty: %s" % [restart_from_text(), difficulty_name()]
	dead_text.show()
	dead_text.label_settings.font_color.a = 0
	dead_text_a_tween = create_tween()
	dead_text_a_tween.tween_property(dead_text.label_settings, 'font_color:a', 1, 1)
	timeout_for_respawn = RESPAWN_TIMEOUT

