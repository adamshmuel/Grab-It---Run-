--!strict
-- Run on a client: these are measured GUI bounds, not device-emulation evidence.
return function(): number
	local players = game:GetService("Players")
	assert(players.LocalPlayer, "TouchButtonLayout requires a client")
	local clone = game:GetService("ReplicatedStorage").GrabIt:Clone()
	local ui = require(clone.ClientModules.Hud).create()
	local ok, result = pcall(function()
		ui.Screen.Parent = players.LocalPlayer.PlayerGui
		for _, size in { Vector2.new(706, 281), Vector2.new(750, 332), Vector2.new(1920, 1022) } do
			ui.Root.Size = UDim2.fromOffset(size.X, size.Y)
			task.wait()
			assert(
				ui.StagePath.AbsolutePosition.Y
					>= ui.Round.AbsolutePosition.Y + ui.Round.AbsoluteSize.Y,
				"Stage names must not overlap the timer at desktop resolutions"
			)
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
		end
		return 1
	end)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, result)
	return result
end
