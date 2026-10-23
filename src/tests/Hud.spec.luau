--!strict
return function()
	local modules = game:GetService("ReplicatedStorage").GrabIt.ClientModules
	local entry = modules:FindFirstChild("Hud")
	assert(entry, "RED: shared desktop/mobile HUD must exist")
	local fresh = entry:Clone()
	fresh.Name = "HudTestCopy"
	fresh.Parent = modules
	local Hud = require(fresh :: ModuleScript)
	fresh:Destroy()
	local ui = Hud.create()
	local ok, err = pcall(function()
		Hud.update(ui, {
			coins = 7,
			cargoCount = 2,
			cargoValue = 7,
			open = true,
			remaining = 29,
			warning = true,
			save = "Saved",
			tutorial = false,
		}, false)
		assert(string.find(ui.Coins.Text, "7"), "banked balance")
		assert(string.find(ui.Bag.Text, "2 / 5"), "cargo count")
		assert(string.find(ui.Round.Text, "RETURN"), "closing warning")
		Hud.update(ui, {
			coins = 105,
			cargoCount = 0,
			cargoValue = 0,
			open = false,
			remaining = 20,
			ready = true,
			save = "Saving",
			tutorial = true,
		}, true)
		assert(string.find(ui.Style.Text, "300"), "next progression target")
		assert(not ui.Collect.Visible, "closed warehouse cannot offer collection")
		assert(
			ui.Tutorial.Visible,
			"returning players must see the next-round message while closed"
		)
		assert(ui.Screen.ScreenInsets == Enum.ScreenInsets.CoreUISafeInsets, "safe screen area")
		assert(
			ui.Coins.BackgroundTransparency == 0
				and ui.Round.BackgroundTransparency == 0
				and ui.Style.BackgroundTransparency == 0,
			"world signs must not bleed through the permanent top HUD"
		)
		local tutorialRight = ui.Tutorial.Position.X.Scale + ui.Tutorial.Size.X.Scale
		local collectLeft = ui.Collect.Position.X.Scale - ui.Collect.Size.X.Scale
		assert(
			tutorialRight < collectLeft,
			"tutorial must leave a gap before the touch collect button"
		)
		local available = {
			coins = 0,
			cargoCount = 0,
			cargoValue = 0,
			open = true,
			remaining = 100,
			ready = true,
			target = 1,
			save = "Saved",
			tutorial = false,
		}
		Hud.update(ui, available, false)
		assert(
			not ui.Collect.Visible,
			"desktop uses the selected-item key hint instead of a duplicate touch button"
		)
		Hud.update(ui, available, true)
		assert(
			ui.Collect.Visible and ui.Collect.Text == "Collect",
			"touch keeps its collection button"
		)
	end)
	ui.Screen:Destroy()
	assert(ok, tostring(err))
	print("PASS HUD balance, cargo, warnings, progression and safe area")
	return 7
end
