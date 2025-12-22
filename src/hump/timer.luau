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

local Timer = {}
Timer.__index = Timer

export type TimerHandle = {
	time: number,
	after: (handle: TimerHandle) -> boolean?,
	during: (dt: number, limit: number) -> (),
	limit: number,
	count: number,
}

export type Timer = {
	functions: { [TimerHandle]: boolean },
	update: (self: Timer, dt: number) -> (),
	during: (
		self: Timer,
		delay: number,
		during: (dt: number, limit: number) -> (),
		after: ((handle: TimerHandle) -> boolean?)?
	) -> TimerHandle,
	after: (self: Timer, delay: number, func: (handle: TimerHandle) -> boolean?) -> TimerHandle,
	every: (self: Timer, delay: number, after: (handle: TimerHandle) -> boolean?, count: number?) -> TimerHandle,
	cancel: (self: Timer, handle: TimerHandle) -> (),
	clear: (self: Timer) -> (),
	script: (self: Timer, f: (wait: (t: number) -> ()) -> ()) -> (),
	tween: Tween,
}

export type TweenMethod = (s: number, ...any) -> number

export type Tween = {
	((
		self: Timer,
		len: number,
		subject: any,
		target: any,
		method: (TweenMethod | string)?,
		after: ((handle: TimerHandle) -> boolean?)?,
		...any
	) -> TimerHandle)
	& {
		out: (f: TweenMethod) -> TweenMethod,
		chain: (f1: TweenMethod, f2: TweenMethod) -> TweenMethod,
		linear: TweenMethod,
		quad: TweenMethod,
		cubic: TweenMethod,
		quart: TweenMethod,
		quint: TweenMethod,
		sine: TweenMethod,
		expo: TweenMethod,
		circ: TweenMethod,
		back: (s: number, bounciness: number?) -> number,
		bounce: TweenMethod,
		elastic: (s: number, amp: number?, period: number?) -> number,
		[string]: TweenMethod,
	}
}

local function _nothing_() end

local function updateTimerHandle(handle: TimerHandle, dt: number)
	-- handle: {
	--   time = <number>,
	--   after = <function>,
	--   during = <function>,
	--   limit = <number>,
	--   count = <number>,
	-- }
	handle.time = handle.time + dt
	handle.during(dt, math.max(handle.limit - handle.time, 0))

	while handle.time >= handle.limit and handle.count > 0 do
		if handle.after(handle) == false then
			handle.count = 0
			break
		end
		handle.time = handle.time - handle.limit
		handle.count = handle.count - 1
	end
end

function Timer:update(dt: number)
	-- timers may create new timers, which leads to undefined behavior
	-- in pairs() - so we need to put them in a different table first
	local to_update: { [TimerHandle]: TimerHandle } = {}
	for handle in pairs(self.functions) do
		to_update[handle] = handle
	end

	for handle in pairs(to_update) do
		if self.functions[handle] then
			updateTimerHandle(handle, dt)
			if handle.count == 0 then self.functions[handle] = nil end
		end
	end
end

function Timer:during(
	delay: number,
	during: (dt: number, limit: number) -> (),
	after: ((handle: TimerHandle) -> boolean?)?
): TimerHandle
	local handle = { time = 0, during = during, after = after or _nothing_, limit = delay, count = 1 }
	self.functions[handle] = true
	return handle
end

function Timer:after(delay: number, func: (handle: TimerHandle) -> boolean?): TimerHandle
	return self:during(delay, _nothing_, func)
end

function Timer:every(delay: number, after: (handle: TimerHandle) -> boolean?, count: number?): TimerHandle
	local count_val = count or math.huge -- exploit below: math.huge - 1 = math.huge
	local handle = { time = 0, during = _nothing_, after = after, limit = delay, count = count_val }
	self.functions[handle] = true
	return handle
end

function Timer:cancel(handle: TimerHandle) self.functions[handle] = nil end

function Timer:clear() self.functions = {} end

function Timer:script(f: (wait: (t: number) -> ()) -> ())
	local co = coroutine.wrap(f)
	co(function(t: number)
		self:after(t, co)
		coroutine.yield()
	end)
end

Timer.tween = setmetatable({
	-- helper functions
	out = function(f: TweenMethod): TweenMethod -- 'rotates' a function
		return function(s: number, ...: any) return 1 - f(1 - s, ...) end
	end,
	chain = function(f1: TweenMethod, f2: TweenMethod): TweenMethod -- concatenates two functions
		return function(s: number, ...: any) return (s < 0.5 and f1(2 * s, ...) or 1 + f2(2 * s - 1, ...)) * 0.5 end
	end,

	-- useful tweening functions
	linear = function(s: number) return s end,
	quad = function(s: number) return s * s end,
	cubic = function(s: number) return s * s * s end,
	quart = function(s: number) return s * s * s * s end,
	quint = function(s: number) return s * s * s * s * s end,
	sine = function(s: number) return 1 - math.cos(s * math.pi / 2) end,
	expo = function(s: number) return 2 ^ (10 * (s - 1)) end,
	circ = function(s: number) return 1 - math.sqrt(1 - s * s) end,

	back = function(s: number, bounciness: number?)
		bounciness = bounciness or 1.70158
		return s * s * ((bounciness :: number + 1) * s - bounciness :: number)
	end,

	bounce = function(s: number) -- magic numbers ahead
		local a, b = 7.5625, 1 / 2.75
		return math.min(
			a * s ^ 2,
			a * (s - 1.5 * b) ^ 2 + 0.75,
			a * (s - 2.25 * b) ^ 2 + 0.9375,
			a * (s - 2.625 * b) ^ 2 + 0.984375
		)
	end,

	elastic = function(s: number, amp: number?, period: number?)
		amp, period = amp and math.max(1, amp) or 1, period or 0.3
		return (-amp :: number * math.sin(2 * math.pi / period :: number * (s - 1) - math.asin(1 / amp :: number)))
			* 2 ^ (10 * (s - 1))
	end,
}, {

	-- register new tween
	__call = function(
		tween: any,
		self: Timer,
		len: number,
		subject: any,
		target: any,
		method: (TweenMethod | string)?,
		after: ((handle: TimerHandle) -> boolean?)?,
		...
	)
		-- recursively collects fields that are defined in both subject and target into a flat list
		local function tween_collect_payload(subject: any, target: any, out: { any })
			for k, v in pairs(target) do
				local ref = subject[k]
				assert(type(v) == type(ref), 'Type mismatch in field "' .. k .. '".')
				if type(v) == "table" then
					tween_collect_payload(ref, v, out)
				else
					local ok, delta = pcall(function() return (v - ref) * 1 end)
					assert(ok, 'Field "' .. k .. '" does not support arithmetic operations')
					out[#out + 1] = { subject, k, delta }
				end
			end
			return out
		end

		local method_fn = tween[method or "linear"] -- see __index
		local payload, t, args = tween_collect_payload(subject, target, {}), 0, { ... }

		local last_s = 0
		return self:during(len, function(dt: number)
			t = t + dt
			local s = method_fn(math.min(1, t / len), unpack(args))
			local ds = s - last_s
			last_s = s
			for _, info in ipairs(payload) do
				local ref, key, delta = unpack(info)
				ref[key] = ref[key] + delta * ds
			end
		end, after)
	end,

	-- fetches function and generated compositions for method `key`
	__index = function(tweens: any, key: string | TweenMethod)
		if type(key) == "function" then return key end

		assert(type(key) == "string", "Method must be function or string.")
		if rawget(tweens, key) then return rawget(tweens, key) end

		local function construct(pattern: string, f: (TweenMethod) -> TweenMethod)
			local method_name = (key :: string):match(pattern)
			local method = if method_name then rawget(tweens, method_name) else nil
			if method then return f(method) end
			return nil
		end

		local out, chain = rawget(tweens, "out"), rawget(tweens, "chain")
		return construct("^in%-([^-]+)$", function(f) return f end)
			or construct("^out%-([^-]+)$", out)
			or construct("^in%-out%-([^-]+)$", function(f) return chain(f, out(f)) end)
			or construct("^out%-in%-([^-]+)$", function(f) return chain(out(f), f) end)
			or error("Unknown interpolation method: " .. (key :: string))
	end,
})

-- Timer instancing
function Timer.new(): Timer return setmetatable({ functions = {}, tween = Timer.tween } :: any, Timer) end

-- default instance
local default = Timer.new()

-- module forwards calls to default instance
local module = {}
for k, v in pairs(Timer) do
	if k ~= "__index" and type(v) == "function" then module[k] = function(...) return default[k](default, ...) end end
end
module.tween = setmetatable({}, {
	__index = Timer.tween,
	__newindex = function(_, k, v) Timer.tween[k] = v end,
	__call = function(_, ...) return default:tween(...) end,
})

return setmetatable(module, { __call = function() return Timer.new() end })
