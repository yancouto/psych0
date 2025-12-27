local Gamestate = require "libs/gamestate"
local Play = require "gamestates/play"
local Tests = require "tests"
local Timer = require "libs/timer"

function love.load(arg)
	for _, v in ipairs(arg) do
		if v == "--test" then
			love.window.close()
			Tests.runAllLevels()
			love.event.quit()
			return
		end
	end

	Gamestate.registerEvents()
	Gamestate.switch(Play)
end

function love.update(dt: number) Timer.update(dt) end

function love.draw() end
