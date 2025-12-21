local Gamestate = require "hump/gamestate"
local Play = require "gamestates/play"

function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(Play)
end

function love.update(dt: number) end

function love.draw() end
