local Camera = require "../hump/camera"
local Gamestate = require "../hump/gamestate"
local Timer = require "../hump/timer"
local Vec = require "../hump/vector"

local gs: Gamestate.GameState = {}

local ball_pos = Vec(50, 50)
local hello_pos = Vec(150, 150)
local cam = Camera(ball_pos.x, ball_pos.y)
local timer = Timer.new()
cam.smoother = Camera.smooth.damped(7)

local keys_tracked = {
	w = false,
	a = false,
	s = false,
	d = false,
}

function gs:goup()
	print "up"
	print(hello_pos)
	print("upt", timer:tween(0.3, hello_pos, { x = 100, y = 100 }, nil, gs.godown))
end

function gs:godown()
	print "down"
	print(hello_pos)
	print("downt",timer:tween(0.3, hello_pos, { x = 400, y = 200 }, nil, gs.goup))
end

function gs:enter()
	print("aftert ", timer:after(1, function() print "hey" end))
	gs:goup()
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
end

function gs:draw()
	cam:lockPosition(ball_pos.x, ball_pos.y)
	cam:attach()
	love.graphics.print("hello world", hello_pos.x, hello_pos.y)
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", ball_pos.x, ball_pos.y, 20)
	cam:detach()
end

function gs:keypressed(k)
	if keys_tracked[k] ~= nil then keys_tracked[k] = true end
end

function gs:keyreleased(k)
	if keys_tracked[k] ~= nil then keys_tracked[k] = false end
end

return gs
