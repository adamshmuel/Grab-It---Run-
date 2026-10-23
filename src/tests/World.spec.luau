--!strict
return function()
	local modules = game:GetService("ServerScriptService").GrabItModules
	local entry = modules:FindFirstChild("World")
	assert(entry, "RED: Rojo-managed warehouse builder must exist")
	local fresh = entry:Clone()
	local World = require(fresh :: ModuleScript)
	fresh:Destroy()
	local root = World.build("GrabItWorldTest")
	local ok, err = pcall(function()
		assert(#root.Items:GetChildren() == 30, "thirty personal collectibles")
		assert(root.Base.Size == Vector3.new(40, 1, 24), "base dimensions")
		assert(root.Floor.Size == Vector3.new(48, 1, 120), "warehouse dimensions")
		assert(root.Deposit.Size == Vector3.new(16, 0.1, 8), "deposit dimensions")
		local home = root:FindFirstChild("HomeSymbol")
		assert(home and #home:GetChildren() == 5, "base needs a geometric home symbol")
		for zone = 1, 3 do
			local marker = root:FindFirstChild("ZoneMarker" .. zone)
			assert(
				marker and marker:FindFirstChild("ValueLabel"),
				"each zone needs a large floor number"
			)
		end
		for _, item in root.Items:GetChildren() do
			assert(item:IsA("BasePart") and not item.CanCollide, "collectibles do not block")
			assert(
				item:GetAttribute("ItemId") and item:FindFirstChild("ValueLabel"),
				"identifiable value"
			)
		end
		local entrySign = root:FindFirstChild("EntrySign")
		assert(
			entrySign and entrySign.Position.Y > 12,
			"warehouse status belongs above the entrance"
		)
		assert(entrySign.ValueLabel.TextLabel.TextScaled, "long entrance text must fit its label")
		for _, object in root:GetChildren() do
			if object:IsA("BasePart") and object:FindFirstChild("ValueLabel") then
				assert(
					object.ValueLabel:IsA("SurfaceGui"),
					"environment signs must stay on their surfaces"
				)
			end
		end
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
