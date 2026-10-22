--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local root = game:GetService("ReplicatedStorage"):WaitForChild("GrabIt", 20)
assert(root, "GrabIt content was not replicated")
local Hud = require(root.ClientModules.Hud)
local player = Players.LocalPlayer
local ui = Hud.create()
ui.Screen.Parent = player:WaitForChild("PlayerGui", 20)
player.CameraMinZoomDistance = 8
player.CameraMaxZoomDistance = 20
player.CameraMode = Enum.CameraMode.Classic
local View = require(root.Shared.Presentation)
local RunService = game:GetService("RunService")
local state = nil
local connections = {}
local sounds = {}
local function orientCamera(character)
	local center = character:WaitForChild("HumanoidRootPart", 10)
	if not center then
		return
	end
	RunService.RenderStepped:Wait()
	local camera = workspace.CurrentCamera
	if camera and player.Character == character then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = View.camera(center.Position)
		task.wait(0.1)
		if player.Character == character then
			camera.CameraType = Enum.CameraType.Custom
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
	if state and state.ready and state.open and state.target then
		root.Action:FireServer("collect", state.target)
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
local previousWarning = false
local previousOpen = nil
local function render()
	if not state then
		return
	end
	Hud.update(ui, state, UserInputService.TouchEnabled)
end
table.insert(
	connections,
	root.State.OnClientEvent:Connect(function(nextState)
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
		local world = workspace:FindFirstChild("GrabItWorld")
		local items = if world then world:FindFirstChild("Items") else nil
		if items then
			for _, part in items:GetChildren() do
				if part:IsA("BasePart") then
					local hidden = state.collected[part:GetAttribute("ItemId")] == true
					part.LocalTransparencyModifier = if hidden then 1 else 0
					local label = part:FindFirstChild("ValueLabel")
					if label then
						label.Enabled = not hidden
					end
				end
			end
		end
		render()
	end)
)
table.insert(connections, UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(render))
ui.Coins.Text = "Loading progress"
ui.Tutorial.Text = "Connecting to warehouse"
ui.Round.Text = "GRAB IT & RUN"
ui.Style.Text = ""
ui.Bag.Text = "BAG 0 / 5"
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
		ui.Screen:Destroy()
	end)
)
