local Vec = require "hump/vector"

local Bullet = {}
Bullet.__index = Bullet

export type BulletProps = {
	pos: Vec.Vector,
	vel: Vec.Vector,
	radius: number,
	to_remove: boolean,
}

export type Bullet = typeof(setmetatable({} :: BulletProps, Bullet))

function Bullet.new(pos: Vec.Vector, vel: Vec.Vector): Bullet
	return setmetatable({
		pos = pos,
		vel = vel,
		radius = 5,
		to_remove = false,
	}, Bullet)
end

function Bullet:update(dt: number)
	self.pos += self.vel * dt
end

function Bullet:draw()
	love.graphics.setColor(1, 1, 0)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

function Bullet:aabb()
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Bullet
