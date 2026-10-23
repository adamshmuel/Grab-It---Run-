--!strict
return function()
	local entry = game:GetService("ServerScriptService").GrabItModules:FindFirstChild("Appearance")
	assert(entry, "RED: cargo appearance must be independently testable")
	local module = entry:Clone()
	local Appearance = require(module :: ModuleScript)
	module:Destroy()
	local character = Instance.new("Model")
	local center = Instance.new("Part")
	center.Name = "HumanoidRootPart"
	center.Anchored = true
	center.CFrame = CFrame.new(0, 4, 0)
	center.Parent = character
	local ok, err = pcall(function()
		local model = Appearance.update(character, { coins = 0, cargo = { 1, 3, 5, 7, 9 } })
		assert(model and #model:GetChildren() == 5, "five collected objects are shown")
		for _, piece in model:GetChildren() do
			local localPosition = center.CFrame:PointToObjectSpace(piece.Position)
			assert(localPosition.Z > 0, "cargo stays behind the avatar")
			assert(
				math.abs(localPosition.X) - piece.Size.X / 2 > 0.5,
				"full stack leaves the central head and body silhouette visible from behind"
			)
			assert(
				not piece.CanCollide and not piece.CanQuery and piece.Massless,
				"cosmetics do not affect gameplay"
			)
		end
		local empty = Appearance.update(character, { coins = 30, cargo = {} })
		assert(empty and #empty:GetChildren() == 4, "unlocked frame remains with empty cargo")
		assert(#character:GetChildren() == 2, "updates replace only the owned cargo model")
	end)
	character:Destroy()
	assert(ok, tostring(err))
	return 3
end
