--!strict
-- Geometry regression only. Recognizability and finish still require actual image review.
return function(): number
	local source = game.ReplicatedStorage.GrabIt.Shared.Gear:Clone()
	local Gear = require(source)
	local bag = Gear.create("canvas")
	local ok, err = pcall(function()
		local body = assert(bag:FindFirstChild("SoftBag"), "Canvas needs a bag body") :: BasePart
		local pocket = bag:FindFirstChild("FrontPocket")
		assert(pocket and pocket:IsA("Model"), "Canvas needs a separate functional front pocket")
		local pocketFrame, pocketSize = pocket:GetBoundingBox()
		assert(
			pocketFrame.Position.Z - pocketSize.Z / 2 < body.Position.Z - body.Size.Z / 2,
			"The pocket must project out from the front of the bag, not sit inside its body"
		)
		assert(
			pocketFrame.Position.Y + pocketSize.Y / 2 < body.Position.Y + body.Size.Y / 2,
			"The pocket must leave a distinct upper bag compartment"
		)
		local straps = 0
		for _, part in bag:GetDescendants() do
			if part:IsA("BasePart") and part.Name == "ShoulderStrap" then
				straps += 1
				assert(
					part.Position.Z > body.Position.Z,
					"Shoulder straps belong behind the bag, away from the front pocket"
				)
				assert(
					part.Position.Y + part.Size.Y / 2 <= body.Position.Y + body.Size.Y / 2 + 0.2,
					"Shoulder straps must not form antenna-like rods above the bag"
				)
			end
		end
		assert(straps >= 2, "Both shoulders need carrying straps")
		for _, id in { "basic", "canvas", "field", "royal" } do
			local model = Gear.create(id)
			local _, size = model:GetBoundingBox()
			local withinBounds = size.X <= 2.81 and size.Y <= 2.81 and size.Z <= 1.21
			local parts, safe = 0, true
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					parts += 1
					safe = safe and not part.CanCollide and not part.CanTouch and not part.CanQuery
				end
			end
			model:Destroy()
			assert(withinBounds, "Equipment must stay inside the approved worn envelope")
			assert(parts <= 64 and safe, "Equipment must keep its part budget and no collisions")
		end
	end)
	bag:Destroy()
	source:Destroy()
	assert(ok, err)
	return 2
end
