local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

local Explosion = {}
Explosion.__index = Explosion

export type ExplosionProps = {
	pos: Vec.Vector,
	time: number,
	duration: number,
	radius: number,
	to_remove: boolean,
	hue: number,
}

export type Explosion = typeof(setmetatable({} :: ExplosionProps, Explosion))

function Explosion.new(pos: Vec.Vector, radius: number, hue: number): Explosion
	return setmetatable({
		pos = pos,
		time = 0,
		duration = 0.5,
		radius = radius * 2,
		to_remove = false,
		hue = hue,
	}, Explosion)
end

function Explosion.update(self: Explosion, dt: number)
	self.time += dt
	if self.time >= self.duration then self.to_remove = true end
end

function Explosion.draw(self: Explosion)
	local progress = self.time / self.duration
	local alpha = 1 - progress
	local current_radius = self.radius * (1 + progress)

	local rgb = HSLuv.hsluv_to_rgb { self.hue, 100, 50 }
	love.graphics.setColor(rgb[1], rgb[2], rgb[3], alpha)
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", self.pos.x, self.pos.y, current_radius)
end

return Explosion
