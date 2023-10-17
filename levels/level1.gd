extends LevelBuilder

var F := Formation
var E := LevelEvent.EnemyType
const Speed := LevelEvent.BasicSpeed

func _init():
	const r := 0.9
	const s := 0.75
	var screen_angle := Vector2(H/2, W/2).angle()

	wait(2)
	spawn(F.Single.new(Vector2(-r, H / 2), Speed.new(s, 0), r))
	wait_until_no_enemies()
	spawn(F.Circle.new(2, -PI/2, 1, [E.Basic3]))
	wait(3)
	spawn(F.Circle.new(4, 0, 1, [E.Basic3, E.Basic1]))
	wait(1.5)
	spawn(F.Circle.new(2, -screen_angle, 1, [E.Basic1, E.Basic3]))
	spawn(F.Circle.new(2, screen_angle, 1, [E.Basic3, E.Basic1]))
	wait_until_no_enemies()

	wait(2)
	spawn(F.HorizontalLine.new(10, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Distribute.new()))
	wait(1)
	spawn(F.HorizontalLine.new(12, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.Distribute.new(), 1, 1))
	wait_until_no_enemies()


	spawn(F.HorizontalLine.new(15, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(100), 1))
	wait(1)
	spawn(F.HorizontalLine.new(14, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(100), 1))
	wait(1.5)
	spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.V.new(100), 1, 1, [E.Basic3, E.Basic1]))
	wait_until_no_enemies()

	set_indicator_time(1)
	for i in range(5):
		wait(1)
		spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Gap.new((i + 1) * (W / 6), 200), 1, 1, [E.Basic3]))
	wait_until_no_enemies()
	

	var extra: Array[Formation] = [
		F.VerticalLine.new(8, F.VerticalLineSide.Right, F.VerticalLinePlacement.Distribute.new(), 1),
		null,
		F.VerticalLine.new(11, F.VerticalLineSide.Right, F.VerticalLinePlacement.V.new(100), 1),
		null,
		F.VerticalLine.new(11, F.VerticalLineSide.Right, F.VerticalLinePlacement.Gap.new(500, 300), 1)
	]
	for i in range(5):
		wait(1)
		if extra[i] != null:
			spawn(extra[i])
		spawn(F.VerticalLine.new(13, F.VerticalLineSide.Left, F.VerticalLinePlacement.Gap.new((i + 1) * (H / 6), 200), 1., 0.75, [E.Basic3]))
	wait_until_no_enemies()

	spawn(F.Multiple.new(50, Vector2(W + r, H / 2), Speed.new(-0.75, 0), Vector2.RIGHT, 0.1, r, [E.Basic3]))
	wait(5)
	for i in range(5):
		wait(1)
		const left := F.VerticalLineSide.Left
		const right := F.VerticalLineSide.Right
		var side := left if i % 2 == 0 else right
		spawn(F.VerticalLine.new(6, side, F.VerticalLinePlacement.Distribute.new(0, LevelBuilder.H / 2 + Formation.get_radius(r)), 0.9 + 0.25 * i))
		spawn(F.VerticalLine.new(6, left + right - side, F.VerticalLinePlacement.Distribute.new(LevelBuilder.H / 2 + Formation.get_radius(r), 0), 0.9 + 0.25 * i))
	wait_until_no_enemies()
	reset_indicator_time()

	spawn(F.Spiral.new(20, 100, 50))
	wait(5)
	spawn(F.VerticalLine.new(11, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), .75))
	wait(0.5)
	spawn(F.VerticalLine.new(11, F.VerticalLineSide.Right, F.VerticalLinePlacement.Distribute.new(), .75))
	wait(4)
	for i in range(3):
		wait(1.5)
		spawn(F.HorizontalLine.new(11, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(50 + 50 * i), .5))
	wait_until_no_enemies()

	set_indicator_time(5)
	wait(6)
	spawn(F.Circle.new(16, 0, 0.5, [E.Basic1, E.Basic3]).set_follow_player())
	reset_indicator_time()
	wait_until_no_enemies()
