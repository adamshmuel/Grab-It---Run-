--!strict
return function(): number
	local p = assert(game.Players.LocalPlayer, "StylesLayout requires a client")
	local clone = game.ReplicatedStorage.GrabIt:Clone()
	local H = require(clone.ClientModules.Hud)
	local S = require(clone.ClientModules.Styles)
	local ui = H.create()
	ui.Screen.Parent = p.PlayerGui
	ui.Root.Size = UDim2.fromOffset(706, 281)
	local collection = S.create(ui.Root, function() end)
	collection.Panel.Visible = true
	local ok, err = pcall(function()
		task.wait()
		S.update(collection, {
			ready = true,
			inBase = true,
			open = true,
			owned = { basic = true },
			selected = "basic",
			coins = 62,
			purchase = "",
		})
		task.wait()
		local button = collection.Cards[1].Button
		assert(
			button.AbsolutePosition.X >= ui.Root.AbsolutePosition.X + ui.Root.AbsoluteSize.X * 0.2,
			"Style actions must leave the mobile joystick region clear"
		)
		for _, card in collection.Cards do
			assert(card.Button.AbsoluteSize.Y >= 48, "Style actions keep a 48px touch target")
			assert(
				card.Button.Parent:FindFirstChild("Name").TextFits,
				"Design names remain readable"
			)
		end
	end)
	S.destroy(collection)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, err)
	return 1
end
