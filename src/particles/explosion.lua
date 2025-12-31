--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = {x=24, y=19}

local image1 = LG.newImage("lineGradient.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 33)
ps:setColors(0.8984375, 0.14739990234375, 0, 1, 0.64984130859375, 0.9140625, 0, 1, 0.84930419921875, 0, 0.8984375, 1)
ps:setDirection(0)
ps:setEmissionArea("ellipse", 45.387523651123, 45.387523651123, 0, true)
ps:setEmissionRate(24.881666183472)
ps:setEmitterLifetime(0)
ps:setInsertMode("random")
ps:setLinearAcceleration(0, -0.45932897925377, 0, -0.45932897925377)
ps:setLinearDamping(-0.024701692163944, 0.97194010019302)
ps:setOffset(50, 2)
ps:setParticleLifetime(0.5, 1)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(true)
ps:setRotation(0, 0)
ps:setSizes(0.23538814485073, 0.55240023136139)
ps:setSizeVariation(0.38019168376923)
ps:setSpeed(66.327102661133, 216.57872009277)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0.625)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=33, blendMode="add", shader=nil, texturePath="lineGradient.png", texturePreset="lineGradient", shaderPath="", shaderFilename="", x=0, y=0})

return particles
