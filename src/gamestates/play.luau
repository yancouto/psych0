local Gamestate = require("../hump/gamestate")

local gs: Gamestate.GameState = {}

function gs:draw()
	love.graphics.print("hello world", 200, 200)
	love.graphics.rectangle("fill", 100, 100, 50, 75)
end

return gs