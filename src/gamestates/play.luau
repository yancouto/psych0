local Gamestate = require "../hump/gamestate"
local Vec = require "../hump/vector"

local gs: Gamestate.GameState = {}

local ball_pos = Vec(50, 50)

local keys_tracked = {
	w = false,
	a = false,
	s = false,
	d = false,
}

function gs:update(dt)
	local speed = Vec(0, 0)
	if keys_tracked.a then speed.x = -1 end
	if keys_tracked.d then speed.x = 1 end
	if keys_tracked.s then speed.y = 1 end
	if keys_tracked.w then speed.y = -1 end
	speed:normalizeInplace()

	ball_pos += speed * 400 * dt
end

function gs:draw()
	love.graphics.print("hello world", 200, 200)
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", ball_pos.x, ball_pos.y, 20)
end

function gs:keypressed(k)
	if keys_tracked[k] ~= nil then keys_tracked[k] = true end
end

function gs:keyreleased(k)
	if keys_tracked[k] ~= nil then keys_tracked[k] = false end
end

return gs
