local interpreter = require "interpreter/init"

local COLOR_RESET = "\27[0m"
local COLOR_GREEN = "\27[32m"
local COLOR_RED = "\27[31m"
local COLOR_YELLOW = "\27[33m"

local function runAllLevels()
	print(COLOR_YELLOW .. "Running all levels..." .. COLOR_RESET)

	local levels = love.filesystem.getDirectoryItems "levels"
	if not levels then error "Could not list levels directory" end

	for _, levelName in ipairs(levels) do
		if levelName == "__polyfill__.lua" or not levelName:match "%.lua$" then continue end

		local levelPath = "levels/" .. levelName
		print("Testing level: " .. levelPath)

		local content = love.filesystem.read("string", levelPath)
		if not content then error("Could not read level file: " .. levelPath) end

		local success, err = pcall(function() interpreter.runLevel(content) end)

		if not success then
			print(COLOR_RED .. "Level " .. levelPath .. " failed: " .. tostring(err) .. COLOR_RESET)
			error "Tests failed"
		end
		print(COLOR_GREEN .. "Level " .. levelPath .. " passed!" .. COLOR_RESET)
	end

	print(COLOR_GREEN .. "All levels passed!" .. COLOR_RESET)
end

return {
	runAllLevels = runAllLevels,
}
