--!strict
return function(): number
	local module = game.ServerScriptService.GrabItModules.Visuals:Clone()
	local Visuals = require(module)
	local Catalog = require(game.ReplicatedStorage.GrabIt.Shared.Catalog)
	local holder = Instance.new("Folder")
	local ok, err = pcall(function()
		local drum = Visuals.createItem(Catalog.items(1)[13], holder, CFrame.identity)
		assert(
			math.abs(drum.Drum.CFrame.RightVector.Y) > 0.99,
			"Drum cylinder must stand upright rather than receive a second rotation"
		)
		local rim = drum.Rim
		assert(
			rim.Size.X < math.min(rim.Size.Y, rim.Size.Z),
			"Drum rim is a thin disc on its cylinder axis"
		)
		local camera = Visuals.createItem(Catalog.items(2)[7], holder, CFrame.identity)
		assert(
			math.abs(camera.Lens.CFrame.RightVector.Z) > 0.99,
			"Camera lens must face forward as a disc, not a vertical bar"
		)
		local speaker = Visuals.createItem(Catalog.items(2)[13], holder, CFrame.identity)
		assert(
			math.abs(speaker.Cone.CFrame.RightVector.Z) > 0.99,
			"Speaker cones must face forward"
		)
	end)
	holder:Destroy()
	module:Destroy()
	assert(ok, err)
	return 1
end
