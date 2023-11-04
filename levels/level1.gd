extends LevelBuilder

var F := Formation
const E := LevelEvent.EnemyType
const Speed := LevelEvent.BasicSpeed
const Top := Formation.HorizontalLineSide.Top
const Bottom := Formation.HorizontalLineSide.Bottom
const Left := Formation.VerticalLineSide.Left
const Right := Formation.VerticalLineSide.Right

func top_bottom(amount: int, enemies: Array[E] = [], invert := false) -> void:
	spawn(F.VerticalLine.new(amount / 2, Right if invert else Left, F.VerticalLinePlacement.Distribute.new(0, H / 2), 1.5, 1., enemies))
	spawn(F.VerticalLine.new((amount + 1) / 2, Left if invert else Right, F.VerticalLinePlacement.Distribute.new(H / 2, 0), 1.5, 1., enemies))

func left_right(amount: int, enemies: Array[E] = [], invert := false) -> void:
	const top := F.HorizontalLineSide.Top
	const bottom := F.HorizontalLineSide.Bottom
	spawn(F.HorizontalLine.new(amount / 2, top if invert else bottom, F.HorizontalLinePlacement.Distribute.new(0, W / 2), 1, 1., enemies))
	spawn(F.HorizontalLine.new((amount + 1) / 2, bottom if invert else top, F.HorizontalLinePlacement.Distribute.new(W / 2, 0), 1, 1., enemies))

func _init():
	seed(42)
	const r := 0.9
	const s := 0.75
	var screen_angle := Vector2(H/2, W/2).angle()

	wait(1)
	level_part("Prelude - What am I?")

	wait(2)
	spawn(F.single().position(Vector2(-r, H / 2)).speedm(Speed.new(s, 0)).radiusm(r))
	wait_until_no_enemies()

	spawn(F.Circle.new(2, -PI/2, 1, [E.Basic1]))
	wait(3)
	spawn(F.Circle.new(4, 0, 1, [E.Basic1]))
	wait(2)
	spawn(F.Circle.new(2, -screen_angle, 1, [E.Basic1]))
	spawn(F.Circle.new(2, screen_angle, 1, [E.Basic1]))
	wait_until_no_enemies()
	checkpoint(&"check1")

	wait(2)
	for i in 4:
		spawn(F.VerticalLine.new(12, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 1.3 if i < 3 else 2, 1))
		var time := (4 - i) * 0.2 + 0.2
		set_indicator_time(time)
		wait(time)
	reset_indicator_time()
	wait(0.5)
	spawn(F.VerticalLine.new(14, F.VerticalLineSide.Right, F.VerticalLinePlacement.Distribute.new(), 1.3))
	wait_until_no_enemies()
	checkpoint(&"check2")
	
	spawn(F.Spiral.new(4, 4, 400, 0., 1., 1., [E.Basic3]))

	wait(6)
	level_part("Part I - The beginning of the end")
	wait(2)

	spawn(F.HorizontalLine.new(15, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(100), 1))
	wait(1)
	spawn(F.HorizontalLine.new(14, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(100), 1))
	wait(1.5)
	spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.V.new(100), 1, 1, [E.Basic3, E.Basic1]))
	wait_until_no_enemies()
	checkpoint(&"check3")

	set_indicator_time(1)
	for i in 5:
		if i > 3:
			spawn(F.VerticalLine.new(8, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 0.5))
		wait(1)
		spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Gap.new((i + 1) * (W / 6), 200), 1, 1, [E.Basic1, E.Basic3]))
	for i in 4:
		if i < 3:
			spawn(F.VerticalLine.new(8, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 0.5))
		wait(1)
		spawn(F.HorizontalLine.new(17, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Gap.new(((4 - i) + 1) * (W / 6), 200), 1, 1, [E.Basic3]))
	wait(4.5)
	checkpoint(&"check4")
	reset_indicator_time()
	for side in [Top, Bottom]:
		spawn(F.HorizontalLine.new(18, side, F.HorizontalLinePlacement.Gap.new(W / 2, 150)))
	wait(1.5)
	for side in [Left, Right]:
		spawn(F.VerticalLine.new(14, side, F.VerticalLinePlacement.Distribute.new(125)))
	for side in [Top, Bottom]:
		spawn(F.HorizontalLine.new(6, side, F.HorizontalLinePlacement.Distribute.new(W * .35)))
	wait_until_no_enemies()
	checkpoint(&"check5")

	set_indicator_time(1)
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
	checkpoint(&"check6")

	spawn(F.Multiple.new(42, Vector2(W + r, H / 2), Speed.new(-0.75, 0), Vector2.RIGHT, 0.1, r, [E.Basic3]))
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
	checkpoint(&"check7")

	wait(2)
	spawn(F.Spiral.new(8, 8, 100, 0, 1))
	wait(6)
	spawn(F.Spiral.new(12, 20, 150, 0, 1.5).invert())
	wait(4)
	spawn(F.VerticalLine.new(10, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), .5))
	spawn(F.VerticalLine.new(10, F.VerticalLineSide.Right, F.VerticalLinePlacement.Distribute.new(), .5))
	wait(6)
	checkpoint(&"check8")
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

	level_part("Part II - Circle madness")
	spawn(F.Circle.new(12))
	wait_until_no_enemies()
	spawn(F.Circle.new(20, 0, 1, [E.Basic1, E.Basic3]))
	wait(5)
	checkpoint(&"check9")
	spawn(F.Circle.new(12).set_center_x(W / 3))
	spawn(F.Circle.new(12).set_center_x(2 * W / 3))
	wait(6.3)
	spawn(F.Circle.new(15, 0, 1, [E.Basic1, E.Basic3, E.Basic1]).set_center_x(W/3))
	spawn(F.Circle.new(15, 0, 1, [E.Basic1]).set_center_x(2*W/3))
	wait(5.5)
	spawn(F.Circle.new(15, 0, 1, [E.Basic1]).set_center_x(W/3))
	spawn(F.Circle.new(15, 0, 1, [E.Basic3, E.Basic1, E.Basic3]).set_center_x(2*W/3))
	wait(5.5)
	spawn(F.Circle.new(18, 0, 1, [E.Basic1, E.Basic3]).set_center_x(W/3))
	spawn(F.Circle.new(18, 0, 1, [E.Basic3, E.Basic1]).set_center_x(2*W/3))
	wait_until_no_enemies()
	checkpoint(&"check10")

	set_indicator_time(1.2)
	spawn(F.Spiral.new(90, 80, 100, PI/2, 1.5, 1, [E.Basic1]))
	wait(2)
	spawn(F.Spiral.new(90, 60, 100, -PI/2, 1.5, 1, [E.Basic1, E.Basic3]).invert())
	wait(4)
	spawn(F.VerticalLine.new(12, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 0.8))
	wait(8)
	
	spawn(F.VerticalLine.new(12, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 1.5))
	wait(1)
	spawn(F.VerticalLine.new(12, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 1.5))
	wait(0.5)
	spawn(F.VerticalLine.new(12, F.VerticalLineSide.Left, F.VerticalLinePlacement.Distribute.new(), 1.5))
	wait(2)
	checkpoint(&"check11")


	spawn(F.Spiral.new(90, 80, 100, 0, 1.5, 1, [E.Basic1, E.Basic3]))
	spawn(F.Spiral.new(90, 80, 100, TAU/3, 1.5, 1, [E.Basic3, E.Basic1]))
	spawn(F.Spiral.new(90, 80, 100, 2*TAU/3, 1.5, 1, [E.Basic1, E.Basic3]))
	
	wait(3.5)
	left_right(10, [])
	wait(2.5)
	top_bottom(12)
	wait(5)
	left_right(18, [E.Basic1, E.Basic3])
	wait(1)
	left_right(18, [E.Basic1], true)
	
	wait(3.5)

	spawn(F.HorizontalLine.new(14, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.Gap.new(W / 2, W / 3), 1.2, 1., [E.Basic3]))
	spawn(F.HorizontalLine.new(11, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(50, W / 4), 1.2, 1., [E.Basic1, E.Basic3]))
	wait(.8)
	spawn(F.HorizontalLine.new(11, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.V.new(50, W / 4), 1.2, 1., [E.Basic3]))
	wait_until_no_enemies()
	checkpoint(&"check12")

	spawn(F.Circle.new(28, 0, 0.7))
	wait(2.5)
	spawn(F.Circle.new(28, 0, 0.5, [E.Basic1, E.Basic3]))
	wait(1.5)
	spawn(F.Circle.new(28, 0, 0.5, [E.Basic3]))
	wait(2.5)
	for i in 5:
		spawn(F.HorizontalLine.new(4 + i * 3, F.HorizontalLineSide.Top, F.HorizontalLinePlacement.Gap.new(W / 2, 100 + (4 - i) * ((W - 100) / 5)), 0.7, 1., [E.Basic3]))
		spawn(F.HorizontalLine.new(4 + i * 3, F.HorizontalLineSide.Bottom, F.HorizontalLinePlacement.Gap.new(W / 2, 100 + (4 - i) * ((W - 100) / 5)), 0.7, 1., [E.Basic3]))
		wait(1.2)
	wait_until_no_enemies()

	level_part("Part III - They're after you")
	set_indicator_time(5)
	wait(6)
	spawn(F.Circle.new(16, 0, 1, [E.Basic1]).set_follow_player())
	set_indicator_time(3)
	wait_until_no_enemies()
	checkpoint(&"check13")

	wait(2)
	spawn(F.HorizontalLine.new(17, Top, F.HorizontalLinePlacement.V.new(100, 20), 1., 1., [E.Basic3]))
	spawn(F.HorizontalLine.new(17, Bottom, F.HorizontalLinePlacement.V.new(100, 20), 1., 1., [E.Basic1]))
	wait(2)
	spawn(F.VerticalLine.new(13, Left, F.VerticalLinePlacement.Distribute.new(0), 1.2).set_follows_player())
	spawn(F.VerticalLine.new(13, Right, F.VerticalLinePlacement.Distribute.new(0), 1.2, 1., [E.Basic3]).set_follows_player())
	wait(4.5)
	set_indicator_time(1.5)

	left_right(15)
	wait(0.75)
	top_bottom(13)
	wait(0.75)
	left_right(15, [], true)
	wait(1)
	top_bottom(13, [], true)
	wait_until_no_enemies()
	checkpoint(&"check14")

	spawn(F.Spiral.new(140, 235, 80, PI/2, 1.4, 1.2, [E.Basic1, E.Basic3]))
	
	wait(3)
	top_bottom(12, [E.Basic3])
	wait(3)
	left_right(16, [E.Basic3])
	wait(3)
	top_bottom(12, [E.Basic3], true)
	wait(3)
	left_right(16, [E.Basic3], true)
	
	wait(3)
	spawn(F.VerticalLine.new(8, Left, F.VerticalLinePlacement.Distribute.new(0, H * .4), 1.2, 1., [E.Basic3, E.Basic1]))
	spawn(F.HorizontalLine.new(9, Top, F.HorizontalLinePlacement.Distribute.new(0, W * .5), 1.2, 1., [E.Basic3, E.Basic1]))
	wait(3)
	spawn(F.VerticalLine.new(8, Right, F.VerticalLinePlacement.Distribute.new(0, H * .4), 1.2, 1., [E.Basic3, E.Basic1]))
	spawn(F.HorizontalLine.new(9, Top, F.HorizontalLinePlacement.Distribute.new(W * .5, 0), 1.2, 1., [E.Basic3, E.Basic1]))
	wait(3)
	spawn(F.VerticalLine.new(8, Right, F.VerticalLinePlacement.Distribute.new(H * .4, 0), 1.2, 1., [E.Basic3, E.Basic1]))
	spawn(F.HorizontalLine.new(9, Bottom, F.HorizontalLinePlacement.Distribute.new(W * .5, 0), 1.2, 1., [E.Basic3, E.Basic1]))
	wait(4)
	spawn(F.VerticalLine.new(8, Left, F.VerticalLinePlacement.Distribute.new(H * .4, 0), 1.2, 1., [E.Basic3, E.Basic1]))
	spawn(F.HorizontalLine.new(9, Bottom, F.HorizontalLinePlacement.Distribute.new(0, W * .5), 1.2, 1., [E.Basic3, E.Basic1]))
	
	wait(3)
	spawn(F.VerticalLine.new(10, Right, F.VerticalLinePlacement.Distribute.new(0, H * .25)))
	spawn(F.VerticalLine.new(10, Left, F.VerticalLinePlacement.Distribute.new(H * .25, 0)))
	spawn(F.HorizontalLine.new(10, Bottom, F.HorizontalLinePlacement.Distribute.new(0, W * .3)))
	spawn(F.HorizontalLine.new(10, Top, F.HorizontalLinePlacement.Distribute.new(W * .3, 0)))
	wait(4)
	spawn(F.VerticalLine.new(10, Left, F.VerticalLinePlacement.Distribute.new(0, H * .25)))
	spawn(F.VerticalLine.new(10, Right, F.VerticalLinePlacement.Distribute.new(H * .25, 0)))
	spawn(F.HorizontalLine.new(10, Top, F.HorizontalLinePlacement.Distribute.new(0, W * .3)))
	spawn(F.HorizontalLine.new(10, Bottom, F.HorizontalLinePlacement.Distribute.new(W * .3, 0)))

	wait_until_no_enemies()
	checkpoint(&"check15")
	set_indicator_time(2.5)
	wait(3)
	var shot_r := 0.4

	var rand_pos := func() -> Vector2:
		return LevelBuilder.point_around_screen(randf() * 4, shot_r * F.BASE_RADIUS)
	spawn(F.single().position(LevelBuilder.point_around_screen(0.5, shot_r * F.BASE_RADIUS)).speedm(LevelEvent.FollowPlayer.new(5)).radiusm(shot_r))
	wait(3)
	set_indicator_time(1.2)
	for i in range(30):
		if i < 5:
			spawn(F.single().position(rand_pos.call()).speedm(LevelEvent.FollowPlayer.new(5)).radiusm(shot_r))
			wait(2)
		elif i < 15:
			spawn(F.single().position(rand_pos.call()).speedm(LevelEvent.FollowPlayer.new(6)).radiusm(shot_r).type(E.Basic3))
			wait(1)
		elif i < 24:
			spawn(F.single().position(rand_pos.call()).speedm(LevelEvent.FollowPlayer.new(7)).radiusm(shot_r).type(E.Basic3))
			wait(.8)
		else:
			spawn(F.single().position(rand_pos.call()).speedm(LevelEvent.FollowPlayer.new(7)).radiusm(shot_r).type(E.Basic3))
			wait(.6)
	wait_until_no_enemies()
	
	level_part("Part IV - The big one")
	wait(2)
	boss(Boss.Level1)
