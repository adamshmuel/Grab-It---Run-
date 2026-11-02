--!strict
-- Run on a client: these are measured GUI bounds, not device-emulation evidence.
return function(): number
	local players = game:GetService("Players")
	assert(players.LocalPlayer, "TouchButtonLayout requires a client")
	local clone = game:GetService("ReplicatedStorage").GrabIt:Clone()
	local Hud = require(clone.ClientModules.Hud)
	local ui = Hud.create()
	local ok, result = pcall(function()
		ui.Screen.Parent = players.LocalPlayer.PlayerGui
		for _, size in
			{
				Vector2.new(640, 281),
				Vector2.new(706, 281),
				Vector2.new(750, 332),
				Vector2.new(1920, 1022),
			}
		do
			ui.Root.Size = UDim2.fromOffset(size.X, size.Y)
			Hud.update(ui, {
				ready = true,
				open = true,
				phase = "active",
				stage = 1,
				stageName = "Expedition Run",
				coins = 1000000,
				save = "Saved",
				remaining = 5,
				warning = true,
				tutorial = true,
				cargoWeight = "4 + ?",
				cargoValue = "7 + ?",
				capacity = 22,
				bankedCount = 31,
				totalItems = 31,
			}, true)
			task.wait()
			assert(
				ui.Coins.TextFits and ui.Metadata.TextFits and ui.Round.TextFits and ui.Bag.TextFits,
				"Essential HUD data fits at 18px, including a large wallet and the long stage name"
			)
			assert(
				not ui.Root:FindFirstChild("StagePath"),
				"A full stage-name strip must not cover the game"
			)
			assert(ui.Metadata, "Stage information needs a compact metadata row")
			local origin = ui.Root.AbsolutePosition
			assert(
				ui.Metadata.AbsolutePosition.Y + ui.Metadata.AbsoluteSize.Y
					<= ui.Round.AbsolutePosition.Y,
				"Stage information must stay above the independent timer"
			)
			assert(
				ui.Round.TextBounds.Y >= 28,
				"Rendered timer digits remain prominent, not only the configured size"
			)
			for _, header in { ui.Coins, ui.Metadata, ui.Round, ui.Scores, ui.Styles } do
				assert(
					header.AbsolutePosition.Y + header.AbsoluteSize.Y - origin.Y <= 56,
					"Header stays within 56px"
				)
			end
			assert(
				ui.Collect.AbsoluteSize.X >= 48 and ui.Collect.AbsoluteSize.Y >= 48,
				"Collect must retain a 48px touch target inside the safe area"
			)
			local lowerRight = ui.Collect.AbsolutePosition + ui.Collect.AbsoluteSize
			local boundary = ui.Root.AbsolutePosition + ui.Root.AbsoluteSize
			assert(lowerRight.X <= boundary.X and lowerRight.Y <= boundary.Y, "Collect must fit")
			local tutorialBottom = ui.Tutorial.AbsolutePosition.Y + ui.Tutorial.AbsoluteSize.Y
			assert(
				tutorialBottom <= ui.Bag.AbsolutePosition.Y,
				"Tutorial and cargo information must not overlap in the mobile safe area"
			)
			local bagLeft = ui.Bag.AbsolutePosition.X - origin.X
			local bagRight = bagLeft + ui.Bag.AbsoluteSize.X
			assert(
				bagLeft >= 178 and bagRight <= size.X - 140,
				"Cargo clears the reserved touch areas"
			)
			for _, panel in { ui.Coins, ui.Metadata, ui.Round, ui.Scores, ui.Styles, ui.Bag } do
				local pos = panel.AbsolutePosition - origin
				local dim = panel.AbsoluteSize
				assert(
					not (
							pos.X < size.X * 0.68
							and pos.X + dim.X > size.X * 0.32
							and pos.Y < size.Y * 0.70
							and pos.Y + dim.Y > size.Y * 0.24
						),
					"Permanent HUD leaves the center clear"
				)
			end
		end
		return 1
	end)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, result)
	return result
end
