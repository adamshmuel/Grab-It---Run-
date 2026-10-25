--!strict
return function(): number
	local source = game:GetService("ServerScriptService").GrabItModules:Clone()
	local A = require(source.Appearance)
	local character = Instance.new("Model")
	local center = Instance.new("Part")
	center.Name = "HumanoidRootPart"
	center.Anchored = true
	center.CFrame = CFrame.new(0, 4, 0)
	center.Parent = character
	local ok, err = pcall(function()
		local model =
			A.update(character, { stage = 3, selected = "royal", cargo = { 1, 2, 3, 7, 31 } })
		assert(model and model:FindFirstChild("Golden Reactor"), "special always represented")
		assert(#model:GetChildren() == 5, "equipment, three cargo models and +N only")
		assert(
			model.ExtraCargo.TextLabel.Text == "+2",
			'Appearance.spec: model.ExtraCargo.TextLabel.Text == "+2"'
		)
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				assert(
					not part.Anchored
						and not part.CanCollide
						and part.Massless
						and part:FindFirstChildWhichIsA("WeldConstraint"),
					"cosmetic welded parts"
				)
			end
		end
		local empty = A.update(character, { stage = 1, selected = "basic", cargo = {} })
		assert(
			empty and #empty:GetChildren() == 1 and #character:GetChildren() == 2,
			"replace own cargo only"
		)
	end)
	character:Destroy()
	source:Destroy()
	assert(ok, tostring(err))
	return 5
end
