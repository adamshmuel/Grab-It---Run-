--!strict
-- Structural regression; visual quality is judged against gameplay references separately.
return function(): number
	local modules = game.ServerScriptService.GrabItModules:Clone()
	local World = require(modules.World)
	local world = World.build("GrabItWallFinishTest")
	local ok, err = pcall(function()
		local finish = assert(world:FindFirstChild("WallFinish"), "Approved wall finish must exist")
		local facade =
			assert(world:FindFirstChild("Facade"), "Warehouse front needs deliberate framing")
		for _, sign in facade:GetChildren() do
			assert(
				sign:IsA("BasePart") and not sign.CanCollide and sign.CanQuery,
				"Flat facade never blocks players and participates in camera fading"
			)
			assert(
				math.abs(sign.Position.X) - sign.Size.X / 2 > 8.7 and sign.Size.Z <= 0.12,
				"Facade stays outside the doorway"
			)
			assert(
				sign.Position.Y + sign.Size.Y / 2 <= 6,
				"Facade artwork stays in the lower front wall"
			)
			if sign.Name == "Sign" then
				assert(
					sign.ValueLabel:IsA("SurfaceGui")
						and sign.ValueLabel.Face == Enum.NormalId.Front,
					"Exterior labels face outward on the surface"
				)
			end
		end
		for _, stage in { 1, 2, 3, 1 } do
			World.setStage(world, stage)
			assert(
				world:FindFirstChild("WallFinish") == finish,
				"Stage changes retain one wall finish"
			)
			assert(#finish:GetChildren() == 21, "Stage changes must not accumulate finish parts")
			for _, panel in finish:GetChildren() do
				assert(panel:IsA("BasePart"), "Wall finish consists of native flat parts")
				assert(
					panel.Anchored and not panel.CanCollide and not panel.CanTouch,
					"Finish does not obstruct movement"
				)
				assert(panel.CanQuery, "Opaque finish participates in camera fading")
				assert(panel.Position.Y - panel.Size.Y / 2 >= 0.49, "Finish adds no floor geometry")
				local side = math.abs(panel.Position.X) >= 23.8 and panel.Size.X <= 0.12
				local back = panel.Position.Z >= 119.8 and panel.Size.Z <= 0.12
				assert(
					side or back,
					"Finish remains flat against side/back walls, away from the front board"
				)
			end
			assert(
				#world.Items:GetChildren() == (if stage == 3 then 31 else 30),
				"Finish does not replace cargo"
			)
		end
	end)
	world:Destroy()
	modules:Destroy()
	assert(ok, err)
	return 1
end
