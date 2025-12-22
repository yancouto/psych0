local Camera = require "../hump/camera"
local Gamestate = require "../hump/gamestate"
local Timer = require "../hump/timer"
local Vec = require "../hump/vector"

local gs: Gamestate.GameState = {}

local ball_pos = Vec(400, 300)
local cam = Camera(ball_pos.x, ball_pos.y)
local timer = Timer()
cam.smoother = Camera.smooth.damped(7)

local bullets = {}
local enemies = {}

local keys_tracked = {
	w = false,
	a = false,
	s = false,
	d = false,
}

local function spawn_enemy()
	local angle = math.random() * math.pi * 2
	local distance = 500 -- distance from player
	local pos = ball_pos + Vec(math.cos(angle), math.sin(angle)) * distance
	local vel = Vec(math.random() - 0.5, math.random() - 0.5):normalized() * 100
	table.insert(enemies, { pos = pos, vel = vel, radius = 15 })
end

function gs:enter()
	bullets = {}
	enemies = {}
	timer:clear()
	timer:every(2, spawn_enemy)
end

function gs:update(dt)
	timer:update(dt)
	local speed = Vec(0, 0)
	if keys_tracked.a then speed.x = -1 end
	if keys_tracked.d then speed.x = 1 end
	if keys_tracked.s then speed.y = 1 end
	if keys_tracked.w then speed.y = -1 end
	speed:normalizeInplace()

	ball_pos += speed * 400 * dt

	-- Update bullets
	for i = #bullets, 1, -1 do
		local b = bullets[i]
		b.pos += b.vel * dt
		-- Remove off-screen bullets (rough estimation)
		if (b.pos - ball_pos):len() > 1000 then
			table.remove(bullets, i)
		end
	end

	-- Update enemies
	for i = #enemies, 1, -1 do
		local e = enemies[i]
		e.pos += e.vel * dt

		-- Remove far away enemies
		if (e.pos - ball_pos):len() > 1500 then
			table.remove(enemies, i)
			continue
		end

		-- Collision with bullets
		for j = #bullets, 1, -1 do
			local b = bullets[j]
			if (e.pos - b.pos):len() < e.radius + 5 then
				table.remove(enemies, i)
				table.remove(bullets, j)
				break
			end
		end
	end
end

function gs:draw()
	cam:lockPosition(ball_pos.x, ball_pos.y)
	cam:attach()

	-- Draw player
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("fill", ball_pos.x, ball_pos.y, 20)

	-- Draw bullets
	love.graphics.setColor(1, 1, 0)
	for _, b in bullets do
		love.graphics.circle("fill", b.pos.x, b.pos.y, 5)
	end

	-- Draw enemies
	love.graphics.setColor(1, 0, 0)
	for _, e in enemies do
		love.graphics.circle("fill", e.pos.x, e.pos.y, e.radius)
	end

	cam:detach()
end

function gs:mousepressed(x, y, button)
	if button == 1 then
		local mx, my = cam:worldCoords(x, y)
		local target = Vec(mx, my)
		local dir = (target - ball_pos):normalized()
		-- Shoot 3 tiny balls in a small spread
		for i = -1, 1 do
			local angle = i * 0.1
			local bdir = dir:rotated(angle)
			table.insert(bullets, { pos = ball_pos:clone(), vel = bdir * 600 })
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
