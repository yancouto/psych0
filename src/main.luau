local Gamestate = require "libs/gamestate"
local Play = require "gamestates/play"
local Timer = require "libs/timer"

function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(Play)
end

function love.update(dt: number)
	Timer.update(dt)
end

function love.draw() end
