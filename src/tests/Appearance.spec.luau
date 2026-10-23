--!strict
return function()
	local entry = game:GetService("ServerScriptService").GrabItModules:FindFirstChild("Appearance")
	assert(entry, "RED: cargo appearance must be independently testable")
	local module = entry:Clone()
	module.Name = "AppearanceTestCopy"
	module.Parent = entry.Parent
	local Appearance = require(module :: ModuleScript)
	module:Destroy()
	local character = Instance.new("Model")
	local center = Instance.new("Part")
	center.Name = "HumanoidRootPart"
	center.Anchored = true
	center.CFrame = CFrame.new(0, 4, 0)
	center.Parent = character
	local ok, err = pcall(function()
		local model = Appearance.update(character, { coins = 0, cargo = { 1, 11, 21, 1, 21 } })
		assert(model and #model:GetChildren() == 5, "five collected objects are shown")
		local families = {}
		for _, cargo in model:GetChildren() do
			assert(cargo:IsA("Model"), "carried items keep their actual family shape")
			families[cargo.Name] = true
			for _, piece in cargo:GetDescendants() do
				if piece:IsA("BasePart") then
					local localPosition = center.CFrame:PointToObjectSpace(piece.Position)
					assert(localPosition.Z > 0, "cargo stays behind the avatar")
					assert(
						math.abs(localPosition.X) - piece.Size.Magnitude / 2 > 0.5,
						"cargo leaves head and body visible"
					)
					assert(
						not piece.Anchored
							and not piece.CanCollide
							and not piece.CanQuery
							and piece.Massless,
						"cargo is welded cosmetic geometry"
					)
					assert(
						piece:FindFirstChildWhichIsA("WeldConstraint"),
						"each visual detail follows the avatar"
					)
				end
			end
		end
		local count = 0
		for _ in families do
			count += 1
		end
		assert(count == 3, "mixed cargo retains all three collectible families")
		local empty = Appearance.update(character, { coins = 30, cargo = {} })
		assert(empty and #empty:GetChildren() == 4, "unlocked frame remains with empty cargo")
		assert(#character:GetChildren() == 2, "updates replace only the owned cargo model")
	end)
	character:Destroy()
	assert(ok, tostring(err))
	return 3
end
