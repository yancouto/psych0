# Copilot Instructions

## Overview

Psych0 is a Love2D 11.5 bullet-hell game written in plain **Lua** with [LuaLS](https://github.com/LuaLS/lua-language-server) (`---@`) annotations. Love2D runs `src/` directly — no build step required.

## Run, Test & Typecheck

```powershell
# Run the game
make run       # or: lovec src/

# Run tests (headless, all levels through interpreter)
make test      # or: lovec src/ --test

# Typecheck both workspaces (LuaLS)
make typecheck # or: lua-language-server --check src && lua-language-server --check src/levels
```

Tests run every `.lua` file in `src/levels/` through the interpreter and fail if any errors or infinite loops. There is no single-test command; all levels are tested together.

## Architecture

```
src/
  main.lua              — Entry point; detects --test flag or starts Play gamestate
  conf.lua              — Love2D window config
  gamestates/play.lua   — Core game loop: player, bullets, enemies, indicators, rings
  interpreter/init.lua  — Level script interpreter (runs level code in a sandbox coroutine)
  object_list.lua       — Generic container with update/draw/collision/offscreen removal
  libs/                 — Modified HUMP libraries (camera, timer, gamestate, vector, sandbox, hsluv)
  tests.lua             — Runs all levels through the interpreter headlessly
  levels/               — Level scripts (separate LuaLS workspace with sandbox restrictions)
level_script.d.lua      — LuaLS meta file declaring sandbox globals (API, Vec2, Enemy, Side, Placement…)
```

The project uses `psycho.code-workspace` with two LuaLS workspaces: `src/` (full Love2D environment) and `src/levels/` (sandbox environment — most stdlib is disabled, only the sandbox allowlist is declared in `level_script.d.lua`).

**Level execution flow:** `play.lua` reads `src/levels/level1.lua`, passes it to `Interpreter.runLevel()`, which wraps the code in a sandbox coroutine. Each `love.update` tick calls `level_instance:update(dt)`, which resumes the coroutine. `API.Wait()` / `API.WaitUntilNoEnemies()` yield the coroutine with typed result tables.

**Object lifecycle:** All game entities live in `ObjectList`. Objects flag themselves dead via `to_remove = true`; the list compacts on the next `update()`. Collision uses AABB pre-filtering then a caller-provided fine check.

**Coordinate system:** Fixed logical canvas `1280×1024` stored in `_G.WIDTH` / `_G.HEIGHT`. Camera from HUMP wraps Love2D drawing; `cam:attach()` / `cam:detach()` wraps world-space draw calls.

**Velocity units:** Level scripts express speed in small integers (e.g. `7`). `play.lua` multiplies by `50` when constructing enemy velocity vectors, so a script value of `7` → `350 px/s`.

**Focus/slow-motion:** Holding shift sets `player.is_focusing = true`, scaling `dt` by `0.2` for everything except the player itself.

## Level Scripting API

Level files run inside a sandbox with these globals only:

| Global | Description |
|---|---|
| `API` | Main API object |
| `Vec2(x, y)` | Constructs a position/velocity `{x, y}` |
| `Enemy.Simple` / `Enemy.Double` | Enemy type strings |
| `Side.Left/Right/Top/Bottom` | Screen edge constants |
| `Placement.*` | Placement strategy constructors |
| `WIDTH` / `HEIGHT` | Screen dimensions |

Key API calls:
- `API.Wait(seconds)` — pause level script
- `API.WaitUntilNoEnemies()` — pause until enemies + indicators are cleared
- `API.Spawn.Single/Multiple/VerticalLine/HorizontalLine/Circle/Spiral {...}` — spawn enemies
- `API.CustomSpawn { indicator_duration = N }.Single/... {...}` — override indicator duration per spawn
- `API.SetDefaultIndicatorDuration(n)` — set global indicator duration

## Code Style

Formatter: **EmmyLuaCodeStyle** (config in `.editorconfig`):
- Indentation: **Tabs**
- `call_arg_parentheses = remove_table_only` — omit parens only for single table-literal args (e.g. `func {}`)
- `space_before_function_call_single_arg = always` — space before single-arg calls (e.g. `require "libs/timer"`)
- `trailing_table_separator = smart`

Type annotations use LuaLS EmmyLua style (`---@class`, `---@field`, `---@param`, `---@return`).

Object types follow the metatable class pattern:
```lua
---@class Foo
---@field bar number
local Foo = {}
Foo.__index = Foo
```

Requires use paths relative to `src/` (the Love2D game root), without extensions: `require "libs/timer"`, `require "gamestates/play"`.

