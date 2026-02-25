local Vec = require "libs/vector"

---@class Indicator
---@field pos Vector
---@field vel Vector
---@field duration number
---@field elapsed number
---@field radius number
---@field to_remove boolean

local Indicator = {}
Indicator.__index = Indicator

---@param pos Vector
---@param vel Vector
---@param duration number
---@param radius number?
---@return Indicator
function Indicator.new(pos, vel, duration, radius)
	return setmetatable({
		pos = pos,
		vel = vel,
		duration = duration,
		elapsed = 0,
		radius = radius or 20,
		to_remove = false,
	}, Indicator)
end

---@param self Indicator
---@param dt number
function Indicator.update(self, dt)
	self.elapsed = self.elapsed + dt
	if self.elapsed >= self.duration then
		self.to_remove = true
	end
end

---@param self Indicator
function Indicator.draw(self)
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
