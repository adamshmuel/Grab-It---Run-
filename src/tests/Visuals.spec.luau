--!strict
return function()
	local modules = game:GetService("ServerScriptService").GrabItModules
	local entry = modules:FindFirstChild("Visuals")
	assert(entry, "RED: shared native collectible visuals must exist")
	local fresh = entry:Clone()
	local Visuals = require(fresh)
	fresh:Destroy()
	local folder = Instance.new("Folder")
	local ok, err = pcall(function()
		local sizes = {}
		local Catalog = require(game:GetService("ReplicatedStorage").GrabIt.Shared.Catalog)
		for zone = 1, 3 do
			local m = Visuals.createItem(
				Catalog.items(1)[(zone - 1) * 6 + 1],
				folder,
				CFrame.new(12, 0.5, 18)
			)
			local cf, size = m:GetBoundingBox()
			sizes[zone] = size
			assert(
				size.X <= 3 and size.Y <= 3 and size.Z <= 3,
				"collectible stays inside approved bounds"
			)
			assert(math.abs(cf.Position.Y - size.Y / 2 - 0.5) < 0.01, "object rests on floor")
			local colors, count = {}, 0
			for _, p in m:GetDescendants() do
				if p:IsA("BasePart") then
					count += 1
					colors[tostring(p.Color)] = true
					assert(
						p.Anchored and not p.CanCollide and not p.CanQuery,
						"display parts do not change interactions"
					)
				end
			end
			local distinct = 0
			for _ in colors do
				distinct += 1
			end
			assert(count >= 3 and distinct >= 3, "detail and multiple colors per family")
		end
		assert(sizes[2].Y > sizes[1].Y and sizes[3].X > sizes[1].X, "families have distinct sizes")
		local tiny = Visuals.createItem(Catalog.items(1)[13], folder, CFrame.new(0, 0, 0), 0.45)
		local _, smallSize = tiny:GetBoundingBox()
		assert(math.abs(smallSize.Y / sizes[3].Y - 0.45) < 0.001, "cargo scales the same asset")
		local original = Visuals.createItem(Catalog.items(1)[13], folder, CFrame.new(0, 0, 0))
		local _, originalSize = original:GetBoundingBox()
		assert(
			(originalSize - sizes[3]).Magnitude < 0.001,
			"scaling never modifies the shared template"
		)
	end)
	folder:Destroy()
	assert(ok, tostring(err))
	return 5
end
