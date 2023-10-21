extends Node

func do_pause_unpause() -> void:
	get_tree().paused = !get_tree().paused
	get_node("../PauseOverlay").visible = get_tree().paused

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		do_pause_unpause()
