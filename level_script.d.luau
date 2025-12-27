--!strict
--[[ This file contains the types of the API for the level interpreter.
The interpreter is very strongly typed, and the types here should serve as documentation on how to use i
A table named API which implements the API type below is provided in level scripts. You can use it to interact with the
API, for example: API.Wait(2); API.Spawn.VerticalLine { enemies = API.new.Enemy.Simple, amount = 12, side = API.new.Side.Top, placement = API.new.PlacemenDistribute {margin=10} }
]]

-- The int/float types are just to make clear which kind of value is expected.
export type int = number
export type float = number

type EnemyList = { Enemy } | Enemy

declare API: {
	Wait: (float) -> (),
	WaitUntilNoEnemies: () -> (),
	Spawn: Spawner,
	CustomSpawn: (
		{
			indicator_duration: float?,
			follow_player: boolean?, -- default: false
		}
	) -> Spawner,
	SetDefaultIndicatorDuration: (float) -> (),
}

type Spawner = {
	Single: (
	{
		enemy: Enemy,
		pos: Vec2,
		speed: Vec2,
		radius: float?, -- default: 20
	}
	) -> (),
	Multiple: (
	{
		enemies: EnemyList,
		amount: int,
		spacing: float?, -- default: 5
		pos: Vec2,
		speed: Vec2,
		radius: float?, -- default: 20
	}
	) -> (),
	VerticalLine: (
	{
		enemies: EnemyList,
		amount: int,
		speed: float?, -- default: 15
		radius: float?, -- default: 20
		side: VerticalLineSide,
		placement: VerticalLinePlacement,
	}
	) -> (),
	HorizontalLine: (
	{
		enemies: EnemyList,
		amount: int,
		speed: float?, -- default: 15
		radius: float?, -- default: 20
		side: HorizontalLineSide,
		placement: HorizontalLinePlacement,
	}
	) -> (),
	Circle: (
	{
		enemies: EnemyList,
		amount: int,
		speed: float?, -- default: 15
		enemy_radius: float?, -- default: 20
		starting_angle: float?, -- default: 0
		formation_radius: float?,
		formation_center: Vec2?,
	}
	) -> (),
	Spiral: (
	{
		enemies: EnemyList,
		amount_in_circle: int,
		amount: int,
		spacing: float,
		enemy_radius: float?, -- default: 20
		speed: float?, -- default: 10
	}
	) -> (),
}

-- You can simply use {x, y} instead of this.
declare Vec2: (x: number, y: number) -> Vec2;

declare Enemy: {
	Simple: "Simple",
	Double: "Double",
}

declare Placement: {
	Distribute: ({ margin: float? }) -> Distribute,
	FromBottom: ({ margin: float?, spacing: float }) -> FromBottom,
	FromTop: ({ margin: float?, spacing: float }) -> FromTop,
	FromLeft: ({ margin: float?, spacing: float }) -> FromLeft,
	FromRight: ({ margin: float?, spacing: float }) -> FromRight,
	V: ({ margin: float?, spacing: float }) -> V,
}

declare Side: {
	Left: "Left",
	Right: "Right",
	Top: "Top",
	Bottom: "Bottom",
}

-- You do not need to actually see these, only if you're doing something advanced.
-- You can just use something like Placement.FromRight {...}  instead of seeing the FromRight type.

export type Vec2 = { number } -- it should have length exactly 2, but we can't specify that in luau

export type Enemy = "Simple" | "Double"

export type VerticalLineSide = "Left" | "Right"

export type HorizontalLineSide = "Top" | "Bottom"

type Distribute = { type: "Distribute", margin: number? }
type FromBottom = { type: "FromBottom", margin: number?, spacing: number }
type FromTop = { type: "FromTop", margin: number?, spacing: number }
type FromLeft = { type: "FromLeft", margin: number?, spacing: number }
type FromRight = { type: "FromRight", margin: number?, spacing: number }
type V = { type: "V", margin: number?, spacing: number }

export type VerticalLinePlacement =
	Distribute |
	FromBottom |
	FromTop |
	V

export type HorizontalLinePlacement =
	Distribute |
	FromLeft |
	FromRight |
	V