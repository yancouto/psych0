local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

---@class Bullet
---@field pos Vector
---@field vel Vector
---@field radius number
---@field to_remove boolean
---@field hue number

local Bullet = {}
Bullet.__index = Bullet

---@param pos Vector
---@param vel Vector
---@return Bullet
function Bullet.new(pos, vel)
	return setmetatable({
		pos = pos,
		vel = vel,
		radius = 5,
		to_remove = false,
		hue = 0,
	}, Bullet)
end

---@param self Bullet
---@param dt number
function Bullet.update(self, dt)
	self.pos = self.pos + self.vel * dt
	self.hue = (self.hue + dt * 200) % 360
end

---@param self Bullet
function Bullet.draw(self)
	local rgb = HSLuv.hsluv_to_rgb { self.hue, 100, 50 }
	love.graphics.setColor(rgb[1], rgb[2], rgb[3])
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

---@param self Bullet
---@return number, number, number, number
function Bullet.aabb(self)
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Bullet
