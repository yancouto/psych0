extends LevelBuilder

var F = Formation

func _init():
	const r = 25
	const s = 300
	var screen_angle := Vector2(H/2, W/2).angle()
	
	wait(2)
	spawn(F.Single.new(Vector2(-r, H / 2), Vector2(s, 0), r))
	wait_until_no_enemies()
	spawn(F.Circle.new(2, -PI/2))
	wait(3)
	spawn(F.Circle.new(4, 0, 400))
	wait(1.5)
	spawn(F.Circle.new(2, -screen_angle, 400))
	spawn(F.Circle.new(2, screen_angle, 400))
	wait_until_no_enemies()
