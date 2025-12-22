--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
--

local function __NULL__() end

export type GameState = {
	init: ((self: GameState) -> ())?,
	enter: ((self: GameState, pre: GameState, ...any) -> any)?,
	leave: ((self: GameState) -> ())?,
	resume: ((self: GameState, pre: GameState, ...any) -> any)?,
	update: ((self: GameState, dt: number) -> ())?,
	draw: ((self: GameState) -> ())?,
	keypressed: ((self: GameState, key: string) -> ())?,
	keyreleased: ((self: GameState, key: string) -> ())?,
	[string]: (self: GameState, ...any) -> any,
}

-- default gamestate produces error on every callback
local state_init: GameState = setmetatable(
	{ leave = __NULL__ } :: any,
	{ __index = function() error "Gamestate not initialized. Use Gamestate.switch()" end }
)
local stack: { GameState } = { state_init }
local initialized_states: { [GameState]: any } = setmetatable({} :: any, { __mode = "k" })
local state_is_dirty = true

local GS = {}

function GS.new(t: GameState?): GameState return t or {} end -- constructor - deprecated!

local function change_state(stack_offset: number, to: GameState, ...)
	local pre = stack[#stack]

	-- initialize only on first call
	local init = initialized_states[to] or to.init or __NULL__;
	(init :: (GameState) -> ())(to)
	initialized_states[to] = __NULL__

	stack[#stack + stack_offset] = to
	state_is_dirty = true
	local enter = to.enter or __NULL__
	return (enter :: (GameState, GameState, ...any) -> any)(to, pre, ...)
end

function GS.switch(to: GameState, ...)
	assert(to, "Missing argument: Gamestate to switch to")
	assert(to ~= GS, "Can't call switch with colon operator")
	local leave = stack[#stack].leave or __NULL__;
	(leave :: (GameState) -> ())(stack[#stack])
	return change_state(0, to, ...)
end

function GS.push(to: GameState, ...)
	assert(to, "Missing argument: Gamestate to switch to")
	assert(to ~= GS, "Can't call push with colon operator")
	return change_state(1, to, ...)
end

function GS.pop(...)
	assert(#stack > 1, "No more states to pop!")
	local pre, to = stack[#stack], stack[#stack - 1]
	stack[#stack] = nil
	local leave = pre.leave or __NULL__;
	(leave :: (GameState) -> ())(pre)
	state_is_dirty = true
	local resume = to.resume or __NULL__
	return (resume :: (GameState, GameState, ...any) -> any)(to, pre, ...)
end

function GS.current(): GameState return stack[#stack] end

-- XXX: don't overwrite love.errorhandler by default:
--      this callback is different than the other callbacks
--      (see http://love2d.org/wiki/love.errorhandler)
--      overwriting thi callback can result in random crashes (issue #95)
local all_callbacks: { string } = { "draw", "update" }

-- fetch event callbacks from love.handlers
for k in pairs((love :: any).handlers) do
	all_callbacks[#all_callbacks + 1] = k
end

function GS.registerEvents(callbacks: { string }?)
	local registry = {}
	callbacks = callbacks or all_callbacks
	for _, f in ipairs(callbacks :: { string }) do
		registry[f] = (love)[f] or __NULL__;
		(love)[f] = function(...)
			registry[f](...)
			return (GS)[f](...)
		end
	end
end

-- forward any undefined functions
setmetatable(GS, {
	__index = function(_, func)
		-- call function only if at least one 'update' was called beforehand
		-- (see issue #46)
		if not state_is_dirty or func == "update" then
			state_is_dirty = false
			return function(...)
				local f = stack[#stack][func] or __NULL__
				return (f :: (GameState, ...any) -> any)(stack[#stack], ...)
			end
		end
		return __NULL__
	end,
})

return GS
