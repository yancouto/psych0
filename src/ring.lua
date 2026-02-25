local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

---@class Ring
---@field pos Vector
---@field radius number
---@field max_radius number
---@field thickness number
---@field hue number
---@field alpha number
---@field speed number
---@field to_remove boolean

local Ring = {}
Ring.__index = Ring

---@param pos Vector
---@param radius number
---@param thickness number
---@param hue number
---@param speed number
---@return Ring
function Ring.new(pos, radius, thickness, hue, speed)
	local w, h = WIDTH, HEIGHT
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

---@param self Ring
---@param dt number
function Ring.update(self, dt)
	self.radius = self.radius + self.speed * dt
	self.alpha = 1 - (self.radius / self.max_radius)
	if self.radius >= self.max_radius or self.alpha <= 0 then
		self.to_remove = true
	end
end

---@param self Ring
function Ring.draw(self)
	local rgb = HSLuv.hsluv_to_rgb { self.hue, 100, 50 }
	love.graphics.setLineWidth(self.thickness)
	love.graphics.setColor(rgb[1], rgb[2], rgb[3], self.alpha * 0.3) -- Dim by default, multiplied by fading alpha
	love.graphics.circle("line", self.pos.x, self.pos.y, self.radius)
end

return Ring
