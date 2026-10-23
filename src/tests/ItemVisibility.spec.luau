--!strict
return function()
	local modules = game.ReplicatedStorage.GrabIt.ClientModules
	local entry = modules:FindFirstChild("ItemVisibility")
	assert(entry, "RED: multipart personal item visibility must exist")
	local fresh = entry:Clone()
	local Visibility = require(fresh)
	fresh:Destroy()
	local root = Instance.new("Part")
	root.Transparency = 1
	local other = Instance.new("Part")
	local model = Instance.new("Model")
	model.Parent = root
	local detail = Instance.new("Part")
	detail.Parent = model
	local label = Instance.new("BillboardGui")
	label.Name = "ValueLabel"
	label.Parent = root
	local ok, err = pcall(function()
		Visibility.set(root, true)
		assert(
			detail.LocalTransparencyModifier == 1 and not label.Enabled,
			"collected item hides every visual and label"
		)
		assert(other.LocalTransparencyModifier == 0, "uncollected personal copy stays visible")
		Visibility.set(root, false)
		assert(
			detail.LocalTransparencyModifier == 0 and label.Enabled,
			"new round restores details and label"
		)
		assert(root.Transparency == 1, "logical anchor stays invisible")
	end)
	root:Destroy()
	other:Destroy()
	assert(ok, tostring(err))
	return 4
end
