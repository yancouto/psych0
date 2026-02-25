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

---@type number
WIDTH = nil

---@type number
HEIGHT = nil

-- ─── Sandbox restrictions ────────────────────────────────────────────────────
-- The level sandbox only exposes a small allowlist of stdlib functions.
-- Modules are disabled via runtime.builtin; only the allowed subset is declared below.

-- basic: only the sandbox allowlist subset is available.

---@type string
_VERSION = nil

---@generic T
---@param v? T
---@param message? any
---@param ... any
---@return T
---@return any ...
function assert(v, message, ...) end

---@param message any
---@param level? integer
function error(message, level) end

---@generic T: table, V
---@param t T
---@return fun(table: V[], i?: integer):integer, V
---@return T
---@return integer i
function ipairs(t) end

---@generic K, V
---@param table table<K, V>
---@param index? K
---@return K?
---@return V?
---@nodiscard
function next(table, index) end

---@generic T: table, K, V
---@param t T
---@return fun(table: table<K, V>, index?: K):K, V
---@return T
function pairs(t) end

---@param f async fun(...):...
---@param arg1? any
---@param ... any
---@return boolean success
---@return any result
---@return any ...
function pcall(f, arg1, ...) end

---@param index integer|"#"
---@param ... any
---@return any
---@nodiscard
function select(index, ...) end

---@overload fun(e: string, base: integer):integer
---@param e any
---@return number?
---@nodiscard
function tonumber(e) end

---@param v any
---@return string
---@nodiscard
function tostring(v) end

---@param v any
---@return string
---@nodiscard
function type(v) end

---@param list any
---@param i? integer
---@param j? integer
---@return any ...
---@nodiscard
function unpack(list, i, j) end

---@param f async fun(...):...
---@param msgh function
---@param arg1? any
---@param ... any
---@return boolean success
---@return any result
---@return any ...
function xpcall(f, msgh, arg1, ...) end

-- os: only clock, difftime, and time are available in the sandbox.
os = {}

---@return number
---@nodiscard
function os.clock() end

---@param t2 number
---@param t1 number
---@return number
---@nodiscard
function os.difftime(t2, t1) end

---@param date? table
---@return integer
function os.time(date) end

-- string: only the sandbox allowlist subset is available.
string = {}

---@param s string|number
---@param i? integer
---@param j? integer
---@return integer ...
---@nodiscard
function string.byte(s, i, j) end

---@param byte integer
---@param ... integer
---@return string
---@nodiscard
function string.char(byte, ...) end

---@param s string|number
---@param pattern string|number
---@param init? integer
---@param plain? boolean
---@return integer|nil start
---@return integer|nil end
---@return any|nil ... captured
---@nodiscard
function string.find(s, pattern, init, plain) end

---@param s string|number
---@param ... any
---@return string
---@nodiscard
function string.format(s, ...) end

---@param s string|number
---@param pattern string|number
---@return fun():string, ...
---@nodiscard
function string.gmatch(s, pattern) end

---@param s string|number
---@param pattern string|number
---@param repl string|number|table|function
---@param n? integer
---@return string
---@return integer count
function string.gsub(s, pattern, repl, n) end

---@param s string|number
---@return integer
---@nodiscard
function string.len(s) end

---@param s string|number
---@return string
---@nodiscard
function string.lower(s) end

---@param s string|number
---@param pattern string|number
---@param init? integer
---@return any ...
---@nodiscard
function string.match(s, pattern, init) end

---@param s string|number
---@return string
---@nodiscard
function string.reverse(s) end

---@param s string|number
---@param i integer
---@param j? integer
---@return string
---@nodiscard
function string.sub(s, i, j) end

---@param s string|number
---@return string
---@nodiscard
function string.upper(s) end

-- table: only the sandbox allowlist subset is available.
table = {}

---@overload fun(list: table, value: any)
---@param list table
---@param pos integer
---@param value any
function table.insert(list, pos, value) end

---@param table table
---@return integer
---@nodiscard
function table.maxn(table) end

---@param list table
---@param pos? integer
---@return any
function table.remove(list, pos) end

---@generic T
---@param list T[]
---@param comp? fun(a: T, b: T):boolean
function table.sort(list, comp) end

-- math: everything except math.randomseed is available.

---@class mathlib
---@field huge number
---@field pi number
math = {}

---@generic Number: number
---@param x Number
---@return Number
---@nodiscard
function math.abs(x) end

---@param x number
---@return number
---@nodiscard
function math.acos(x) end

---@param x number
---@return number
---@nodiscard
function math.asin(x) end

---@param y number
---@return number
---@nodiscard
function math.atan(y) end

---@param y number
---@param x number
---@return number
---@nodiscard
function math.atan2(y, x) end

---@param x number
---@return integer
---@nodiscard
function math.ceil(x) end

---@param x number
---@return number
---@nodiscard
function math.cos(x) end

---@param x number
---@return number
---@nodiscard
function math.cosh(x) end

---@param x number
---@return number
---@nodiscard
function math.deg(x) end

---@param x number
---@return number
---@nodiscard
function math.exp(x) end

---@param x number
---@return integer
---@nodiscard
function math.floor(x) end

---@param x number
---@param y number
---@return number
---@nodiscard
function math.fmod(x, y) end

---@param x number
---@return number m
---@return number e
---@nodiscard
function math.frexp(x) end

---@param m number
---@param e number
---@return number
---@nodiscard
function math.ldexp(m, e) end

---@param x number
---@param base? integer
---@return number
---@nodiscard
function math.log(x, base) end

---@param x number
---@return number
---@nodiscard
function math.log10(x) end

---@generic Number: number
---@param x Number
---@param ... Number
---@return Number
---@nodiscard
function math.max(x, ...) end

---@generic Number: number
---@param x Number
---@param ... Number
---@return Number
---@nodiscard
function math.min(x, ...) end

---@param x number
---@return integer
---@return number
---@nodiscard
function math.modf(x) end

---@param x number
---@param y number
---@return number
---@nodiscard
function math.pow(x, y) end

---@param x number
---@return number
---@nodiscard
function math.rad(x) end

---@overload fun():number
---@overload fun(m: integer):integer
---@param m integer
---@param n integer
---@return integer
---@nodiscard
function math.random(m, n) end

---@param x number
---@return number
---@nodiscard
function math.sin(x) end

---@param x number
---@return number
---@nodiscard
function math.sinh(x) end

---@param x number
---@return number
---@nodiscard
function math.sqrt(x) end

---@param x number
---@return number
---@nodiscard
function math.tan(x) end

---@param x number
---@return number
---@nodiscard
function math.tanh(x) end
