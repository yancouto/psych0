local HSLuv = require "libs/hsluv"

---@class Background
---@field time number
---@field update fun(self: Background, dt: number)
---@field draw fun(self: Background)

local Background = {}
Background.__index = Background

---@return Background
function Background.new()
	return setmetatable({
		time = 0,
	}, Background)
end

---@param dt number
function Background.update(self, dt)
	self.time = self.time + dt
end

---@param self Background
function Background.draw(self)
	local w, h = WIDTH, HEIGHT
	local cellSize = 40
	local cols = math.ceil(w / cellSize) + 1
	local rows = math.ceil(h / cellSize) + 1

	for i = 0, cols do
		for j = 0, rows do
			local x = i * cellSize
			local y = j * cellSize

			local dist = math.sqrt((x - w / 2) ^ 2 + (y - h / 2) ^ 2)
			local hue = (dist * 0.1 + self.time * 50) % 360
			local radius = (math.sin(dist * 0.05 - self.time * 5) + 1) * cellSize * 0.4

			local rgb = HSLuv.hsluv_to_rgb({ hue, 60, 10 })
			love.graphics.setColor(rgb[1], rgb[2], rgb[3])
			love.graphics.circle("fill", x, y, radius)
		end
	end
end

return Background
