local Bullet = require "../bullet"
local Camera = require "../libs/camera"
local Enemy = require "../enemy"
local Gamestate = require "../libs/gamestate"
local ObjectList = require "../object_list"
local Player = require "../player"
local Timer = require "../libs/timer"
local Vec = require "../libs/vector"

local gs: Gamestate.GameState = {}

local player = Player.new(400, 300)
local cam = Camera(400, 300)
local timer = Timer()

local bullets: ObjectList.ObjectList<Bullet.Bullet> = ObjectList.new()
local enemies: ObjectList.ObjectList<Enemy.Enemy> = ObjectList.new()

local keys_tracked: { [string]: boolean } = {
	w = false,
	a = false,
	s = false,
	d = false,
}

local function spawn_enemy()
	local w, h = love.graphics.getDimensions()
	local side = math.random(1, 4) -- 1: top, 2: bottom, 3: left, 4: right
	local pos = Vec(0, 0)
	if side == 1 then
		pos = Vec(math.random(0, w), -20)
	elseif side == 2 then
		pos = Vec(math.random(0, w), h + 20)
	elseif side == 3 then
		pos = Vec(-20, math.random(0, h))
	else
		pos = Vec(w + 20, math.random(0, h))
	end

	local vel = (player.pos - pos):normalized() * 100
	enemies:add(Enemy.new(pos, vel, 15))
end

function gs:enter()
	player = Player.new(400, 300)
	timer:clear()
	timer:every(2, spawn_enemy)
end

function gs:update(dt)
	timer:update(dt)
	player:update(dt, keys_tracked)

	bullets:update(dt)
	enemies:update(dt)

	-- Remove off-screen bullets
	local w, h = love.graphics.getDimensions()
	for _, b in ipairs(bullets.all) do
		if b.pos.x < -100 or b.pos.x > w + 100 or b.pos.y < -100 or b.pos.y > h + 100 then b.to_remove = true end
	end

	enemies:check_collision(bullets, function(e: Enemy.Enemy, b: Bullet.Bullet)
		local r = e.radius + b.radius
		return e.pos:dist2(b.pos) < r * r
	end, function(e: Enemy.Enemy, b: Bullet.Bullet)
		if not e.to_remove and not b.to_remove then
			e.to_remove = true
			b.to_remove = true
		end
	end)
end

function gs:draw()
	-- Camera is static now, but we still use it for potential screen shakes or zooming later
	cam:attach()

	player:draw()
	bullets:draw()
	enemies:draw()

	cam:detach()
end

function gs:mousepressed(x, y, button)
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
	if keys_tracked[k] ~= nil then keys_tracked[k] = true end
end

function gs:keyreleased(k)
	if keys_tracked[k] ~= nil then keys_tracked[k] = false end
end

return gs
