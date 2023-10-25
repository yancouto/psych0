class_name ShootingInput

static func dir_from_inputs(up: StringName, down: StringName, left: StringName, right: StringName) -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed(down):
		dir.y += 1
	if Input.is_action_pressed(up):
		dir.y -= 1
	if Input.is_action_pressed(left):
		dir.x -= 1
	if Input.is_action_pressed(right):
		dir.x += 1
	if dir.is_zero_approx():
		return Vector2.ZERO
	return dir.normalized()

# TODO: support controller
static func shooting_direction(viewport: Viewport, player_pos: Vector2) -> Vector2:
	# Mouse shooting
	if Input.is_action_pressed(&"shoot"):
		var dir := (viewport.get_mouse_position() - player_pos).normalized()
		return dir
	# Arrows shooting
	return dir_from_inputs(&"shoot_up", &"shoot_down", &"shoot_left", &"shoot_right")
