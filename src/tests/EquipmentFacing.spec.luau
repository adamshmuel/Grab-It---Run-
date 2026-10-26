--!strict
-- Tests the equipped assembly, not the standalone collection preview.
return function(): number
	local modules = game.ServerScriptService.GrabItModules:Clone()
	local Appearance = require(modules.Appearance)
	local character = Instance.new("Model")
	local center = Instance.new("Part")
	center.Name = "HumanoidRootPart"
	center.Anchored = true
	center.Parent = character
	local ok, err = pcall(function()
		for _, example in
			{
				{ "canvas", "Buckle", "SoftBag" },
				{ "field", "YellowStrap", "TallPack" },
				{ "royal", "DiamondClasp", "HardCase" },
			}
		do
			local cargo = Appearance.update(character, {
				stage = 1,
				selected = example[1],
				cargo = { 1, 2, 3, 4, 5, 6, 7, 8 },
			})
			local equipment = assert(cargo).CarryingEquipment
			assert(
				equipment[example[2]].Position.Z > equipment[example[3]].Position.Z,
				"Equipped " .. example[1] .. " details must face outward from the avatar back"
			)
			assert(cargo.ExtraCargo.TextLabel.Text == "+5", "Equipment does not change cargo")
		end
	end)
	character:Destroy()
	modules:Destroy()
	assert(ok, err)
	return 1
end
