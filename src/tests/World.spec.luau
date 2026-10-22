--!strict
return function()
	local modules = game:GetService("ServerScriptService").GrabItModules
	local entry = modules:FindFirstChild("World")
	assert(entry, "RED: Rojo-managed warehouse builder must exist")
	local World = require(entry :: ModuleScript)
	local root = World.build("GrabItWorldTest")
	local ok, err = pcall(function()
		assert(#root.Items:GetChildren() == 30, "thirty personal collectibles")
		assert(root.Base.Size == Vector3.new(40, 1, 24), "base dimensions")
		assert(root.Floor.Size == Vector3.new(48, 1, 120), "warehouse dimensions")
		assert(root.Deposit.Size == Vector3.new(16, 0.1, 8), "deposit dimensions")
		for _, item in root.Items:GetChildren() do
			assert(item:IsA("BasePart") and not item.CanCollide, "collectibles do not block")
			assert(
				item:GetAttribute("ItemId") and item:FindFirstChild("ValueLabel"),
				"identifiable value"
			)
		end
		assert(root.Door.ValueLabel.TextLabel.TextScaled, "long door text must fit its label")
		World.setOpen(root, false)
		assert(root.Door.CanCollide and root.Door.Transparency == 0, "closed entry blocks")
		World.setOpen(root, true)
		assert(not root.Door.CanCollide, "open entry")
	end)
	root:Destroy()
	assert(ok, tostring(err))
	print("PASS warehouse geometry, thirty items, labels and closure")
	return 7
end
