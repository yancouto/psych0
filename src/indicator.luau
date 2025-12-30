local Vec = require "libs/vector"

local Indicator = {}
Indicator.__index = Indicator

export type IndicatorProps = {
	pos: Vec.Vector,
	vel: Vec.Vector,
	duration: number,
	elapsed: number,
	radius: number,
	to_remove: boolean,
}

export type Indicator = typeof(setmetatable({} :: IndicatorProps, Indicator))

function Indicator.new(pos: Vec.Vector, vel: Vec.Vector, duration: number, radius: number?): Indicator
	return setmetatable({
		pos = pos,
		vel = vel,
		duration = duration,
		elapsed = 0,
		radius = radius or 20,
		to_remove = false,
	}, Indicator)
end

function Indicator:update(dt: number)
	self.elapsed += dt
	if self.elapsed >= self.duration then
		self.to_remove = true
	end
end

function Indicator:draw()
	local alpha = 0.5 + 0.5 * math.sin(self.elapsed * 20) -- Flashing
	love.graphics.setColor(1, 1, 0, alpha)

	local remaining = (1 - (self.elapsed / self.duration)) * 0.3
	local angle = self.vel:angleTo()
	local arc_angle = math.pi * 2 * remaining

	local start_angle = angle - arc_angle / 2
	local end_angle = angle + arc_angle / 2
	love.graphics.arc("line", "open", self.pos.x, self.pos.y, self.radius, start_angle, end_angle)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x + math.cos(start_angle) * self.radius, self.pos.y + math.sin(start_angle) * self.radius)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x + math.cos(end_angle) * self.radius, self.pos.y + math.sin(end_angle) * self.radius)
end

return Indicator
