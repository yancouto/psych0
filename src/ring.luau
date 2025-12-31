local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

local Ring = {}
Ring.__index = Ring

export type RingProps = {
	pos: Vec.Vector,
	radius: number,
	max_radius: number,
	thickness: number,
	hue: number,
	alpha: number,
	speed: number,
	to_remove: boolean,
}

export type Ring = typeof(setmetatable({} :: RingProps, Ring))

function Ring.new(pos: Vec.Vector, radius: number, thickness: number, hue: number, speed: number): Ring
	local w, h = love.graphics.getDimensions()
	-- Calculate max_radius: distance to the farthest corner
	local corners = {
		{ x = 0, y = 0 },
		{ x = w, y = 0 },
		{ x = 0, y = h },
		{ x = w, y = h },
	}
	local max_radius = 0
	for _, corner in ipairs(corners) do
		local dx = pos.x - corner.x
		local dy = pos.y - corner.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist > max_radius then
			max_radius = dist
		end
	end

	return setmetatable({
		pos = pos,
		radius = radius,
		max_radius = max_radius,
		thickness = thickness,
		hue = hue,
		alpha = 1,
		speed = speed,
		to_remove = false,
	}, Ring)
end

function Ring.update(self: Ring, dt: number)
	self.radius += self.speed * dt
	self.alpha = 1 - (self.radius / self.max_radius)
	if self.radius >= self.max_radius or self.alpha <= 0 then
		self.to_remove = true
	end
end

function Ring.draw(self: Ring)
	local rgb = HSLuv.hsluv_to_rgb { self.hue, 100, 50 }
	love.graphics.setLineWidth(self.thickness)
	love.graphics.setColor(rgb[1], rgb[2], rgb[3], self.alpha * 0.3) -- Dim by default, multiplied by fading alpha
	love.graphics.circle("line", self.pos.x, self.pos.y, self.radius)
end

return Ring
