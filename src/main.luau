local Gamestate = require "libs/gamestate"
local Play = require "gamestates/play"
local Tests = require "tests"
local Timer = require "libs/timer"

-- Used fixed width and height for calculating play screen stuff.
_G.WIDTH, _G.HEIGHT = 1280, 1024

function love.load(arg)
	for _, v in ipairs(arg) do
		if v == "--test" then
			love.window.close()
			local ok = Tests.runAllLevels()
			love.event.quit(if not ok then 1 else 0)
			return
		end
	end

	Gamestate.registerEvents()
	Gamestate.switch(Play)
end

function love.update(dt: number) Timer.update(dt) end

function love.draw() end
