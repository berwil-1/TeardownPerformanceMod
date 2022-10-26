fire = {}
fires = {}

local fireLimit, fireSpread
fire.init = function()
	fire.name = "fire"
	fireLimit = GetInt("game.fire.maxcount")
	fireSpread = GetInt("game.fire.spread")
end

fire.disable = function()
	SetInt("game.fire.maxcount", fireLimit)
	SetFloat("game.fire.spread", fireSpread)
end

local tile = 0
fire.tick = function(ticks)
	if options.general.speedrun then
		SetInt("game.fire.maxcount", fireLimit)
		SetFloat("game.fire.spread", fireSpread)
		return
	end

	if options.general.debug then
		DebugWatch("Fires", GetFireCount())
	end

	if fire.options.performance then
		if ticks % 10 == 0 then
			for index = 1, #fires do
				spawnFire(index)
				--spawnSmoke(index)
			end
		end

		if ticks % 60 == 0 then
			firesToLocations()
		end
	end

	if ticks % 60 == 0 then
		SetInt("game.fire.maxcount", fire.options.fireLimit)
		SetInt("game.fire.spread", fire.options.fireSpread)
	end
end

fire.draw = function()
	
end

local sanity = false
local fireLimitHeld, fireSpreadHeld
fire.interface = function()
	UiTranslate(30, 30)

	UiPush()
		-- General
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch("FIRE", 400, 60, fire.options.enabled) then
			if fire.options.enabled then fire.disable() end
			fire.options.enabled = not fire.options.enabled
		end
		UiTranslate(0, 60)

		if interface.buttonText({ text = "RESET", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
			for name,value in pairs(fire.default) do
				fire.options[name] = Clone(value)
			end
		end
		UiTranslate(0, 90)

		-- Fire
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "FIRE", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)
		if interface.buttonSwitch("PERFORMANCE", 400, 60, fire.options.performance) then
			fire.options.performance = not fire.options.performance
		end
		UiTranslate(0, 60)
		fire.options.fireLimit, fireLimitHeld = interface.slider("LIMIT", Round(fire.options.fireLimit, -1, 0.5), 400, 60, 0, 2000, theme.button, theme.background, nil, nil, fireLimitHeld)
		UiTranslate(0, 60)
		fire.options.fireSpread, fireSpreadHeld = interface.slider("SPREAD", Round(fire.options.fireSpread, 0, 0.5), 400, 60, 0, 100, theme.button, theme.background, nil, nil, fireSpreadHeld)
	UiPop()
end

function spawnFire(index)
	if options.general.debug then
		DebugCross(fires[index], 1, 1, 1, 1)
	end

	ParticleReset()
	ParticleTile(5)
	ParticleColor(1, 0.7, 0.5, 1, 0.1, 0)

	ParticleAlpha(0.2)
	ParticleGravity(3)
	ParticleRadius(0.1, 0.3)
	ParticleEmissive(15, 0)
	--ParticleRotation(1, 0)
	ParticleCollide(0, 1)

	-- GetShapeMaterialAtPosition(shape, worldpos)
	if math.random() < 0.9 then SpawnParticle(fires[index], Vec(0, 0, 0), 1) end
	if math.random() < 0.1 then MakeHole(fires[index], 0.2, 0.2, 0.2, true) end

	local hit = QueryRaycast(fires[index], Vec(0, -1, 0), 0.2)
	local nextLocation = VecAdd(fires[index], RandomVec(0.5))
	local nextHit = QueryRaycast(nextLocation, Vec(0, 1, 0), 1)
	if nextHit and math.random() < 0.009 then fires[#fires + 1] = nextLocation end
	if (not hit) or math.random() < 0.01 then table.remove(fires, index) end
end

function spawnSmoke(index)
	ParticleReset()
	ParticleType("smoke")
	ParticleColor(0, 0, 0)

	ParticleAlpha(0, 1)
	ParticleGravity(3, -1)
	ParticleRadius(0.1, 1)
	ParticleRotation(1, 0)
	SpawnParticle(fires[index], Vec(0, 0, 0), 8)
end

function firesToLocations()
	local count = GetFireCount()

	for index = 1, count do
		local hit, pos = QueryClosestFire(Vec(0, 0, 0), math.huge)
		RemoveAabbFires(pos, pos)
		fires[#fires + 1] = pos
	end
end