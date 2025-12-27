--!strict
-- The interpreter implementation.

local sandbox = require "libs/sandbox"

local string_rep = string.rep

local function printTable(t: any, indent: number?): string
	local actualIndent = indent or 0
	local s = "{\n"
	for k, v in pairs(t) do
		s = s .. string_rep("  ", actualIndent + 1) .. tostring(k) .. " = "
		if type(v) == "table" then
			s = s .. tostring(printTable(v, actualIndent + 1)) .. ",\n"
		else
			s = s .. tostring(v) .. ",\n"
		end
	end
	s = s .. string_rep("  ", actualIndent) .. "}"
	return s
end

local function createSpawner(prefix: string?): any
	local actualPrefix = prefix or ""
	return {
		Single = function(params) print(actualPrefix .. "Spawn.Single: " .. printTable(params, 0)) end,
		Multiple = function(params) print(actualPrefix .. "Spawn.Multiple: " .. printTable(params, 0)) end,
		VerticalLine = function(params) print(actualPrefix .. "Spawn.VerticalLine: " .. printTable(params, 0)) end,
		HorizontalLine = function(params) print(actualPrefix .. "Spawn.HorizontalLine: " .. printTable(params, 0)) end,
		Circle = function(params) print(actualPrefix .. "Spawn.Circle: " .. printTable(params, 0)) end,
		Spiral = function(params) print(actualPrefix .. "Spawn.Spiral: " .. printTable(params, 0)) end,
	}
end

local Vec2_impl = function(x, y) return { x, y } end

local Enemy_impl = {
	Simple = "Simple",
	Double = "Double",
}

local Side_impl = {
	Left = "Left",
	Right = "Right",
	Top = "Top",
	Bottom = "Bottom",
}

local Placement_impl = {
	Distribute = function(params) return { type = "Distribute", margin = params.margin } end,
	FromBottom = function(params) return { type = "FromBottom", margin = params.margin, spacing = params.spacing } end,
	FromTop = function(params) return { type = "FromTop", margin = params.margin, spacing = params.spacing } end,
	FromLeft = function(params) return { type = "FromLeft", margin = params.margin, spacing = params.spacing } end,
	FromRight = function(params) return { type = "FromRight", margin = params.margin, spacing = params.spacing } end,
	V = function(params) return { type = "V", margin = params.margin, spacing = params.spacing } end,
}

local API_impl = {
	Wait = function(seconds: number) print("Wait: " .. tostring(seconds) .. "s") end,
	WaitUntilNoEnemies = function() print "WaitUntilNoEnemies" end,
	Spawn = createSpawner(),
	CustomSpawn = function(params)
		local prefix = "Custom[" .. printTable(params, 0) .. "] "
		return createSpawner(prefix)
	end,
	SetDefaultIndicatorDuration = function(duration: number)
		print("SetDefaultIndicatorDuration: " .. tostring(duration))
	end,
}

local function runLevel(levelCode: string)
	local run = sandbox.protect(levelCode, {
		env = {
			API = API_impl,
			Vec2 = Vec2_impl,
			Enemy = Enemy_impl,
			Side = Side_impl,
			Placement = Placement_impl,
		},
	})

	local success, runErr = pcall(run)
	if not success then error("Error running level: " .. tostring(runErr)) end
end

return {
	runLevel = runLevel,
}
