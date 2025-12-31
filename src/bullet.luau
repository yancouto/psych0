local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

local Bullet = {}
Bullet.__index = Bullet

export type BulletProps = {
	pos: Vec.Vector,
	vel: Vec.Vector,
	radius: number,
	to_remove: boolean,
	hue: number,
}

export type Bullet = typeof(setmetatable({} :: BulletProps, Bullet))

function Bullet.new(pos: Vec.Vector, vel: Vec.Vector): Bullet
	return setmetatable({
		pos = pos,
		vel = vel,
		radius = 5,
		to_remove = false,
		hue = 0,
	}, Bullet)
end

function Bullet.update(self: Bullet, dt: number)
	self.pos += self.vel * dt
	self.hue = (self.hue + dt * 200) % 360
end

function Bullet.draw(self: Bullet)
	local rgb = HSLuv.hsluv_to_rgb { self.hue, 100, 50 }
	love.graphics.setColor(rgb[1], rgb[2], rgb[3])
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

function Bullet.aabb(self: Bullet)
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Bullet
