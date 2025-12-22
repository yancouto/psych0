--[[
Copyright (c) 2010-2015 Matthias Richter

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

local _PATH = (...):match "^(.*[%./])[^%.%/]+$" or ""
local cos, sin = math.cos, math.sin

local camera = {}
camera.__index = camera

export type Smoother = (dx: number, dy: number, ...any) -> (number, number)

export type Camera = {
	x: number,
	y: number,
	scale: number,
	rot: number,
	smoother: Smoother,
	_sx: number,
	_sy: number,
	_sw: number,
	_sh: number,
	lookAt: (self: Camera, x: number, y: number) -> Camera,
	move: (self: Camera, dx: number, dy: number) -> Camera,
	position: (self: Camera) -> (number, number),
	rotate: (self: Camera, phi: number) -> Camera,
	rotateTo: (self: Camera, phi: number) -> Camera,
	zoom: (self: Camera, mul: number) -> Camera,
	zoomTo: (self: Camera, zoom: number) -> Camera,
	attach: (self: Camera, x: number?, y: number?, w: number?, h: number?, noclip: boolean?) -> (),
	detach: (self: Camera) -> (),
	draw: (self: Camera, ...any) -> (),
	cameraCoords: (
		self: Camera,
		x: number,
		y: number,
		ox: number?,
		oy: number?,
		w: number?,
		h: number?
	) -> (number, number),
	worldCoords: (
		self: Camera,
		x: number,
		y: number,
		ox: number?,
		oy: number?,
		w: number?,
		h: number?
	) -> (number, number),
	mousePosition: (self: Camera, ox: number?, oy: number?, w: number?, h: number?) -> (number, number),
	lockX: (self: Camera, x: number, smoother: Smoother?, ...any) -> Camera,
	lockY: (self: Camera, y: number, smoother: Smoother?, ...any) -> Camera,
	lockPosition: (self: Camera, x: number, y: number, smoother: Smoother?, ...any) -> Camera,
	lockWindow: (
		self: Camera,
		x: number,
		y: number,
		x_min: number,
		x_max: number,
		y_min: number,
		y_max: number,
		smoother: Smoother?,
		...any
	) -> (),
}

-- Movement interpolators (for camera locking/windowing)
camera.smooth = {}

function camera.smooth.none(): Smoother
	return function(dx, dy) return dx, dy end
end

function camera.smooth.linear(speed: number): Smoother
	assert(type(speed) == "number", "Invalid parameter: speed = " .. tostring(speed))
	return function(dx, dy, s)
		-- normalize direction
		local d = math.sqrt(dx * dx + dy * dy)
		local dts = math.min((s or speed) * love.timer.getDelta(), d) -- prevent overshooting the goal
		if d > 0 then
			dx, dy = dx / d, dy / d
		end

		return dx * dts, dy * dts
	end
end

function camera.smooth.damped(stiffness: number): Smoother
	assert(type(stiffness) == "number", "Invalid parameter: stiffness = " .. tostring(stiffness))
	return function(dx, dy, s)
		local dts = love.timer.getDelta() * (s or stiffness)
		return dx * dts, dy * dts
	end
end

local function new(x: number?, y: number?, zoom: number?, rot: number?, smoother: Smoother?): Camera
	x, y = x or love.graphics.getWidth() / 2, y or love.graphics.getHeight() / 2
	zoom = zoom or 1
	rot = rot or 0
	smoother = smoother or camera.smooth.none() -- for locking, see below
	return setmetatable({ x = x, y = y, scale = zoom, rot = rot, smoother = smoother } :: any, camera)
end

function camera:lookAt(x: number, y: number): Camera
	self.x, self.y = x, y
	return self
end

function camera:move(dx: number, dy: number): Camera
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

function camera:position(): (number, number) return self.x, self.y end

function camera:rotate(phi: number): Camera
	self.rot = self.rot + phi
	return self
end

function camera:rotateTo(phi: number): Camera
	self.rot = phi
	return self
end

function camera:zoom(mul: number): Camera
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom: number): Camera
	self.scale = zoom
	return self
end

function camera:attach(x: number?, y: number?, w: number?, h: number?, noclip: boolean?)
	x, y = x or 0, y or 0
	w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	local sx, sy, sw, sh = love.graphics.getScissor()
	self._sx, self._sy, self._sw, self._sh = sx, sy, sw, sh
	if not noclip then love.graphics.setScissor(x :: number, y :: number, w :: number, h :: number) end

	local cx, cy = (x :: number) + (w :: number) / 2, (y :: number) + (h :: number) / 2
	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.scale(self.scale, self.scale)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
	love.graphics.setScissor(self._sx, self._sy, self._sw, self._sh)
end

function camera:draw(...)
	local x, y, w, h, noclip, func
	local nargs = select("#", ...)
	if nargs == 1 then
		func = ...
	elseif nargs == 5 then
		x, y, w, h, func = ...
	elseif nargs == 6 then
		x, y, w, h, noclip, func = ...
	else
		error "Invalid arguments to camera:draw()"
	end

	self:attach(x, y, w, h, noclip)
	func()
	self:detach()
end

-- world coordinates to camera coordinates
function camera:cameraCoords(x: number, y: number, ox: number?, oy: number?, w: number?, h: number?): (number, number)
	ox, oy = ox or 0, oy or 0
	w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local c, s = cos(self.rot), sin(self.rot)
	x, y = x - self.x, y - self.y
	x, y = c * x - s * y, s * x + c * y
	return x * self.scale + (w :: number) / 2 + (ox :: number), y * self.scale + (h :: number) / 2 + (oy :: number)
end

-- camera coordinates to world coordinates
function camera:worldCoords(x: number, y: number, ox: number?, oy: number?, w: number?, h: number?): (number, number)
	ox, oy = ox or 0, oy or 0
	w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local c, s = cos(-self.rot), sin(-self.rot)
	x, y = (x - (w :: number) / 2 - (ox :: number)) / self.scale, (y - (h :: number) / 2 - (oy :: number)) / self.scale
	x, y = c * x - s * y, s * x + c * y
	return x + self.x, y + self.y
end

function camera:mousePosition(ox: number?, oy: number?, w: number?, h: number?): (number, number)
	local mx, my = love.mouse.getPosition()
	return self:worldCoords(mx, my, ox, oy, w, h)
end

-- camera scrolling utilities
function camera:lockX(x: number, smoother: Smoother?, ...): Camera
	local dx, _ = (smoother or self.smoother)(x - self.x, self.y, ...)
	self.x = self.x + dx
	return self
end

function camera:lockY(y: number, smoother: Smoother?, ...): Camera
	local _, dy = (smoother or self.smoother)(self.x, y - self.y, ...)
	self.y = self.y + dy
	return self
end

function camera:lockPosition(x: number, y: number, smoother: Smoother?, ...): Camera
	return self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

function camera:lockWindow(
	x: number,
	y: number,
	x_min: number,
	x_max: number,
	y_min: number,
	y_max: number,
	smoother: Smoother?,
	...
)
	-- figure out displacement in camera coordinates
	local cx, cy = self:cameraCoords(x, y)
	local dx, dy = 0, 0
	if cx < x_min then
		dx = cx - x_min
	elseif cx > x_max then
		dx = cx - x_max
	end
	if cy < y_min then
		dy = cy - y_min
	elseif cy > y_max then
		dy = cy - y_max
	end

	-- transform displacement to movement in world coordinates
	local c, s = cos(-self.rot), sin(-self.rot)
	dx, dy = (c * dx - s * dy) / self.scale, (s * dx + c * dy) / self.scale

	-- move
	self:move((smoother or self.smoother)(dx, dy, ...))
end

-- the module
return setmetatable({ new = new, smooth = camera.smooth }, {
	__call = function(_, ...): Camera return new(...) end,
})
