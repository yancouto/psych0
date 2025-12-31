local HSLuv = require "libs/hsluv"
local Vec = require "libs/vector"

local Explosion = {}

local shared_ps: ParticleSystem
local particle_image: Image

local function get_particle_image()
	-- Create a procedural circle image
	local size = 32
	local data = love.image.newImageData(size, size)
	local border = 5
	for x = 0, size - 1 do
		for y = 0, size - 1 do
			local dx = x - size / 2 + 0.5
			local dy = y - size / 2 + 0.5
			local dist = math.sqrt(dx * dx + dy * dy)
			local alpha
			if dist < size / 2 - border then
				alpha = 1
			else
				alpha = 1 - ((dist - size/2 + border) / border)
			end
			alpha = math.max(0, math.min(1, alpha))

			data:setPixel(x, y, 1, 1, 1, alpha)
		end
	end
	particle_image = love.graphics.newImage(data)
	return particle_image
end

function Explosion.init()
	local img = get_particle_image()
	-- Increase capacity to handle many simultaneous explosions
	shared_ps = love.graphics.newParticleSystem(img, 1000)

	-- Default parameters from src/particles/explosion.lua
	shared_ps:setDirection(0)
	shared_ps:setEmissionRate(0)
	shared_ps:setEmitterLifetime(-1) -- Infinite lifetime for the system itself
	shared_ps:setInsertMode("random")
	shared_ps:setLinearAcceleration(0, -0.459, 0, -0.459)
	shared_ps:setLinearDamping(-0.0247, 0.9719)
	shared_ps:setOffset(img:getWidth() / 2, img:getHeight() / 2)
	shared_ps:setParticleLifetime(0.5, 1)
	shared_ps:setRadialAcceleration(0, 0)
	shared_ps:setRelativeRotation(true)
	shared_ps:setRotation(0, 0)
	shared_ps:setSizeVariation(0.380)
	shared_ps:setSpin(0, 0)
	shared_ps:setSpinVariation(0)
	shared_ps:setSpread(0.625)
	shared_ps:setTangentialAcceleration(0, 0)
end

function Explosion.spawn(pos: Vec.Vector, radius: number, hue: number)
	local rgb = HSLuv.hsluv_to_rgb { hue, 100, 50 }
	shared_ps:setColors(rgb[1], rgb[2], rgb[3], 1, rgb[1], rgb[2], rgb[3], 0.5, rgb[1], rgb[2], rgb[3], 0)

	shared_ps:setEmissionArea("ellipse", 45.3875 * (radius / 25), 45.3875 * (radius / 25), 0, true)
	shared_ps:setSizes(0.135 * (radius / 25), 0.352 * (radius / 25))
	shared_ps:setSpeed(66.3 * (radius / 25), 216.5 * (radius / 25))

	shared_ps:setPosition(pos.x, pos.y)
	shared_ps:emit(33)
end

function Explosion.update(dt: number)
	shared_ps:update(dt)
end

function Explosion.draw()
	love.graphics.draw(shared_ps, 0, 0)
end

return Explosion