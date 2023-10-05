extends LevelBuilder

var F := Formation

func _init():
	const r := 25
	const s := 300
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

	wait(2)
	spawn(F.HorizontalLine.new(10, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Distribute.new()))
	wait(1)
	spawn(F.HorizontalLine.new(12, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.Distribute.new(), 400, 30))
	wait_until_no_enemies()


	spawn(F.HorizontalLine.new(15, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(100), 400))
	wait(1)
	spawn(F.HorizontalLine.new(14, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(100), 400))
	wait(1.5)
	spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.V.new(100), 400))
	wait_until_no_enemies()


	for i in range(5):
		wait(1)
		spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Gap.new((i + 1) * (W / 6), 200)))
	wait_until_no_enemies()
	

	var extra: Array[Formation] = [
		F.VerticalLine.new(8, F.VerticalLineSide.Right, F.VerticalLinePlacement.Distribute.new(), 400),
		null,
		F.VerticalLine.new(11, F.VerticalLineSide.Right, F.VerticalLinePlacement.V.new(100), 400),
		null,
		F.VerticalLine.new(11, F.VerticalLineSide.Right, F.VerticalLinePlacement.Gap.new(500, 300), 400)
	]
	for i in range(5):
		wait(1)
		if extra[i] != null:
			spawn(extra[i])
		spawn(F.VerticalLine.new(13, F.VerticalLineSide.Left, F.VerticalLinePlacement.Gap.new((i + 1) * (H / 6), 200)))
	wait_until_no_enemies()

	reset()
	spawn(F.Multiple.new(50, Vector2(W + r, H / 2), Vector2(-300, 0), 5, r))
	wait(5)
	for i in range(5):
		wait(1)
		var side := F.VerticalLineSide.Left if i % 2 == 0 else F.VerticalLineSide.Right
		spawn(F.VerticalLine.new(13, side, F.VerticalLinePlacement.Distribute.new(), 350 + 100 * i))
	wait_until_no_enemies()
