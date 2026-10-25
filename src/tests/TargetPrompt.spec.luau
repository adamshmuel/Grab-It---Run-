--!strict
return function()
	local modules = game:GetService("ReplicatedStorage").GrabIt.ClientModules
	local entry = modules:FindFirstChild("TargetPrompt")
	assert(entry, "RED: selected item needs an overhead collection prompt")
	local fresh = entry:Clone()
	local owner = Instance.new("Folder")
	local ok, err = pcall(function()
		local Prompt = require(fresh :: ModuleScript)
		local ui = Prompt.create(owner)
		assert(ui.Gui:IsA("BillboardGui") and ui.Gui.Parent == owner, "player-owned world prompt")
		assert(not ui.Gui.Enabled and ui.Gui.Adornee == nil, "no selection while loading")
		assert(not ui.Gui.AlwaysOnTop, "prompt cannot show through walls")
		local items = Instance.new("Folder")
		items.Parent = owner
		for id = 1, 2 do
			local item = Instance.new("Part")
			item.Name = tostring(id)
			item.Parent = items
		end
		local state = { ready = true, open = true, target = 1, cargoCount = 0, collected = {} }
		Prompt.update(ui, state, items, false)
		assert(ui.Gui.Enabled and ui.Gui.Adornee == items["1"], "mark selected item")
		assert(ui.Label.Text == "Collect [E]", "desktop key shown over item")
		state.target = 2
		Prompt.update(ui, state, items, false)
		assert(ui.Gui.Adornee == items["2"], "move one prompt to the new selected item")
		local prompts = 0
		for _, child in owner:GetChildren() do
			if child:IsA("BillboardGui") then
				prompts += 1
			end
		end
		assert(prompts == 1, "only one item is marked")
		state.open = false
		Prompt.update(ui, state, items, false)
		assert(not ui.Gui.Enabled and ui.Gui.Adornee == nil, "closed warehouse clears selection")
		state.open = true
		state.ready = false
		Prompt.update(ui, state, items, false)
		assert(not ui.Gui.Enabled, "loading player has no collection prompt")
		state.ready = true
		state.collected[2] = true
		Prompt.update(ui, state, items, false)
		assert(not ui.Gui.Enabled, "collected item has no collection prompt")
		state.collected = {}
		items["2"]:Destroy()
		Prompt.update(ui, state, items, false)
		assert(not ui.Gui.Enabled, "missing replicated item clears selection")
		Prompt.update(ui, state, nil, false)
		assert(not ui.Gui.Enabled, "missing map is safe")
		state.target = 1
		state.tooHeavy = true
		Prompt.update(ui, state, items, true)
		assert(
			ui.Gui.Enabled and ui.Label.Text == "Too heavy",
			"overweight explains unavailable action"
		)
		state.tooHeavy = false
		Prompt.update(ui, state, items, true)
		assert(ui.Label.Text == "Collect", "touch prompt does not ask for a keyboard")
	end)
	fresh:Destroy()
	owner:Destroy()
	assert(ok, tostring(err))
	return 4
end
