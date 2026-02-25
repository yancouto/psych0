---@meta _
-- Level script sandbox globals — injected by the interpreter into all files in src/levels/.
-- These globals are NOT available in regular game code; they only exist inside the sandbox.
-- LuaLS does not support per-directory scoping, so they are declared workspace-wide here.

---@alias Vec2 {[1]: number, [2]: number}

---@alias EnemyType "Simple" | "Double"
---@alias VerticalLineSide "Left" | "Right"
---@alias HorizontalLineSide "Top" | "Bottom"

---@class PlacementDistribute
---@field type "Distribute"
---@field margin number?

---@class PlacementSpaced
---@field type "FromBottom"|"FromTop"|"FromLeft"|"FromRight"|"V"
---@field margin number?
---@field spacing number

---@alias VerticalLinePlacement PlacementDistribute|PlacementSpaced
---@alias HorizontalLinePlacement PlacementDistribute|PlacementSpaced

---@class SingleParams
---@field enemy EnemyType
---@field pos Vec2
---@field speed Vec2
---@field radius number? default: 20

---@class MultipleParams
---@field enemies EnemyType | EnemyType[]
---@field amount integer
---@field spacing number? default: 5
---@field pos Vec2
---@field speed Vec2
---@field radius number? default: 20

---@class VerticalLineParams
---@field enemies EnemyType | EnemyType[]
---@field amount integer
---@field speed number? default: 15
---@field radius number? default: 20
---@field side VerticalLineSide
---@field placement VerticalLinePlacement

---@class HorizontalLineParams
---@field enemies EnemyType | EnemyType[]
---@field amount integer
---@field speed number? default: 15
---@field radius number? default: 20
---@field side HorizontalLineSide
---@field placement HorizontalLinePlacement

---@class CircleParams
---@field enemies EnemyType | EnemyType[]
---@field amount integer
---@field speed number? default: 15
---@field enemy_radius number? default: 20
---@field starting_angle number? default: 0
---@field formation_radius number?
---@field formation_center Vec2?

---@class SpiralParams
---@field enemies EnemyType | EnemyType[]
---@field amount_in_circle integer
---@field amount integer
---@field spacing number
---@field enemy_radius number? default: 20
---@field speed number? default: 10

---@class Spawner
---@field Single fun(params: SingleParams)
---@field Multiple fun(params: MultipleParams)
---@field VerticalLine fun(params: VerticalLineParams)
---@field HorizontalLine fun(params: HorizontalLineParams)
---@field Circle fun(params: CircleParams)
---@field Spiral fun(params: SpiralParams)

---@class CustomSpawnParams
---@field indicator_duration number?

---@class API_t
---@field Wait fun(seconds: number)
---@field WaitUntilNoEnemies fun()
---@field Spawn Spawner
---@field CustomSpawn fun(params: CustomSpawnParams): Spawner
---@field SetDefaultIndicatorDuration fun(duration: number)

---@class PlacementModule
---@field Distribute fun(params: {margin: number?}): PlacementDistribute
---@field FromBottom fun(params: {margin: number?, spacing: number}): PlacementSpaced
---@field FromTop fun(params: {margin: number?, spacing: number}): PlacementSpaced
---@field FromLeft fun(params: {margin: number?, spacing: number}): PlacementSpaced
---@field FromRight fun(params: {margin: number?, spacing: number}): PlacementSpaced
---@field V fun(params: {margin: number?, spacing: number}): PlacementSpaced

---@class EnemyModule
---@field Simple "Simple"
---@field Double "Double"

---@class SideModule
---@field Left "Left"
---@field Right "Right"
---@field Top "Top"
---@field Bottom "Bottom"

---@type API_t
API = nil

---@type fun(x: number, y: number): Vec2
Vec2 = nil

---@type EnemyModule
Enemy = nil

---@type SideModule
Side = nil

---@type PlacementModule
Placement = nil

