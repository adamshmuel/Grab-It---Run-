--!strict
return function(): number
	local worldModule = game.ServerScriptService.GrabItModules.World:Clone()
	worldModule.Parent = game.ServerScriptService.GrabItModules
	local world = require(worldModule).build("GrabItDevelopmentFixture")
	local promptModule = game.ReplicatedStorage.GrabIt.ClientModules.TargetPrompt:Clone()
	local owner = Instance.new("Folder")
	local ok, err = pcall(function()
		for _, item in world.Items:GetChildren() do
			assert(
				not item:FindFirstChildOfClass("BillboardGui"),
				"Unselected item labels clutter the view"
			)
		end
		local Prompt = require(promptModule)
		local ui = Prompt.create(owner)
		assert(ui.Gui:IsA("ScreenGui"), "Projected information needs an unclipped screen layer")
		Prompt.update(ui, {
			ready = true,
			open = true,
			target = 1,
			collected = {},
			cargoCount = 0,
			targetName = "Rubber Duck",
			targetInfo = "Weight 1 | Value 2",
		}, world.Items, true)
		assert(ui.Gui.Enabled, "Selected item retains a prompt")
		assert(
			string.find(ui.Label.Text, "Rubber Duck", 1, true),
			"Selected item name remains available"
		)
		assert(
			string.find(ui.Label.Text, "Weight 1 | Value 2", 1, true),
			"Selected weight and reward remain available"
		)
		assert(
			Prompt.placement,
			"Selected information must fit beside the avatar and outside the HUD"
		)
		for _, x in { 5, 200, 353, 500, 700 } do
			local pos = Prompt.placement(Vector2.new(x, 100), Vector2.new(220, 66), {
				left = 0,
				right = 706,
				top = 136,
				bottom = 291,
				headX = 353,
			})
			assert(pos.X - 110 >= 0 and pos.X + 110 <= 706, "Prompt stays on screen")
			assert(pos.Y - 33 >= 136 and pos.Y + 33 <= 291, "Prompt stays between the HUD rows")
			assert(math.abs(pos.X - 353) >= 130, "Prompt leaves the avatar head clear")
		end
		assert(Prompt.lineOfSight, "Prompt needs an explicit opaque-wall visibility check")
		local wall = Instance.new("Part")
		wall.Anchored = true
		wall.Size = Vector3.new(1, 10, 10)
		wall.Position = Vector3.new(1005, 4, 1000)
		wall.Parent = world
		local origin, target = Vector3.new(1000, 4, 1000), Vector3.new(1010, 4, 1000)
		assert(
			not Prompt.lineOfSight(origin, target, {}),
			"An opaque wall hides the selected prompt"
		)
		wall.LocalTransparencyModifier = 1
		assert(
			Prompt.lineOfSight(origin, target, {}),
			"A locally hidden camera wall must not clip information"
		)
		wall.LocalTransparencyModifier = 0.5
		assert(
			Prompt.lineOfSight(origin, target, {}),
			"A camera wall mid-fade must not hide readable information"
		)
	end)
	owner:Destroy()
	promptModule:Destroy()
	world:Destroy()
	worldModule:Destroy()
	assert(ok, err)
	return 1
end
