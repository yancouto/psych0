extends Level

func _init():
	const r = 25
	const s = 300
	spawn(Formation.Single.new(Vector2(-r, H/2), Vector2(s/2, 0), r * 1.25))
	wait(3)
	spawn(Formation.Single.new(Vector2(-r, H/2), Vector2(s/2, 0), r * 1.25))
	wait(10)
