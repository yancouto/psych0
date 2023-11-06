extends LevelBuilder

var F := Formation
const E := LevelEvent.EnemyType
const Speed := LevelEvent.BasicSpeed
const Top := Formation.HorizontalLineSide.Top
const Bottom := Formation.HorizontalLineSide.Bottom
const Left := Formation.VerticalLineSide.Left
const Right := Formation.VerticalLineSide.Right

func top_bottom(amount: int, enemies: Array[E] = [], invert := false) -> void:
	spawn(F.vertical_line(amount / 2).side(Right if invert else Left).distribute(0, H / 2).speedm_len(1.5).types(enemies))
	spawn(F.vertical_line((amount + 1) / 2).side(Left if invert else Right).distribute(H / 2, 0).speedm_len(1.5).types(enemies))

func left_right(amount: int, enemies: Array[E] = [], invert := false) -> void:
	spawn(F.horizontal_line(amount / 2).side(Top if invert else Bottom).distribute(0, W / 2).types(enemies))
	spawn(F.horizontal_line((amount + 1) / 2).side(Bottom if invert else Top).distribute(W / 2, 0).types(enemies))

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

	spawn(F.circle(2).starting_angle(-PI/2))
	wait(3)
	spawn(F.circle(4))
	wait(2)
	spawn(F.circle(2).starting_angle(-screen_angle))
	spawn(F.circle(2).starting_angle(screen_angle))
	wait_until_no_enemies()
	checkpoint(&"check1")

	wait(2)
	for i in 4:
		spawn(F.vertical_line(12).left().distribute().speedm_len(1.3 if i < 3 else 2))
		var time := (4 - i) * 0.2 + 0.2
		set_indicator_time(time)
		wait(time)
	reset_indicator_time()
	wait(0.5)
	spawn(F.vertical_line(14).right().distribute().speedm_len(1.3))
	wait_until_no_enemies()
	checkpoint(&"check2")
	
	spawn(F.spiral(4).spacing(400).types([E.Basic3]))

	wait(6)
	level_part("Part I - The beginning of the end")
	wait(2)

	spawn(F.horizontal_line(15).top().v(100))
	wait(1)
	spawn(F.horizontal_line(14).top().v(100))
	wait(1.5)
	spawn(F.horizontal_line(17).bottom().v(100).types([E.Basic3, E.Basic1]))
	wait_until_no_enemies()
	checkpoint(&"check3")

	set_indicator_time(1)
	for i in 5:
		if i > 3:
			spawn(F.vertical_line(8).left().distribute().speedm_len(0.5))
		wait(1)
		spawn(F.horizontal_line(17).top().gap(200, (i + 1) * (W / 6)).types([E.Basic1, E.Basic3]))
	for i in 4:
		if i < 3:
			spawn(F.vertical_line(8).left().distribute().speedm_len(0.5))
		wait(1)
		spawn(F.horizontal_line(17).top().gap(200, ((4 - i) + 1) * (W / 6)).types([E.Basic3]))
	wait(4.5)
	checkpoint(&"check4")
	reset_indicator_time()
	for side in [Top, Bottom]:
		spawn(F.horizontal_line(18).side(side).gap(150))
	wait(1.5)
	for side in [Left, Right]:
		spawn(F.vertical_line(14).side(side).distribute(125))
	for side in [Top, Bottom]:
		spawn(F.horizontal_line(6).side(side).distribute(W * .35))
	wait_until_no_enemies()
	checkpoint(&"check5")

	set_indicator_time(1)
	var extra: Array[Formation] = [
		F.vertical_line(8).right().distribute(),
		null,
		F.vertical_line(11).right().v(100),
		null,
		F.vertical_line(11).right().gap(300, 500)
	]
	for i in range(5):
		wait(1)
		if extra[i] != null:
			spawn(extra[i])
		spawn(F.vertical_line(13).left().gap(200, (i + 1) * (H / 6)).radiusm(0.75).types([E.Basic3]))
	wait_until_no_enemies()
	checkpoint(&"check6")

	spawn(F.multiple(42).pos(Vector2(W + r, H / 2)).speedm(Speed.new(-0.75, 0)).dir(Vector2.RIGHT).spacing(0.1).radiusm(r).types([E.Basic3]))
	wait(5)
	for i in range(5):
		wait(1)
		const left := F.VerticalLineSide.Left
		const right := F.VerticalLineSide.Right
		var side := left if i % 2 == 0 else right
		spawn(F.vertical_line(6).side(side).distribute(0, LevelBuilder.H / 2 + Formation.get_radius(r)).speedm_len(0.9 + 0.25 * i))
		spawn(F.vertical_line(6).side(left + right - side).distribute(LevelBuilder.H / 2 + Formation.get_radius(r), 0).speedm_len(0.9 + 0.25 * i))
	wait_until_no_enemies()
	reset_indicator_time()
	checkpoint(&"check7")

	wait(2)
	spawn(F.spiral(8).spacing(100))
	wait(6)
	spawn(F.spiral(20).circle_amount(12).spacing(150).speedm_len(1.5).invert())
	wait(4)
	spawn(F.vertical_line(10).left().distribute().speedm_len(.5))
	spawn(F.vertical_line(10).right().distribute().speedm_len(.5))
	wait(6)
	checkpoint(&"check8")
	spawn(F.spiral(100).circle_amount(20).spacing(50).speedm_len(.75))
	wait(5)
	spawn(F.vertical_line(11).left().distribute().speedm_len(.75))
	wait(0.5)
	spawn(F.vertical_line(11).right().distribute().speedm_len(.75))
	wait(4)
	for i in range(3):
		wait(1.5)
		spawn(F.horizontal_line(11).top().v(50 + 50 * i).speedm_len(.5))
	wait_until_no_enemies()

	level_part("Part II - Circle madness")
	spawn(F.circle(12))
	wait_until_no_enemies()
	spawn(F.circle(20).types([E.Basic1, E.Basic3]))
	wait(5)
	checkpoint(&"check9")
	spawn(F.circle(12).center_x(W / 3))
	spawn(F.circle(12).center_x(2 * W / 3))
	wait(6.3)
	spawn(F.circle(15).center_x(W/3).types([E.Basic1, E.Basic3, E.Basic1]))
	spawn(F.circle(15).center_x(2*W/3).types([E.Basic1]))
	wait(5.5)
	spawn(F.circle(15).center_x(W/3).types([E.Basic1]))
	spawn(F.circle(15).center_x(2*W/3).types([E.Basic3, E.Basic1, E.Basic3]))
	wait(5.5)
	spawn(F.circle(18).center_x(W/3).types([E.Basic1, E.Basic3]))
	spawn(F.circle(18).center_x(2*W/3).types([E.Basic3, E.Basic1]))
	wait_until_no_enemies()
	checkpoint(&"check10")

	set_indicator_time(1.2)
	spawn(F.spiral(80).circle_amount(90).spacing(100).starting_angle(PI/2).speedm_len(1.5))
	wait(2)
	spawn(F.spiral(60).circle_amount(90).spacing(100).starting_angle(-PI/2).speedm_len(1.5).types([E.Basic1, E.Basic3]).invert())
	wait(4)
	spawn(F.vertical_line(12).left().distribute().speedm_len(0.8))
	wait(8)
	
	spawn(F.vertical_line(12).left().distribute().speedm_len(1.5))
	wait(1)
	spawn(F.vertical_line(12).left().distribute().speedm_len(1.5))
	wait(0.5)
	spawn(F.vertical_line(12).left().distribute().speedm_len(1.5))
	wait(2)
	checkpoint(&"check11")


	spawn(F.spiral(80).circle_amount(90).spacing(100).starting_angle(0).speedm_len(1.5).types([E.Basic1, E.Basic3]))
	spawn(F.spiral(80).circle_amount(90).spacing(100).starting_angle(TAU/3).speedm_len(1.5).types([E.Basic3, E.Basic1]))
	spawn(F.spiral(80).circle_amount(90).spacing(100).starting_angle(2*TAU/3).speedm_len(1.5).types([E.Basic1, E.Basic3]))
	
	wait(3.5)
	left_right(10, [])
	wait(2.5)
	top_bottom(12)
	wait(5)
	left_right(18, [E.Basic1, E.Basic3])
	wait(1)
	left_right(18, [E.Basic1], true)
	
	wait(3.5)

	spawn(F.horizontal_line(14).bottom().gap(W / 3).speedm_len(1.2).types([E.Basic3]))
	spawn(F.horizontal_line(11).top().v(50, W / 4).speedm_len(1.2).types([E.Basic1, E.Basic3]))
	wait(.8)
	spawn(F.horizontal_line(11).top().v(50, W / 4).speedm_len(1.2).types([E.Basic3]))
	wait_until_no_enemies()
	checkpoint(&"check12")

	spawn(F.circle(28).speedm_len(0.7))
	wait(2.5)
	spawn(F.circle(28).speedm_len(0.5).types([E.Basic1, E.Basic3]))
	wait(1.5)
	spawn(F.circle(28).speedm_len(0.5).types([E.Basic3]))
	wait(2.5)
	for i in 5:
		spawn(F.horizontal_line(4 + i * 3).top().gap(100 + (4 - i) * ((W - 100) / 5)).speedm_len(0.7).types([E.Basic3]))
		spawn(F.horizontal_line(4 + i * 3).bottom().gap(100 + (4 - i) * ((W - 100) / 5)).speedm_len(0.7).types([E.Basic3]))
		wait(1.2)
	wait_until_no_enemies()

	level_part("Part III - They're after you")
	set_indicator_time(5)
	wait(6)
	spawn(F.circle(16).follow_player())
	set_indicator_time(3)
	wait_until_no_enemies()
	checkpoint(&"check13")

	wait(2)
	spawn(F.horizontal_line(17).top().v(100, 20).types([E.Basic3]))
	spawn(F.horizontal_line(17).bottom().v(100, 20).types([E.Basic1]))
	wait(2)
	spawn(F.vertical_line(13).left().distribute(0).speedm_len(1.2).follow_player())
	spawn(F.vertical_line(13).right().distribute(0).speedm_len(1.2).types([E.Basic3]).follow_player())
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

	spawn(F.spiral(235).circle_amount(140).spacing(80).starting_angle(PI/2).speedm_len(1.4).radiusm(1.2).types([E.Basic1, E.Basic3]))
	
	wait(3)
	top_bottom(12, [E.Basic3])
	wait(3)
	left_right(16, [E.Basic3])
	wait(3)
	top_bottom(12, [E.Basic3], true)
	wait(3)
	left_right(16, [E.Basic3], true)
	
	wait(3)
	spawn(F.vertical_line(8).left().distribute(0, H * .4).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	spawn(F.horizontal_line(9).top().distribute(0, W * .5).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	wait(3)
	spawn(F.vertical_line(8).right().distribute(0, H * .4).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	spawn(F.horizontal_line(9).top().distribute(W * .5, 0).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	wait(3)
	spawn(F.vertical_line(8).right().distribute(H * .4, 0).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	spawn(F.horizontal_line(9).bottom().distribute(W * .5, 0).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	wait(4)
	spawn(F.vertical_line(8).left().distribute(H * .4, 0).speedm_len(1.2).types([E.Basic3, E.Basic1]))
	spawn(F.horizontal_line(9).bottom().distribute(0, W * .5).speedm_len(1.2).types([E.Basic3, E.Basic1]))

	wait(3)
	spawn(F.vertical_line(10).right().distribute(0, H * .25))
	spawn(F.vertical_line(10).left().distribute(H * .25, 0))
	spawn(F.horizontal_line(10).bottom().distribute(0, W * .3))
	spawn(F.horizontal_line(10).top().distribute(W * .3, 0))
	wait(4)
	spawn(F.vertical_line(10).left().distribute(0, H * .25))
	spawn(F.vertical_line(10).right().distribute(H * .25, 0))
	spawn(F.horizontal_line(10).top().distribute(0, W * .3))
	spawn(F.horizontal_line(10).bottom().distribute(W * .3, 0))

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
