local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

local Timer = require "libs/timer"

local Player = {}
Player.__index = Player

local Ring = require "ring"

export type PlayerProps = {
	pos: Vec.Vector,
	radius: number,
	base_radius: number,
	speed: number,
	dead: boolean,
	hue: number,
	focus: number, -- 0 to 1
	is_focusing: boolean,
	timer: Timer.Timer,
	ring_timer: number,
}

export type Player = typeof(setmetatable({} :: PlayerProps, Player))

function Player.new(x: number, y: number): Player
	return setmetatable({
		pos = Vec(x, y),
		base_radius = 25,
		radius = 25,
		speed = 400,
		dead = false,
		hue = 0,
		focus = 1,
		is_focusing = false,
		timer = Timer(),
		ring_timer = 0,
	}, Player) :: Player
end

function Player.update(self: Player, dt: number, keys: { [string]: boolean }, spawn_ring: (r: any) -> ())
	if self.dead then return end

	self.timer:update(dt)
	self.hue = (self.hue + dt * 100) % 360

	self.ring_timer += dt
	if self.ring_timer >= 0.5 then
		self.ring_timer = 0
		spawn_ring(Ring.new(self.pos:clone(), self.radius, 3, self.hue, 250))
	end

	local was_focusing = self.is_focusing
	self.is_focusing = keys.lshift or keys.rshift
	if self.is_focusing then
		self.focus = math.max(0, self.focus - dt * 0.5) -- Drains in 2s
		if self.focus <= 0 then self.is_focusing = false end
	else
		self.focus = math.min(1, self.focus + dt * 0.2) -- Recharges in 5s
	end

	if self.is_focusing ~= was_focusing then
		local target_radius = if self.is_focusing then 20 else self.base_radius
		self.timer:clear()
		self.timer:tween(0.2, self, { radius = target_radius }, "out-quad")
	end

	local move = Vec(0, 0)
	if keys.a then move.x = -1 end
	if keys.d then move.x = 1 end
	if keys.s then move.y = 1 end
	if keys.w then move.y = -1 end
	move:normalizeInplace()

	local current_speed = self.speed
	if self.is_focusing then
		current_speed = self.speed * 0.6 -- Moves at 60% speed normally, which is 3x faster than enemies in 0.2x time
	end

	self.pos += move * current_speed * dt

	-- Clamp to screen
	local w, h = WIDTH, HEIGHT
	self.pos.x = math.max(self.radius, math.min(w - self.radius, self.pos.x))
	self.pos.y = math.max(self.radius, math.min(h - self.radius, self.pos.y))
end

function Player.draw(self: Player)
	if self.dead then return end

	local rgb = HSLuv.hsluv_to_rgb({ self.hue, 100, 50 })
	love.graphics.setColor(rgb[1], rgb[2], rgb[3])
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)

	-- Focus bar
	local w, h = WIDTH, HEIGHT
	local bar_w, bar_h = 200, 10
	local bar_x, bar_y = (w - bar_w) / 2, h - 30
	love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
	love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
	love.graphics.setColor(1, 1, 1, 0.8)
	love.graphics.rectangle("fill", bar_x, bar_y, bar_w * self.focus, bar_h)
end

function Player.aabb(self: Player)
	return self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2
end

return Player
