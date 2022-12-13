#include "../utility/general.lua"
#include "../utility/math.lua"
debris = {}

debris.init = function()
	debris.name = "debris"
end

local stabilized = {}
local forbiddenArea = FindTrigger("perfmod-disable-debris", true)
local forbidden = IndexElements(Concat(Concat(FindBodies("target", true), FindBodies("alarmbox", true)), FindBodies("escapevehicle", true)))
debris.shape = function(shape)
	local smart = options.debris.smart

	-- If above 60~ FPS return since no further action is needed.
	if smart and GetTimeStep() < 0.017 then return end

	local body = GetShapeBody(shape)
	if options.general.speedrun or forbidden[body] == body or GetWorldBody() == body or IsShapeInTrigger(forbiddenArea, shape) then return end

	local count = GetShapeVoxelCount(shape)
	local broken = IsShapeBroken(shape)

	if debris.options.collider then
		if broken and count < options.debris.colliderVoxelCount then
			if options.general.debug then
				DrawShapeOutline(shape, 1, 0, 0, 1)
			end

			SetShapeCollisionFilter(shape, 2, debris.options.collideLevel and 253 or 254)
		end
	end

	-- If above 50 FPS return since no further action is needed.
	if smart and GetTimeStep() < 0.02 then return end

	if debris.options.cleaner then
		if broken and count < debris.options.cleanerVoxelCount then
			if debris.options.particle then
				local sizex, sizey, sizez = GetShapeSize(shape)
				for x = 0, sizex * 1 / (11 - debris.options.particleAmount), 1 do
					for y = 0, sizey, 1 do
						for z = 0, sizez, 1 do
							local name, red, green, blue, alpha = GetShapeMaterialAtIndex(shape, x, y, z)
							
							if alpha > 0 then
								local position = VecAdd(GetShapeWorldTransform(shape).pos, TransformToParentVec(GetShapeWorldTransform(shape), Vec(x * .1, y * .1, z * .1)))
								local velocity = RandomVec(1)
								local radius = Random(0.03, 0.05)

								ParticleReset()
								ParticleColor(red, green, blue)

								ParticleAlpha(1)
								ParticleGravity(-10)
								ParticleRadius(radius, radius, "constant", 0, 0.2)
								ParticleSticky(0.2)
								ParticleStretch(0.0)
								ParticleTile(6)
								ParticleRotation(Random(-20, 20), 0.0, "easeout")
								SpawnParticle(position, velocity, 8)
							end
						end
					end
				end
			end

			if options.general.debug then
				DrawShapeOutline(shape, 1, 0, 0, 1)
			else
				Delete(shape)
			end
		end
	end

	-- If above 40 FPS return since no further action is needed.
	if smart and GetTimeStep() < 0.025 then return end

	if debris.options.stabilizer then
		if count < options.debris.stabilizerVoxelCount then
			if stabilized[body] and VecLength(VecSub(GetPlayerTransform().pos, GetShapeWorldTransform(shape).pos)) < debris.options.stabilizerRadius then
				if options.general.debug then
					DrawBodyOutline(body, 0, 1, 0, 1)
				end

				SetBodyDynamic(body, true)
				SetBodyVelocity(body, Vec(0, 0, 0))
				stabilized[body] = nil
			end

			if IsBodyActive(body) and VecLength(VecSub(GetPlayerTransform().pos, GetShapeWorldTransform(shape).pos)) > debris.options.stabilizerRadius and 0 < VecLength(GetBodyVelocity(body)) and VecLength(GetBodyVelocity(body)) < debris.options.stabilizerForce then
				if options.general.debug then
					DrawBodyOutline(body, 1, 0, 0, 1)
				end

				if IsBodyDynamic(body) then stabilized[body] = true	end
				SetBodyVelocity(body, Vec(0, 0, 0))
				SetBodyAngularVelocity(body, Vec(0, 0, 0))
				SetBodyDynamic(body, false)
			end
		end
	end
end

local cleanerVoxelCountHeld, particleAmountHeld, stabilizerVoxelCountHeld, stabilizerRadiusHeld, stabilizerForceHeld, colliderVoxelCountHeld
debris.interface = function()
	UiTranslate(30, 30)

	UiPush()
		UiPush()
			-- General
			interface.color(theme.background)
			UiRect(400, 40)
			
			interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, theme.text)
			UiTranslate(0, 40)

			if interface.buttonSwitch("DEBRIS", 400, 60, debris.options.enabled) then
				debris.options.enabled = not debris.options.enabled
			end
			UiTranslate(0, 60)

			if interface.buttonSwitch("SMART", 400, 60, options.debris.smart) then
				options.debris.smart = not options.debris.smart
			end
			UiTranslate(0, 60)

			if interface.buttonText({ text = "RESET", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
				for name,value in pairs(debris.default) do
					debris.options[name] = Clone(value)
				end
			end
			UiTranslate(0, 90)

			-- Cleaner
			interface.color(theme.background)
			UiRect(400, 40)
			
			interface.text({ text = "CLEANER", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, theme.text)
			UiTranslate(0, 40)
			
			if interface.buttonSwitch("CLEANER", 400, 60, debris.options.cleaner) then
				debris.options.cleaner = not debris.options.cleaner
			end
			UiTranslate(0, 60)
			
			if interface.buttonSwitch("PARTICLE", 400, 60, debris.options.particle) then
				debris.options.particle = not debris.options.particle
			end
			UiTranslate(0, 60)
			
			debris.options.cleanerVoxelCount, cleanerVoxelCountHeld = interface.slider("VOXEL COUNT", Round(debris.options.cleanerVoxelCount, -1, 0.5), 400, 60, 0, 1000, theme.button, theme.background, nil, nil, cleanerVoxelCountHeld)
			UiTranslate(0, 60)
			
			debris.options.particleAmount, particleAmountHeld = interface.slider("PARTICLE AMOUNT", Round(debris.options.particleAmount, 0, 0.5), 400, 60, 0, 10, theme.button, theme.background, nil, nil, particleAmountHeld)
			UiTranslate(0, 90)
		UiPop()
		UiTranslate(430, 0)

		UiPush()
			-- Stabilizer
			interface.color(theme.background)
			UiRect(400, 40)
			
			interface.text({ text = "STABILIZER", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, theme.text)
			UiTranslate(0, 40)
			
			if interface.buttonSwitch("STABILIZER", 400, 60, debris.options.stabilizer) then
				if options.debris.stabilizer then
					for body in pairs(stabilized) do
						SetBodyDynamic(body, true)
						SetBodyVelocity(body, Vec(0, 0, 0))
						stabilized[body] = nil
					end
				end

				debris.options.stabilizer = not debris.options.stabilizer
			end
			UiTranslate(0, 60)
			
			debris.options.stabilizerVoxelCount, stabilizerVoxelCountHeld = interface.slider("VOXEL COUNT", Round(debris.options.stabilizerVoxelCount, -1, 0.5), 400, 60, 0, 1000, theme.button, theme.background, nil, nil, stabilizerVoxelCountHeld)
			UiTranslate(0, 60)
			
			if options.general.advanced then
			debris.options.stabilizerRadius, stabilizerRadiusHeld = interface.slider("RADIUS", Round(debris.options.stabilizerRadius, 0, 0.5), 400, 60, 0, 100, theme.button, theme.background, nil, nil, stabilizerRadiusHeld)
			UiTranslate(0, 60)
			
			debris.options.stabilizerForce, stabilizerForceHeld = interface.slider("FORCE", Round(debris.options.stabilizerForce, 2, 0.005), 400, 60, 0, 1, theme.button, theme.background, nil, nil, stabilizerForceHeld)
			UiTranslate(0, 60)
			end

			UiTranslate(0, 30)

			-- Collider
			interface.color(theme.background)
			UiRect(400, 40)
			interface.text({ text = "COLLIDER", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, theme.text)
			UiTranslate(0, 40)
			if interface.buttonSwitch("COLLIDER", 400, 60, debris.options.collider) then
				debris.options.collider = not debris.options.collider
			end
			UiTranslate(0, 60)
			if interface.buttonSwitch("COLLIDE LEVEL", 400, 60, debris.options.collideLevel) then
				debris.options.collideLevel = not debris.options.collideLevel
			end
			UiTranslate(0, 60)
			debris.options.colliderVoxelCount, colliderVoxelCountHeld = interface.slider("VOXEL COUNT", Round(debris.options.colliderVoxelCount, -1, 0.5), 400, 60, 0, 1000, theme.button, theme.background, nil, nil, colliderVoxelCountHeld)
			UiTranslate(0, 90)
		UiPop()
	UiPop()
end