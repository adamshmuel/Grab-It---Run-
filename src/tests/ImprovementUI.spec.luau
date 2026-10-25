--!strict
return function(): number
	local root = game:GetService("ReplicatedStorage").GrabIt
	local clone = root:Clone()
	local ok, result = pcall(function()
		local H = require(clone.ClientModules.Hud)
		local ui = H.create()
		local state = {
			ready = true,
			open = true,
			save = "Saved",
			coins = 40,
			remaining = 15,
			warning = true,
			stage = 3,
			stageName = "Golden Rush",
			phase = "active",
			mode = "solo",
			cargoCount = 2,
			cargoWeight = "4 + ?",
			cargoValue = "7 + ?",
			capacity = 18,
			bankedCount = 5,
			totalItems = 31,
			tutorial = true,
			inBase = false,
			canNext = false,
			target = 7,
			tooHeavy = false,
		}
		H.update(ui, state, true)
		assert(
			string.find(ui.Bag.Text, "4 + ?", 1, true)
				and not string.find(ui.Bag.Text, "/ 5", 1, true),
			"RED: HUD must show masked total weight"
		)
		assert(
			ui.Next.Visible == false and ui.Styles.Visible == false and ui.Collect.Visible,
			"ImprovementUI.spec: ui.Next.Visible == false and ui.Styles.Visible == false and ui.Collect.Visible"
		)
		state.canNext = true
		state.inBase = true
		H.update(ui, state, true)
		assert(
			ui.Next.Visible and ui.Styles.Visible,
			"ImprovementUI.spec: ui.Next.Visible and ui.Styles.Visible"
		)
		assert(
			ui.StagePath.Text == "Toy Dash > Tech Run > Golden Rush",
			"all three stage names visible from the start"
		)
		local Results = clone.ClientModules:FindFirstChild("Results")
		assert(Results, "RED: results UI missing")
		local resultUI = require(Results).create(ui.Screen)
		require(Results).update(resultUI, {
			phase = "results",
			stage = 1,
			remaining = 5,
			mode = "multi",
			rows = {
				{ id = "a", name = "Adam", score = 22, percent = 20, ranked = true, place = 1 },
			},
			personal = { earnings = 22, stages = { 22, 0, 0 } },
			matchRows = {},
		}, "a")
		assert(
			resultUI.Panel.Visible and resultUI.Rows[1][2].Text == "Adam",
			'ImprovementUI.spec: resultUI.Panel.Visible and resultUI.Rows[1][2].Text == "Adam"'
		)
		local Styles = clone.ClientModules:FindFirstChild("Styles")
		assert(Styles, "RED: style collection missing")
		local collection = require(Styles).create(ui.Screen, function() end)
		require(Styles).update(collection, {
			ready = true,
			inBase = true,
			open = true,
			owned = { basic = true },
			selected = "basic",
			coins = 99,
			purchase = "",
		})
		assert(
			#collection.Cards == 4 and collection.Cards[2].Button.Text == "Buy 100",
			'ImprovementUI.spec: #collection.Cards == 4 and collection.Cards[2].Button.Text == "Buy 100"'
		)
		ui.Screen:Destroy()
		local Gear = clone.Shared:FindFirstChild("Gear")
		assert(Gear, "RED: equipment models missing")
		local shapes = {}
		local g = require(Gear)
		for _, id in { "basic", "canvas", "field", "royal" } do
			local m = g.create(id)
			local _, size = m:GetBoundingBox()
			assert(
				size.X <= 2.81 and size.Y <= 2.81 and size.Z <= 1.21,
				"ImprovementUI.spec: size.X <= 2.81 and size.Y <= 2.81 and size.Z <= 1.21"
			)
			shapes[id] = #m:GetChildren()
			m:Destroy()
		end
		assert(
			shapes.basic ~= shapes.field and shapes.royal ~= shapes.canvas,
			"ImprovementUI.spec: shapes.basic ~= shapes.field and shapes.royal ~= shapes.canvas"
		)
		return 5
	end)
	clone:Destroy()
	assert(ok, result)
	return result
end
