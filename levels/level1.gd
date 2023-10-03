extends LevelBuilder

func _init():
	const r = 25
	const s = 300
	spawn(Formation.Circle.new(10))
	wait(3)
	spawn(Formation.Circle.new(20))
	wait_until_no_enemies()
	spawn(Formation.Single.new(Vector2(-r, H/2), Vector2(s/2, 0), r * 1.25))
	wait_until_no_enemies()
	spawn(Formation.Single.new(Vector2(-r, H/2), Vector2(s/2, 0), r * 1.25))
	wait(10)
