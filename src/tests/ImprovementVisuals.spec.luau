--!strict
return function(): number
	local source = game:GetService("ServerScriptService").GrabItModules
	local modules = source:Clone()
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
	local holder = Instance.new("Folder")
	local world: Model? = nil
	local ok, result = pcall(function()
		local V = require(modules.Visuals)
		local Catalog = require(shared.Catalog)
		for stage = 1, #Catalog.stages do
			for _, item in Catalog.items(stage) do
				local m = V.createItem(item, holder, CFrame.identity, 1)
				local _, size = m:GetBoundingBox()
				local expected = Vector3.new(table.unpack(item.size))
				assert(
					size.X <= expected.X + 0.01
						and size.Y <= expected.Y + 0.01
						and size.Z <= expected.Z + 0.01,
					"catalog envelope for " .. item.name
				)
				local carryScale = V.carryScale(item)
				local carried = V.createItem(item, holder, CFrame.identity, carryScale)
				local _, carriedSize = carried:GetBoundingBox()
				assert(
					(carriedSize - size * carryScale).Magnitude < 0.06,
					"Carried model preserves fitted proportions: " .. item.name
				)
				for index, part in carried:GetChildren() do
					if part:IsA("BasePart") then
						local original = m:GetChildren()[index]
						assert(
							original and (part.Size - original.Size * carryScale).Magnitude < 0.035,
							"Native minimum part size distorts carried detail: "
								.. item.name
								.. " / "
								.. part.Name
						)
					end
				end
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
				assert(
					n >= 3 and parts >= 3 and parts <= 64,
					"Model color roles and bounded part budget; not a visual-quality verdict"
				)
			end
		end
		local cameraItem = Catalog.items(2)[7]
		local wideItem = table.clone(cameraItem)
		wideItem.size = { cameraItem.size[1] * 2, cameraItem.size[2], cameraItem.size[3] }
		local normal = V.createItem(cameraItem, holder, CFrame.identity)
		local wide = V.createItem(wideItem, holder, CFrame.identity)
		assert(
			math.abs(normal.Body.Size.X / normal.Body.Size.Y - wide.Body.Size.X / wide.Body.Size.Y)
				< 0.001,
			"A wider allowed envelope must not stretch a camera body out of proportion"
		)
		local World = require(modules.World)
		world = World.build("GrabItDevelopmentFixture")
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
		for stage = 4, 5 do
			local layout = Catalog.nextLayout(stage, Random.new(12))
			World.setStage(world, stage, layout)
			assert(
				#world.Items:GetChildren() == 31 and world.SpecialDisplay,
				"Late-stage special display"
			)
			assert(
				world:GetAttribute("LayoutVariant") == layout.variant
					and world:GetAttribute("LayoutFlips") == layout.flips,
				"World declares actual layout"
			)
			for _, item in Catalog.items(stage, layout) do
				assert(
					world.Items[tostring(item.id)]:FindFirstChild(item.name),
					"Native world uses actual randomized product"
				)
			end
		end
		World.setStage(world, 1)
		local posters = 0
		for _, entry in world.StageDecor:GetChildren() do
			if entry.Name == "ProductPoster" then
				posters += 1
				local frame, size = entry:GetBoundingBox()
				local wallDepth = math.abs(frame.RightVector.X) * size.X
					+ math.abs(frame.UpVector.X) * size.Y
					+ math.abs(frame.LookVector.X) * size.Z
				assert(wallDepth <= 0.121, "Product posters must stay flat against the side walls")
				assert(
					math.abs(frame.Position.X) + wallDepth / 2 <= 23.851,
					"Product posters must sit in front of the wall framing, not behind an upright"
				)
				assert(
					entry:FindFirstChild("Artwork"),
					"Posters need product artwork, not unrelated tiles"
				)
				for _, part in entry:GetDescendants() do
					if part:IsA("BasePart") then
						if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
							assert(
								math.min(part.Size.X, part.Size.Y, part.Size.Z)
										/ math.max(part.Size.X, part.Size.Y, part.Size.Z)
									>= 0.2,
								"Flattened product spheres must retain a visible projected silhouette"
							)
						end
						assert(
							not part.CanCollide and not part.CanTouch and part.CanQuery,
							"Poster geometry must not obstruct players and must fade with the wall"
						)
					end
				end
			end
		end
		assert(posters == 6, "Each department needs three product posters on each side")

		assert(
			#world.Items:GetChildren() == 30 and not world:FindFirstChild("SpecialDisplay"),
			'ImprovementVisuals.spec: #world.Items:GetChildren() == 30 and not world:FindFirstChild("SpecialDisplay")'
		)
		return 4
	end)
	if world then
		world:Destroy()
	end
	holder:Destroy()
	shared:Destroy()
	modules:Destroy()
	assert(ok, result)
	return result
end
