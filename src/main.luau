local Gamestate = require "hump/gamestate"
local Play = require "gamestates/play"
local Timer = require "hump/timer"

function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(Play)
end

function love.update(dt: number)
	Timer.update(dt)
end

function love.draw() end
