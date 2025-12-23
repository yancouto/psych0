local Vec = require "libs/vector"

local Player = {}
Player.__index = Player

export type PlayerProps = {
	pos: Vec.Vector,
	radius: number,
	speed: number,
}

export type Player = typeof(setmetatable({} :: PlayerProps, Player))

function Player.new(x: number, y: number): Player
	return setmetatable({
		pos = Vec(x, y),
		radius = 20,
		speed = 400,
	}, Player)
end

function Player:update(dt: number, keys: { [string]: boolean })
	local move = Vec(0, 0)
	if keys.a then move.x = -1 end
	if keys.d then move.x = 1 end
	if keys.s then move.y = 1 end
	if keys.w then move.y = -1 end
	move:normalizeInplace()

	self.pos += move * self.speed * dt

	-- Clamp to screen
	local w, h = love.graphics.getDimensions()
	self.pos.x = math.max(self.radius, math.min(w - self.radius, self.pos.x))
	self.pos.y = math.max(self.radius, math.min(h - self.radius, self.pos.y))
end

function Player:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

return Player
