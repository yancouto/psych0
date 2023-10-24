class_name ColorChanger
extends Node

class ColorPattern:
	var cur_time: float = 0
	func get_color() -> Color:
		assert(false, "Must be implemented")
		return Color.BLACK
	func update(dt: float) -> void:
		cur_time += dt

class HueChanger extends ColorPattern:
	func get_color() -> Color:
		return Color.from_hsv(fmod(cur_time / 15., 1), pingpong(cur_time / 50, 0.3) + 0.65, pingpong(cur_time / 91., 0.2) + 0.55)

class SatChanger extends ColorPattern:
	var h: float
	var s: float
	var v: float
	func _init(base_color: Color):
		h = base_color.h
		s = base_color.s
		v = base_color.v
	func get_color() -> Color:
		return Color.from_hsv(h, clampf(s + pingpong(cur_time, 0.4) - 0.2, 0, 1), v)

var pattern: ColorPattern = HueChanger.new()

func _process(dt: float) -> void:
	pattern.update(dt)

func get_color() -> Color:
	return pattern.get_color()
