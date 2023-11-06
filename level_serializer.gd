extends Node2D

# Hardcoded for now
var builder: LevelBuilder = preload("res://levels/level1.gd").new()

const PATH := "user://serialized_level1.gd"

func _on_save_pressed() -> void:
	var level := builder.build()
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_var(level.serialized())
	print("Saved!")

func _on_test_pressed() -> void:
	var level: Array = builder.build().serialized()
	var file := FileAccess.open(PATH, FileAccess.READ)
	var level_stored = file.get_var()
	assert(level.size() == level_stored.size(), "Different sizes")
	for i in level.size():
		if level[i] != level_stored[i]:
			print(level[i])
			print(level_stored[i])
			assert(false, "Not equal %d" % i)
	assert(level == level_stored, "Not equal")
	print("They are equal")
