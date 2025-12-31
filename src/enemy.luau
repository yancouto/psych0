local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

local Enemy = {}
Enemy.__index = Enemy

export type EnemyProps = {
	pos: Vec.Vector,
	vel: Vec.Vector,
	radius: number,
	to_remove: boolean,
	hue: number,
	time: number,
}

export type Enemy = typeof(setmetatable({} :: EnemyProps, Enemy))

function Enemy.new(pos: Vec.Vector, vel: Vec.Vector, radius: number?): Enemy
	return setmetatable({
		pos = pos,
		vel = vel,
		radius = radius or 15,
		to_remove = false,
		hue = 10,
		time = math.random() * math.pi * 2,
	}, Enemy) :: Enemy
end

function Enemy.update(self: Enemy, dt: number)
	self.pos += self.vel * dt
	self.time += dt
	self.hue = 10 + math.sin(self.time * 2) * 20 -- Oscillates between -10 and 30
	if self.hue < 0 then self.hue += 360 end
end

function Enemy.draw(self: Enemy)
	local rgb = HSLuv.hsluv_to_rgb({ self.hue, 100, 50 })
	love.graphics.setColor(rgb[1], rgb[2], rgb[3])
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

function Enemy.aabb(self: Enemy)
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Enemy
