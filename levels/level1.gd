extends LevelBuilder

var F = Formation

func _init():
	const r = 25
	const s = 300
	
	wait(2)
	spawn(F.Single.new(Vector2(-r, H / 2), Vector2(s, 0), r))
	wait_until_no_enemies()
	spawn(F.Circle.new(2, -PI/2))
	wait(1.5)
	spawn(F.Circle.new(4))
	wait_until_no_enemies()
