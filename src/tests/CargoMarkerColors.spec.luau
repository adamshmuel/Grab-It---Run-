--!strict
return function(): number
	local modules = game:GetService("ServerScriptService").GrabItModules:Clone()
	local World = require(modules.World)
	local Catalog = require(game:GetService("ReplicatedStorage").GrabIt.Shared.Catalog)
	local root = World.build("GrabItCargoMarkerTest")
	local ok, result = pcall(function()
		local function markerFor(item): BasePart
			local found: BasePart? = nil
			local count = 0
			for _, marker in root.StageDecor:GetChildren() do
				if marker:IsA("BasePart") and marker.Name == "CargoMarker" then
					count += 1
					if
						math.abs(marker.Position.X - item.x) < 0.01
						and math.abs(marker.Position.Z - item.z) < 0.01
					then
						assert(not found, "Only one marker per product position")
						found = marker
					end
				end
			end
			assert(count == 30, "Thirty regular markers after every layout change")
			return assert(found, "Each regular product has a floor marker")
		end
		for stage = 1, 5 do
			World.setStage(root, stage)
			local colors = {}
			for _, item in Catalog.items(stage) do
				if not item.special then
					colors[item.kind] = markerFor(item).Color
				end
			end
			if stage > 1 then
				for _, layout in
					{
						{ variant = 1, flips = 0 },
						{ variant = 1, flips = 32767 },
						{ variant = Catalog.variantCount(stage), flips = 21845 },
					}
				do
					World.setStage(root, stage, layout)
					for _, item in Catalog.items(stage, layout) do
						if not item.special then
							assert(
								markerFor(item).Color == colors[item.kind],
								"Floor marker preserves product color after random quantities and side flips: "
									.. item.name
							)
						end
					end
					task.wait()
				end
			end
		end
		return 1
	end)
	root:Destroy()
	modules:Destroy()
	assert(ok, result)
	return result
end
