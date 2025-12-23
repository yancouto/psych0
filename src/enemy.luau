local Vec = require "hump/vector"

local Enemy = {}
Enemy.__index = Enemy

export type EnemyProps = {
	pos: Vec.Vector,
	vel: Vec.Vector,
	radius: number,
	to_remove: boolean,
}

export type Enemy = typeof(setmetatable({} :: EnemyProps, Enemy))

function Enemy.new(pos: Vec.Vector, vel: Vec.Vector, radius: number?): Enemy
	return setmetatable({
		pos = pos,
		vel = vel,
		radius = radius or 15,
		to_remove = false,
	}, Enemy) :: Enemy
end

function Enemy:update(dt: number)
	self.pos += self.vel * dt
end

function Enemy:draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

function Enemy:aabb()
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Enemy
