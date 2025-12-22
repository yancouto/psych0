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

local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local vector = {}
vector.__index = vector

export type VectorData = {
	x: number,
	y: number,
}

export type Vector = typeof(setmetatable({} :: VectorData, vector))

local function new(x: number?, y: number?): Vector return setmetatable({ x = x or 0, y = y or 0 }, vector) :: any end
local zero = new(0, 0)

local function fromPolar(angle: number, radius: number?): Vector
	radius = radius or 1
	return new(cos(angle) * radius, sin(angle) * radius)
end

local function randomDirection(len_min: number?, len_max: number?): Vector
	local l_min = len_min or 1
	local l_max = len_max or l_min

	assert(l_max > 0, "len_max must be greater than zero")
	assert(l_max >= l_min, "len_max must be greater than or equal to len_min")

	return fromPolar(math.random() * 2 * math.pi, math.random() * (l_max - l_min) + l_min)
end

local function isvector(v: any): boolean return type(v) == "table" and type(v.x) == "number" and type(v.y) == "number" end

function vector:clone(): Vector return new(self.x, self.y) end

function vector:unpack(): (number, number) return self.x, self.y end

function vector:__tostring(): string return "(" .. self.x .. "," .. self.y .. ")" end

function vector.__unm(a: Vector): Vector return new(-a.x, -a.y) end

function vector.__add(a: Vector, b: Vector): Vector
	assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
	return new(a.x + b.x, a.y + b.y)
end

function vector.__sub(a: Vector, b: Vector): Vector
	assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
	return new(a.x - b.x, a.y - b.y)
end

function vector.__mul(a: Vector | number, b: Vector | number): Vector | number
	if type(a) == "number" then
		return new(a * (b :: Vector).x, a * (b :: Vector).y)
	elseif type(b) == "number" then
		return new(b * (a :: Vector).x, b * (a :: Vector).y)
	else
		assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
		return (a :: Vector).x * (b :: Vector).x + (a :: Vector).y * (b :: Vector).y
	end
end

function vector.__div(a: Vector, b: number): Vector
	assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return new(a.x / b, a.y / b)
end

function vector.__eq(a: Vector, b: Vector): boolean return a.x == b.x and a.y == b.y end

function vector.__lt(a: Vector, b: Vector): boolean return a.x < b.x or (a.x == b.x and a.y < b.y) end

function vector.__le(a: Vector, b: Vector): boolean return a.x <= b.x and a.y <= b.y end

function vector.permul(a: Vector, b: Vector): Vector
	assert(isvector(a) and isvector(b), "permul: wrong argument types (<vector> expected)")
	return new(a.x * b.x, a.y * b.y)
end

function vector:toPolar(): Vector return new(atan2(self.x, self.y), self:len()) end

function vector:len2(): number return self.x * self.x + self.y * self.y end

function vector:len(): number return sqrt(self.x * self.x + self.y * self.y) end

function vector.dist(a: Vector, b: Vector): number
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

function vector.dist2(a: Vector, b: Vector): number
	local dx = a.x - b.x
	local dy = a.y - b.y
	return (dx * dx + dy * dy)
end

function vector:normalizeInplace(): Vector
	local l = self:len()
	if l > 0 then
		self.x, self.y = self.x / l, self.y / l
	end
	return self
end

function vector:normalized(): Vector return self:clone():normalizeInplace() end

function vector:rotateInplace(phi: number): Vector
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function vector:rotated(phi: number): Vector
	local c, s = cos(phi), sin(phi)
	return new(c * self.x - s * self.y, s * self.x + c * self.y)
end

function vector:perpendicular(): Vector return new(-self.y, self.x) end

function vector:projectOn(v: Vector): Vector
	-- (self * v) * v / v:len2()
	local s = (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return new(s * v.x, s * v.y)
end

function vector:mirrorOn(v: Vector): Vector
	-- 2 * self:projectOn(v) - self
	local s = 2 * (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return new(s * v.x - self.x, s * v.y - self.y)
end

function vector:cross(v: Vector): number
	return self.x * v.y - self.y * v.x
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vector:trimInplace(maxLen: number): Vector
	local s = maxLen * maxLen / self:len2()
	s = (s > 1 and 1) or math.sqrt(s)
	self.x, self.y = self.x * s, self.y * s
	return self
end

function vector:angleTo(other: Vector?): number
	if other then return atan2(self.y, self.x) - atan2((other :: Vector).y, (other :: Vector).x) end
	return atan2(self.y, self.x)
end

function vector:trimmed(maxLen: number): Vector return self:clone():trimInplace(maxLen) end

-- the module
return setmetatable({
	new = new,
	fromPolar = fromPolar,
	randomDirection = randomDirection,
	isvector = isvector,
	zero = zero,
}, {
	__call = function(_, ...): Vector return new(...) end,
})
