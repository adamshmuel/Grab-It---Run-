--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local root = game:GetService("ReplicatedStorage"):WaitForChild("GrabIt", 20)
assert(root, "GrabIt content was not replicated")
local Hud = require(root.ClientModules.Hud)
local TargetPrompt = require(root.ClientModules.TargetPrompt)
local ItemVisibility = require(root.ClientModules.ItemVisibility)
local Results = require(root.ClientModules.Results)
local Scores = require(root.ClientModules.Scores)
local Styles = require(root.ClientModules.Styles)
local Catalog = require(root.Shared.Catalog)
local player = Players.LocalPlayer
local ui = Hud.create()
ui.Screen.Parent = player:WaitForChild("PlayerGui", 20)
local targetPrompt = TargetPrompt.create(ui.Screen.Parent)
player.CameraMinZoomDistance = 8
player.CameraMaxZoomDistance = 20
player.CameraMode = Enum.CameraMode.Classic
local View = require(root.Shared.Presentation)
local Wire = require(root.Shared.NetworkState)
local RunService = game:GetService("RunService")
local state = nil
local connections = {}
local sounds = {}
local displayedTarget = nil
local results = Results.create(ui.Screen)
local scores = Scores.create(ui.Screen)
local collection = Styles.create(ui.Screen, function(action, id)
	root.Action:FireServer(action, id)
end)
local board = nil
local visibilityFolder = nil
local visibilityConnection = nil
local visibilityDirty = true
local visibilityMask = -1
local visibilityRound = -1
local function currentTarget()
	local character = player.Character
	local center = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if not state or not center or not humanoid or humanoid.Health <= 0 then
		return nil
	end
	return View.collectionTarget(Catalog.items(state.stage), state, center.Position)
end
local function orientCamera(character)
	local center = character:WaitForChild("HumanoidRootPart", 10)
	if not center then
		return
	end
	RunService.RenderStepped:Wait()
	local camera = workspace.CurrentCamera
	if camera and player.Character == character then
		player.CameraMinZoomDistance = 14
		player.CameraMaxZoomDistance = 14
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = View.camera(center.Position)
		task.wait(0.1)
		if player.Character == character then
			camera.CameraType = Enum.CameraType.Custom
			RunService.RenderStepped:Wait()
			if player.Character == character then
				player.CameraMinZoomDistance = 8
				player.CameraMaxZoomDistance = 20
			end
		end
	end
end
table.insert(
	connections,
	player.CharacterAdded:Connect(function(character)
		task.spawn(orientCamera, character)
	end)
)
if player.Character then
	task.spawn(orientCamera, player.Character)
end

for kind, pitch in { collect = 1.3, bank = 1.7, lost = 0.6, warning = 0.8, open = 1.1, style = 2 } do
	local sound = Instance.new("Sound")
	sound.Name = "GrabIt_" .. kind
	sound.SoundId = "rbxasset://sounds/volume_slider.ogg"
	sound.Volume = 0.35
	sound.PlaybackSpeed = pitch
	sound.Parent = SoundService
	sounds[kind] = sound
end
local function play(kind)
	local sound = sounds[kind]
	if sound then
		sound:Play()
	end
end
local function collect()
	local target = currentTarget()
	if target then
		root.Action:FireServer("collect", target)
	end
end
table.insert(connections, ui.Collect.Activated:Connect(collect))
table.insert(
	connections,
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.E then
			collect()
		end
	end)
)
local messageToken = 0
local function message(text, duration)
	messageToken += 1
	local token = messageToken
	ui.Message.Text = text
	ui.Message.Visible = true
	task.delay(duration, function()
		if messageToken == token and ui.Screen.Parent then
			ui.Message.Visible = false
		end
	end)
end
table.insert(
	connections,
	root.Notice.OnClientEvent:Connect(function(text, kind)
		play(kind)
		if kind ~= "collect" then
			message(text, if kind == "lost" or kind == "style" then 3 else 2)
		end
	end)
)
table.insert(
	connections,
	ui.Next.Activated:Connect(function()
		root.Action:FireServer("next")
	end)
)
table.insert(
	connections,
	ui.Styles.Activated:Connect(function()
		scores.Panel.Visible = false
		collection.Panel.Visible = not collection.Panel.Visible
	end)
)
table.insert(
	connections,
	results.Styles.Activated:Connect(function()
		scores.Panel.Visible = false
		collection.Panel.Visible = true
	end)
)
table.insert(
	connections,
	results.Replay.Activated:Connect(function()
		root.Action:FireServer("again")
	end)
)
table.insert(
	connections,
	results.Tab.Activated:Connect(function()
		results.showStage = not results.showStage
	end)
)
table.insert(
	connections,
	ui.Scores.Activated:Connect(function()
		collection.Panel.Visible = false
		Scores.toggle(scores)
	end)
)
local previousWarning = false
local previousRemaining = nil
local previousOpen = nil
local function render()
	if not state then
		return
	end
	displayedTarget = currentTarget()
	local display = table.clone(state)
	display.target = displayedTarget
	local center = if player.Character
		then player.Character:FindFirstChild("HumanoidRootPart")
		else nil
	display.inBase = center ~= nil and center.Position.Z <= 0
	local item = if displayedTarget then Catalog.items(state.stage)[displayedTarget] else nil
	display.tooHeavy = state.tooHeavy and displayedTarget == state.target
	if item then
		display.targetName = if item.special then "MYSTERY" else item.name
		display.targetInfo = if item.special
			then "Weight ? | Value ?"
			else "Weight " .. item.weight .. " | Value " .. item.value
	end
	Hud.update(ui, display, UserInputService.TouchEnabled)
	Styles.update(collection, display)
	Results.update(results, state, tostring(player.UserId))
	Scores.update(scores, state, tostring(player.UserId))
	results.Panel.Visible = results.Panel.Visible and not collection.Panel.Visible
	local world = workspace:FindFirstChild("GrabItWorld")
	local items = if world and world:GetAttribute("Stage") == state.stage
		then world:FindFirstChild("Items")
		else nil
	TargetPrompt.update(targetPrompt, display, items, UserInputService.TouchEnabled)
	local camera = workspace.CurrentCamera
	if camera then
		local inset = GuiService:GetGuiInset()
		local head = if player.Character then player.Character:FindFirstChild("Head") else nil
		TargetPrompt.place(targetPrompt, camera, {
			left = 0,
			right = camera.ViewportSize.X,
			top = inset.Y + ui.StagePath.AbsolutePosition.Y + ui.StagePath.AbsoluteSize.Y,
			bottom = inset.Y + (if ui.Tutorial.Visible
				then ui.Tutorial.AbsolutePosition.Y
				else ui.Bag.AbsolutePosition.Y),
			headX = if head
				then camera:WorldToViewportPoint(head.Position).X
				else camera.ViewportSize.X / 2,
		})
	end
	if items then
		if visibilityFolder ~= items then
			if visibilityConnection then
				visibilityConnection:Disconnect()
			end
			visibilityFolder = items
			visibilityDirty = true
			visibilityConnection = items.DescendantAdded:Connect(function()
				visibilityDirty = true
			end)
		end
		local mask = 0
		for id, value in state.collected do
			if value then
				mask += 2 ^ id
			end
		end
		if visibilityDirty or visibilityMask ~= mask or visibilityRound ~= state.roundId then
			for _, part in items:GetChildren() do
				if part:IsA("BasePart") then
					ItemVisibility.set(part, state.collected[part:GetAttribute("ItemId")] == true)
				end
			end
			visibilityMask = mask
			visibilityRound = state.roundId
			visibilityDirty = false
		end
	end
	local boardPart = if world then world:FindFirstChild("LiveResults") else nil
	if boardPart and (not board or board.Gui.Adornee ~= boardPart) then
		if board then
			board.Gui:Destroy()
		end
		board = Results.board(ui.Screen.Parent, boardPart)
	end
	if board then
		Results.fill(board, state.rows or {}, tostring(player.UserId), false)
	end
end
local renderElapsed = 0
table.insert(
	connections,
	RunService.Heartbeat:Connect(function(dt)
		renderElapsed += dt
		if renderElapsed >= 0.1 then
			renderElapsed = 0
			render()
		end
	end)
)
table.insert(
	connections,
	root.State.OnClientEvent:Connect(function(nextState)
		nextState.collected = Wire.unpackCollected(nextState.collected)
		state = nextState
		if state.warning and not previousWarning then
			message("Return to base", 3)
			play("warning")
		end
		if state.open and previousOpen == false then
			message("Warehouse open", 2)
			play("open")
		end
		previousWarning = state.warning
		previousOpen = state.open
		if
			state.open
			and state.remaining <= 5
			and previousRemaining
			and state.remaining < previousRemaining
		then
			play("warning")
		end
		previousRemaining = state.remaining
		render()
	end)
)
table.insert(connections, UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(render))
ui.Coins.Text = "Loading progress"
ui.Tutorial.Text = "Connecting to warehouse"
ui.Round.Text = "GRAB IT & RUN"
ui.Style.Text = ""
ui.Bag.Text = "Weight 0 / 10"
root.Action:FireServer("ready")
table.insert(
	connections,
	script.Destroying:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, sound in sounds do
			sound:Destroy()
		end
		if visibilityConnection then
			visibilityConnection:Disconnect()
		end
		Styles.destroy(collection)
		Scores.destroy(scores)
		if board then
			board.Gui:Destroy()
		end
		ui.Screen:Destroy()
		targetPrompt.Gui:Destroy()
	end)
)
