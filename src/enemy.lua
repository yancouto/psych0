local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

---@class Enemy
---@field pos Vector
---@field vel Vector
---@field radius number
---@field to_remove boolean
---@field hue number
---@field time number

local Enemy = {}
Enemy.__index = Enemy

---@param pos Vector
---@param vel Vector
---@param radius number?
---@return Enemy
function Enemy.new(pos, vel, radius)
	return setmetatable({
		pos = pos,
		vel = vel,
		radius = radius or 15,
		to_remove = false,
		hue = 10,
		time = math.random() * math.pi * 2,
	}, Enemy)
end

---@param self Enemy
---@param dt number
function Enemy.update(self, dt)
	self.pos = self.pos + self.vel * dt
	self.time = self.time + dt
	self.hue = 10 + math.sin(self.time * 2) * 20 -- Oscillates between -10 and 30
	if self.hue < 0 then self.hue = self.hue + 360 end
end

---@param self Enemy
function Enemy.draw(self)
	local rgb = HSLuv.hsluv_to_rgb({ self.hue, 100, 50 })
	love.graphics.setColor(rgb[1], rgb[2], rgb[3])
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

---@param self Enemy
---@return number, number, number, number
function Enemy.aabb(self)
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Enemy
