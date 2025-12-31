local Background = require "../background"
local Bullet = require "../bullet"
local Camera = require "../libs/camera"
local Enemy = require "../enemy"
local Explosion = require "../explosion"
local Gamestate = require "../libs/gamestate"
local Indicator = require "../indicator"
local Interpreter = require "../interpreter/init"
local ObjectList = require "../object_list"
local Player = require "../player"
local Timer = require "../libs/timer"
local Vec = require "../libs/vector"

local gs: Gamestate.GameState = {}

local player = Player.new(0, 0)
local cam = Camera(0, 0)
local timer = Timer()
local background = Background.new()

local bullets: ObjectList.ObjectList<Bullet.Bullet> = ObjectList.new()
local enemies: ObjectList.ObjectList<Enemy.Enemy> = ObjectList.new()
local indicators: ObjectList.ObjectList<Indicator.Indicator> = ObjectList.new()
local explosions: ObjectList.ObjectList<Explosion.Explosion> = ObjectList.new()

local level_instance: Interpreter.LevelInstance? = nil

local paused = false

local keys_tracked: { [string]: boolean } = {
	w = false,
	a = false,
	s = false,
	d = false,
	lshift = false,
	rshift = false,
}

local function spawn_enemy(params: any)
	local pos = Vec(params.pos[1], params.pos[2])
	local vel = Vec(params.vel[1], params.vel[2]) * 50
	local duration = params.indicatorDuration or 0
	if duration > 0 then
		timer:after(duration, function() enemies:add(Enemy.new(pos, vel, params.radius)) end)
	else
		enemies:add(Enemy.new(pos, vel, params.radius))
	end
end

local function spawn_indicator(params: any)
	local pos = Vec(params.pos[1], params.pos[2])
	local vel = Vec(params.vel[1], params.vel[2])
	local duration = params.duration
	indicators:add(Indicator.new(pos, vel, duration, params.radius))
end

function gs:enter()
	local w, h = love.graphics.getDimensions()
	player = Player.new(w / 2, h / 2)
	cam:lookAt(w / 2, h / 2)
	timer:clear()
	bullets = ObjectList.new()
	enemies = ObjectList.new()
	indicators = ObjectList.new()
	explosions = ObjectList.new()
	background = Background.new()

	local levelCode = love.filesystem.read("string", "levels/level1.lua")

	if levelCode then
		level_instance = Interpreter.runLevel(levelCode, {
			spawnCallback = spawn_enemy,
			spawnIndicatorCallback = spawn_indicator,
			getEnemyCount = function() return #enemies.all + #indicators.all end,
		})
	end
end

function gs:update(dt)
	if paused then return end

	local time_scale = 1
	if player.is_focusing then time_scale = 0.2 end

	local scaled_dt = dt * time_scale

	background:update(scaled_dt)
	timer:update(scaled_dt)
	player:update(dt, keys_tracked)

	if not player.dead then
		if level_instance then level_instance:update(scaled_dt) end

		bullets:update(scaled_dt)
		enemies:update(scaled_dt)
		indicators:update(scaled_dt)
		explosions:update(scaled_dt)

		local w, h = love.graphics.getDimensions()
		bullets:remove_offscreen(w, h)
		enemies:remove_offscreen(w, h)

		enemies:check_collision(bullets, function(e: Enemy.Enemy, b: Bullet.Bullet)
			local r = e.radius + b.radius
			return e.pos:dist2(b.pos) < r * r
		end, function(e: Enemy.Enemy, b: Bullet.Bullet)
			if not e.to_remove and not b.to_remove then
				e.to_remove = true
				b.to_remove = true
				explosions:add(Explosion.new(e.pos:clone(), e.radius, e.hue))
			end
		end)

		-- Collision with player
		for _, e in ipairs(enemies.all) do
			local r = e.radius + player.radius
			if e.pos:dist2(player.pos) < r * r then
				player.dead = true
				break
			end
		end
	end
end

function gs:draw()
	background:draw()

	-- Camera is static now, but we still use it for potential screen shakes or zooming later
	cam:attach()

	player:draw()
	bullets:draw()
	enemies:draw()
	indicators:draw()
	explosions:draw()

	cam:detach()

	if paused then
		local w, h = love.graphics.getDimensions()
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("PAUSED", 0, h / 2 - 10, w, "center")
	end

	if player.dead then
		local w, h = love.graphics.getDimensions()
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("GAME OVER\nPress 'R' to Restart", 0, h / 2 - 20, w, "center")
	end
end

function gs:mousepressed(x, y, button)
	if player.dead then return end
	if button == 1 then
		local mx, my = cam:worldCoords(x, y)
		local target = Vec(mx, my)
		local dir = (target - player.pos):normalizeInplace()
		-- Shoot 3 tiny balls in a small spread
		for i = -1, 1 do
			local angle = i * 0.1
			local bdir = dir:rotated(angle)
			bullets:add(Bullet.new(player.pos:clone(), bdir * 600))
		end
	end
end

function gs:keypressed(k)
	if k == "escape" then
		paused = not paused
	end

	if paused then return end

	if keys_tracked[k] ~= nil then keys_tracked[k] = true end
	if k == "r" and player.dead then
		self:enter()
	end
end

function gs:keyreleased(k)
	if k == "escape" then return end
	if keys_tracked[k] ~= nil then keys_tracked[k] = false end
end

return gs
