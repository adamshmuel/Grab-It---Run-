--!strict
-- Size regression only; recognition is compared in gameplay, not inferred from this test.
return function(): number
	local modules = game.ServerScriptService.GrabItModules:Clone()
	local Appearance = require(modules.Appearance)
	local character = Instance.new("Model")
	local center = Instance.new("Part")
	center.Name = "HumanoidRootPart"
	center.Anchored = true
	center.Parent = character
	local ok, err = pcall(function()
		local cargo =
			Appearance.update(character, { stage = 1, selected = "basic", cargo = { 3, 19, 25 } })
		local duck = assert(cargo:FindFirstChild("Rubber Duck"), "Duck remains represented")
		local _, duckSize = duck:GetBoundingBox()
		assert(
			math.max(duckSize.X, duckSize.Y, duckSize.Z) >= 1.19,
			"Small carried items need a 1.2-stud visible envelope"
		)
		local _, carSize = cargo["Toy Car"]:GetBoundingBox()
		local _, chestSize = cargo["Toy Chest"]:GetBoundingBox()
		assert(
			carSize.X >= 1.19 and chestSize.X >= 1.19,
			"Small models retain recognizable silhouettes"
		)
		for _, item in cargo:GetChildren() do
			if item:IsA("Model") and item.Name ~= "CarryingEquipment" then
				local pivot, size = item:GetBoundingBox()
				assert(pivot.Position.Y + size.Y / 2 < 1, "Cargo stays below the avatar head")
			end
		end
		local specialCargo =
			Appearance.update(character, { stage = 3, selected = "basic", cargo = { 31, 7 } })
		local _, specialSize = specialCargo["Golden Reactor"]:GetBoundingBox()
		assert(
			math.abs(specialSize.Y - 3.8 * 0.45) < 0.06,
			"Already large special keeps its approved scale"
		)
		assert(
			#character:GetChildren() == 2,
			"Appearance updates replace their own previous models"
		)
		local tech = Appearance.update(character, { stage = 2, selected = "basic", cargo = { 13 } })
		local speaker = tech["Speaker"]
		assert(
			speaker.Cone.Position.Z > speaker.Housing.Position.Z,
			"Identifying speaker cones must face outward from the avatar back"
		)
	end)
	character:Destroy()
	modules:Destroy()
	assert(ok, err)
	return 1
end
