--!strict
local sandbox = require "libs/sandbox"

export type Vec2 = { number }

type SpawnParams = {
	enemyType: string,
	pos: Vec2,
	vel: Vec2,
	radius: number,
}

type IndicatorParams = {
	pos: Vec2,
	vel: Vec2,
	duration: number,
	radius: number,
}

export type LevelInstanceData = {
	coro: any,
	waitTimer: number,
	waitingForNoEnemies: boolean,
	isFinished: boolean,
	defaultIndicatorDuration: number,
	spawnCallback: (SpawnParams) -> (),
	spawnIndicatorCallback: (IndicatorParams) -> (),
	getEnemyCount: () -> number,
}

export type LevelInstance = typeof(setmetatable({} :: LevelInstanceData, {} :: { __index: LevelInstanceData })) & {
	update: (self: LevelInstance, dt: number) -> boolean,
}

local LevelInstanceImpl = {}
LevelInstanceImpl.__index = LevelInstanceImpl

function LevelInstanceImpl:update(dt: number): boolean
	if self.isFinished then return true end

	if self.waitTimer > 0 then
		self.waitTimer -= dt
		if self.waitTimer > 0 then return false end
	end

	if self.waitingForNoEnemies then
		if self.getEnemyCount() > 0 then return false end
		self.waitingForNoEnemies = false
	end

	local success, result = coroutine.resume(self.coro)
	print("doing something", result)
	if not success then error("Error in level script: " .. tostring(result)) end

	if coroutine.status(self.coro) == "dead" then
		self.isFinished = true
		return true
	end

	if result then
		if result.type == "wait" then
			print("Waiting ", result.duration)
			self.waitTimer = result.duration
		elseif result.type == "wait_no_enemies" then
			print "Waiting for no enemies"
			self.waitingForNoEnemies = true
		end
	end

	return false
end

local function get_enemy_type(enemies: string | { string }, index: number): string
	if type(enemies) == "string" then
		return enemies
	elseif type(enemies) == "table" then
		return enemies[((index - 1) % #enemies) + 1]
	end
	return "Simple"
end

local function clamp_to_screen(pos: Vec2, radius: number): Vec2
	local w, h = love.graphics.getDimensions()
	return {
		math.max(radius, math.min(w - radius, pos[1])),
		math.max(radius, math.min(h - radius, pos[2])),
	}
end

local function handle_spawn(
	self: any,
	enemyType: string,
	pos: Vec2,
	vel: Vec2,
	radius: number,
	indicatorDuration: number
)
	if indicatorDuration > 0 then
		local indicatorPos = clamp_to_screen(pos, radius)
		self.spawnIndicatorCallback {
			pos = indicatorPos,
			vel = vel,
			duration = indicatorDuration,
			radius = radius,
		}
	end

	self.spawnCallback {
		enemyType = enemyType,
		pos = pos,
		vel = vel,
		radius = radius,
		indicatorDuration = indicatorDuration,
	}
end

local SpawnerImpl = {}

function SpawnerImpl:Single(params: { enemy: string, pos: Vec2, speed: Vec2, radius: number? })
	handle_spawn(
		self,
		params.enemy,
		params.pos,
		params.speed,
		params.radius or 20,
		self.indicatorDuration
	)
end

function SpawnerImpl:Multiple(params: {
	enemies: { string } | string,
	amount: number,
	spacing: number?,
	pos: Vec2,
	speed: Vec2,
	radius: number?,
})
	local amount = params.amount
	local spacing = params.spacing or 5
	local radius = params.radius or 20

	local vel = { params.speed[1], params.speed[2] }
	local velLen = math.sqrt(vel[1] ^ 2 + vel[2] ^ 2)
	local dir = { 0, 0 }
	if velLen > 0 then dir = { vel[1] / velLen, vel[2] / velLen } end

	for i = 1, amount do
		local offset = (i - 1) * spacing
		handle_spawn(
			self,
			get_enemy_type(params.enemies, i),
			{ params.pos[1] - dir[1] * offset, params.pos[2] - dir[2] * offset },
			{ vel[1], vel[2] },
			radius,
			self.indicatorDuration
		)
	end
end

function SpawnerImpl:VerticalLine(params: {
	enemies: { string } | string,
	amount: number,
	speed: number?,
	radius: number?,
	side: string,
	placement: any,
})
	local w, h = love.graphics.getDimensions()
	local amount = params.amount
	local speed = params.speed or 15
	local radius = params.radius or 20
	local side = params.side
	local placement = params.placement

	local x = (side == "Left") and -radius or w + radius
	local velX = (side == "Left") and speed or -speed

	local yPositions = {}
	local margin = placement.margin or 20

	if placement.type == "Distribute" then
		local availableH = h - 2 * margin
		if amount > 1 then
			for i = 1, amount do
				table.insert(yPositions, margin + (i - 1) * (availableH / (amount - 1)))
			end
		else
			table.insert(yPositions, h / 2)
		end
	elseif placement.type == "FromTop" then
		for i = 1, amount do
			table.insert(yPositions, margin + (i - 1) * placement.spacing)
		end
	elseif placement.type == "FromBottom" then
		for i = 1, amount do
			table.insert(yPositions, h - margin - (i - 1) * placement.spacing)
		end
	elseif placement.type == "V" then
		local centerY = h / 2
		for i = 1, amount do
			local offset = math.floor(i / 2) * placement.spacing
			if i % 2 == 0 then
				table.insert(yPositions, centerY + offset)
			else
				table.insert(yPositions, centerY - offset)
			end
		end
		table.sort(yPositions)
	end

	for i, y in ipairs(yPositions) do
		handle_spawn(
			self,
			get_enemy_type(params.enemies, i),
			{ x, y },
			{ velX, 0 },
			radius,
			self.indicatorDuration
		)
	end
end

function SpawnerImpl:HorizontalLine(params: {
	enemies: { string } | string,
	amount: number,
	speed: number?,
	radius: number?,
	side: string,
	placement: any,
})
	local w, h = love.graphics.getDimensions()
	local amount = params.amount
	local speed = params.speed or 15
	local radius = params.radius or 20
	local side = params.side
	local placement = params.placement

	local y = (side == "Top") and -radius or h + radius
	local velY = (side == "Top") and speed or -speed

	local xPositions = {}
	local margin = placement.margin or 20

	if placement.type == "Distribute" then
		local availableW = w - 2 * margin
		if amount > 1 then
			for i = 1, amount do
				table.insert(xPositions, margin + (i - 1) * (availableW / (amount - 1)))
			end
		else
			table.insert(xPositions, w / 2)
		end
	elseif placement.type == "FromLeft" then
		for i = 1, amount do
			table.insert(xPositions, margin + (i - 1) * placement.spacing)
		end
	elseif placement.type == "FromRight" then
		for i = 1, amount do
			table.insert(xPositions, w - margin - (i - 1) * placement.spacing)
		end
	elseif placement.type == "V" then
		local centerX = w / 2
		for i = 1, amount do
			local offset = math.floor(i / 2) * placement.spacing
			if i % 2 == 0 then
				table.insert(xPositions, centerX + offset)
			else
				table.insert(xPositions, centerX - offset)
			end
		end
		table.sort(xPositions)
	end

	for i, x in ipairs(xPositions) do
		handle_spawn(
			self,
			get_enemy_type(params.enemies, i),
			{ x, y },
			{ 0, velY },
			radius,
			self.indicatorDuration
		)
	end
end

function SpawnerImpl:Circle(params: {
	enemies: { string } | string,
	amount: number,
	speed: number?,
	enemy_radius: number?,
	starting_angle: number?,
	formation_radius: number?,
	formation_center: Vec2?,
})
	local w, h = love.graphics.getDimensions()
	local amount = params.amount
	local speed = params.speed or 15
	local enemy_radius = params.enemy_radius or 20
	local starting_angle = params.starting_angle or 0
	local formation_center = params.formation_center or { w / 2, h / 2 }
	local formation_radius = params.formation_radius or (math.sqrt(w * w + h * h) / 2 + enemy_radius)

	for i = 1, amount do
		local angle = starting_angle + (i - 1) * (2 * math.pi / amount)
		local pos = {
			formation_center[1] + math.cos(angle) * formation_radius,
			formation_center[2] + math.sin(angle) * formation_radius,
		}
		local vel = { -math.cos(angle) * speed, -math.sin(angle) * speed }
		handle_spawn(
			self,
			get_enemy_type(params.enemies, i),
			pos,
			vel,
			enemy_radius,
			self.indicatorDuration
		)
	end
end

function SpawnerImpl:Spiral(params: {
	enemies: { string } | string,
	amount_in_circle: number,
	amount: number,
	spacing: number,
	enemy_radius: number?,
	speed: number?,
})
	local w, h = love.graphics.getDimensions()
	local amount = params.amount
	local amount_in_circle = params.amount_in_circle
	local spacing = params.spacing
	local enemy_radius = params.enemy_radius or 20
	local speed = params.speed or 10
	local centerX, centerY = w / 2, h / 2

	for i = 1, amount do
		local angle = (i - 1) * (2 * math.pi / amount_in_circle)
		local r = (i - 1) * spacing
		local pos = { centerX + math.cos(angle) * r, centerY + math.sin(angle) * r }
		local vel = { math.cos(angle) * speed, math.sin(angle) * speed }
		handle_spawn(
			self,
			get_enemy_type(params.enemies, i),
			pos,
			vel,
			enemy_radius,
			self.indicatorDuration
		)
	end
end

local SpawnerMetatable = {
	__index = function(self, key): any
		local impl = SpawnerImpl[key]
		if impl then
			return function(params) return impl(self, params) end
		end
		return nil
	end,
}

local function createSpawner(
	spawnCallback: (SpawnParams) -> (),
	spawnIndicatorCallback: (IndicatorParams) -> (),
	indicatorDuration: number,
	customParams: any?
)
	return setmetatable({
		spawnCallback = spawnCallback,
		spawnIndicatorCallback = spawnIndicatorCallback,
		indicatorDuration = indicatorDuration,
		customParams = customParams,
	}, SpawnerMetatable)
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

local function runLevel(
	levelCode: string,
	options: {
		spawnCallback: (SpawnParams) -> (),
		spawnIndicatorCallback: (IndicatorParams) -> (),
		getEnemyCount: () -> number,
	}
): LevelInstance
	local instance: LevelInstanceData = {
		coro = nil,
		waitTimer = 0,
		waitingForNoEnemies = false,
		isFinished = false,
		defaultIndicatorDuration = 1,
		spawnCallback = options.spawnCallback,
		spawnIndicatorCallback = options.spawnIndicatorCallback,
		getEnemyCount = options.getEnemyCount,
	}

	local API_impl = {
		Wait = function(seconds: number) coroutine.yield { type = "wait", duration = seconds } end,
		WaitUntilNoEnemies = function() coroutine.yield { type = "wait_no_enemies" } end,
		Spawn = (setmetatable({
			spawnCallback = options.spawnCallback,
			spawnIndicatorCallback = options.spawnIndicatorCallback,
			indicatorDuration = 1, -- Initial value
		}, {
			__index = function(t, k)
				(t :: any).indicatorDuration = instance.defaultIndicatorDuration
				return SpawnerMetatable.__index(t, k)
			end,
		}) :: any),
		CustomSpawn = function(params)
			local duration = params.indicator_duration or instance.defaultIndicatorDuration
			return createSpawner(options.spawnCallback, options.spawnIndicatorCallback, duration, params)
		end,
		SetDefaultIndicatorDuration = function(duration: number) instance.defaultIndicatorDuration = duration end,
	}

	local w, h = love.graphics.getDimensions()
	local run = sandbox.protect(levelCode, {
		env = {
			API = API_impl,
			Vec2 = Vec2_impl,
			Enemy = Enemy_impl,
			Side = Side_impl,
			Placement = Placement_impl,
			WIDTH = w,
			HEIGHT = h,
		},
	})

	instance.coro = coroutine.create(run)

	return setmetatable(instance, LevelInstanceImpl) :: any
end

return {
	runLevel = runLevel,
}
