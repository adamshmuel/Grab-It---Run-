--!strict
return function()
	local guiService = game:GetService("GuiService")
	local originalControls = guiService.TouchControlsEnabled
	guiService.TouchControlsEnabled = true
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
			cargoWeight = "4",
			ready = true,
			cargoValue = 7,
			open = true,
			remaining = 29,
			warning = true,
			save = "Saved",
			tutorial = false,
		}, false)
		assert(string.find(ui.Coins.Text, "7"), "banked balance")
		assert(string.find(ui.Bag.Text, "4 / 10"), "cargo count")
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
		assert(ui.Styles.Visible, "styles available during results")
		assert(not ui.Collect.Visible, "closed warehouse cannot offer collection")
		assert(ui.Styles.Visible, "results retain access to style collection")
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
		for _, phase in { "results", "summary", "active" } do
			available.phase = phase
			Hud.update(ui, available, true)
			assert(
				guiService.TouchControlsEnabled == (phase == "active"),
				"Movement controls must not cover results; restore them during active play"
			)
		end
		available.phase = "summary"
		Hud.update(ui, available, true)
	end)
	ui.Screen:Destroy()
	local controlsRestored = guiService.TouchControlsEnabled
	guiService.TouchControlsEnabled = originalControls
	assert(controlsRestored, "Restore controls on HUD cleanup")
	assert(ok, tostring(err))
	print("PASS HUD balance, cargo, warnings, progression and safe area")
	return 8
end
