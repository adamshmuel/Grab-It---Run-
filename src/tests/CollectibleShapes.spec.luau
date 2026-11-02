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
			camera.Lens:IsA("Part") and camera.Lens.Shape == Enum.PartType.Cylinder,
			"Lens geometry uses the native cylinder whose axis is verified below"
		)
		assert(
			math.abs(camera.Lens.CFrame.RightVector.Z) > 0.99,
			"Camera lens must face forward as a disc, not a vertical bar"
		)
		local speaker = Visuals.createItem(Catalog.items(2)[13], holder, CFrame.identity)
		assert(
			math.abs(speaker.Cone.CFrame.RightVector.Z) > 0.99,
			"Speaker cones must face forward"
		)
		local drone = Visuals.createItem(Catalog.items(2)[19], holder, CFrame.identity)
		local motors = 0
		for _, motor in drone:GetChildren() do
			if motor:IsA("BasePart") and motor.Name == "Motor" then
				motors += 1
				local blades = {}
				for _, blade in drone:GetChildren() do
					if blade:IsA("BasePart") and blade.Name == "Rotor" then
						local delta = blade.Position - motor.Position
						if Vector2.new(delta.X, delta.Z).Magnitude < 0.03 then
							table.insert(blades, blade)
						end
					end
				end
				assert(#blades == 2, "Each motor needs two crossing propeller blades")
				assert(
					math.abs(blades[1].CFrame.RightVector:Dot(blades[2].CFrame.RightVector)) < 0.05,
					"A propeller must have a cross silhouette rather than two parallel bars"
				)
				assert(
					blades[1].Size.X > motor.Size.Y * 2,
					"Propeller blades must visibly extend beyond their motor"
				)
			end
		end
		assert(motors == 4, "A quadcopter must have four powered rotor assemblies")
		local gems = Visuals.createItem(Catalog.items(3)[1], holder, CFrame.identity)
		for _, tip in gems:GetChildren() do
			if tip:IsA("WedgePart") and tip.Name == "CrystalTip" then
				local nearest = nil
				for _, body in gems:GetChildren() do
					if body:IsA("BasePart") and body.Name == "Crystal" then
						if
							not nearest
							or math.abs(body.Position.X - tip.Position.X)
								< math.abs(nearest.Position.X - tip.Position.X)
						then
							nearest = body
						end
					end
				end
				local peak =
					tip.CFrame:PointToWorldSpace(Vector3.new(0, tip.Size.Y / 2, tip.Size.Z / 2))
				assert(
					nearest and math.abs(peak.X - nearest.Position.X) < 0.02,
					"Crystal facets must meet at a central peak, not form a split V"
				)
			end
		end
	end)
	holder:Destroy()
	module:Destroy()
	assert(ok, err)
	return 1
end
