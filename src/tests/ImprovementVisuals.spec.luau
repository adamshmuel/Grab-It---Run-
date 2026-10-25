--!strict
return function(): number
	local source = game:GetService("ServerScriptService").GrabItModules
	local modules = source:Clone()
	local ok, result = pcall(function()
		local V = require(modules.Visuals)
		local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
		local Catalog = require(shared.Catalog)
		local holder = Instance.new("Folder")
		for stage = 1, 3 do
			for _, item in Catalog.items(stage) do
				local m = V.createItem(item, holder, CFrame.identity, 1)
				local _, size = m:GetBoundingBox()
				local expected = Vector3.new(table.unpack(item.size))
				assert((size - expected).Magnitude < 0.06, "catalog dimensions for " .. item.name)
				local colors = {}
				local parts = 0
				for _, v in m:GetDescendants() do
					if v:IsA("BasePart") then
						colors[tostring(v.Color)] = true
						parts += 1
						assert(not v.CanCollide, "ImprovementVisuals.spec: not v.CanCollide")
					end
				end
				local n = 0
				for _ in colors do
					n += 1
				end
				assert(n >= 3 and parts >= 3, "ImprovementVisuals.spec: n >= 3 and parts >= 3")
			end
		end
		local World = require(modules.World)
		local world = World.build("GrabItDevelopmentFixture")
		World.setStage(world, 3)
		assert(
			#world.Items:GetChildren() == 31 and world:FindFirstChild("SpecialDisplay"),
			'ImprovementVisuals.spec: #world.Items:GetChildren() == 31 and world:FindFirstChild("SpecialDisplay")'
		)
		for _, v in world:GetDescendants() do
			assert(
				not string.find(v.Name, "Shelf"),
				'ImprovementVisuals.spec: not string.find(v.Name, "Shelf")'
			)
		end
		assert(
			world:FindFirstChild("LiveResults"),
			'ImprovementVisuals.spec: world:FindFirstChild("LiveResults")'
		)
		World.setStage(world, 1)
		local star = world.StageDecor:FindFirstChild("ToyStar")
		assert(
			star and star:IsA("Model") and #star:GetChildren() == 5,
			"stage-one wall motif must be a star silhouette"
		)
		assert(
			#world.Items:GetChildren() == 30 and not world:FindFirstChild("SpecialDisplay"),
			'ImprovementVisuals.spec: #world.Items:GetChildren() == 30 and not world:FindFirstChild("SpecialDisplay")'
		)
		world:Destroy()
		holder:Destroy()
		shared:Destroy()
		return 4
	end)
	modules:Destroy()
	assert(ok, result)
	return result
end
