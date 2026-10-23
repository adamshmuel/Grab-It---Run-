--!strict
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local root = game:GetService("ReplicatedStorage"):WaitForChild("GrabIt", 20)
local channel = game:GetService("ReplicatedStorage"):WaitForChild("GrabItQAChannel", 20)
assert(root and channel, "QA replication timed out")
local View = require(root.Shared.Presentation)
local Wire = require(root.Shared.NetworkState)
local Rules = require(root.Shared.GameRules)
assert(channel:GetAttribute("Marker") == "GrabItV1.AutomatedQA", "wrong QA channel")
local duration = channel:GetAttribute("Duration")
local qualitySettings = UserSettings():GetService("UserGameSettings")
script:SetAttribute("Stage", "loading")
local state = nil
local snapshots = {}
local lastAttempt = nil
local stateConnection = root.State.OnClientEvent:Connect(function(value)
	value.collected = Wire.unpackCollected(value.collected)
	state = value
	table.insert(snapshots, {
		target = value.target,
		cargo = value.cargoCount,
		coins = value.coins,
		round = value.roundId,
		remaining = value.remaining,
		collected = Wire.packCollected(value.collected),
	})
	if #snapshots > 12 then
		table.remove(snapshots, 1)
	end
end)
local frames, slowFrames, seconds = 0, 0, 0
local windowSeconds, windowFrames, sampleCount, slowSamples = 0, 0, 0, 0
local minimumFPS = nil
local sampling = false
local measuring = channel:GetAttribute("MeasureFrames") ~= false
local measurementConnection = channel:GetAttributeChangedSignal("MeasureFrames"):Connect(function()
	measuring = channel:GetAttribute("MeasureFrames") == true
	if measuring then
		frames, slowFrames, seconds = 0, 0, 0
		windowSeconds, windowFrames, sampleCount, slowSamples = 0, 0, 0, 0
		minimumFPS = nil
	end
end)
local frameConnection = RunService.RenderStepped:Connect(function(dt)
	if sampling and measuring and seconds < 600 then
		frames += 1
		seconds += dt
		if dt > 1 / 30 then
			slowFrames += 1
		end
		windowSeconds += dt
		windowFrames += 1
		if windowSeconds >= 1 then
			local fps = windowFrames / windowSeconds
			sampleCount += 1
			if fps < 30 then
				slowSamples += 1
			end
			minimumFPS = math.min(minimumFPS or fps, fps)
			windowSeconds, windowFrames = 0, 0
		end
	end
end)
local function awaitCondition(check, timeout: number, message: string)
	local deadline = os.clock() + timeout
	repeat
		if check() then
			return
		end
		task.wait(0.1)
	until os.clock() >= deadline
	error(message)
end
local function walk(x: number, z: number)
	local character = player.Character
	assert(character, "missing character")
	local center = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	assert(center and humanoid, "missing humanoid")
	local deadline = os.clock() + 18
	repeat
		if (Vector3.new(x, center.Position.Y, z) - center.Position).Magnitude < 2 then
			return
		end
		humanoid:MoveTo(Vector3.new(x, center.Position.Y, z))
		task.wait(0.15)
	until os.clock() >= deadline
	error("walking timed out: " .. x .. "," .. z)
end
local function collect(expected: number, optional: boolean?)
	task.wait(0.25)
	local function target()
		local character = player.Character
		local center = if character then character:FindFirstChild("HumanoidRootPart") else nil
		return if center then View.collectionTarget(Rules.items, state, center.Position) else nil
	end
	if optional and not target() then
		return
	end
	awaitCondition(function()
		return state and target() ~= nil
	end, 3, "no collectible target")
	lastAttempt = {
		target = target(),
		cargo = state.cargoCount,
		coins = state.coins,
		round = state.roundId,
		remaining = state.remaining,
		collected = Wire.packCollected(state.collected),
		position = tostring(player.Character:GetPivot().Position),
	}
	root.Action:FireServer("collect", target())
	awaitCondition(function()
		return state.cargoCount == expected
	end, 4, "collection was not accepted")
end
local leaveConnection = channel.OnClientEvent:Connect(function(action)
	if action == "verify-after-leave" then
		local ui = player.PlayerGui:FindFirstChild("GrabItHUD")
		local coins = if ui then tonumber(string.match(ui.Root.Coins.Text, "%d+")) else nil
		channel:FireServer({
			stage = "after-leave",
			passed = state and coins == state.coins,
			coins = coins,
		})
	end
end)
local ok, result = pcall(function()
	for _ = 1, 30 do
		root.Action:FireServer("ready")
		if state and state.ready then
			break
		end
		task.wait(0.5)
	end
	assert(
		state and state.ready and state.coins == 0 and state.cargoCount == 0,
		"fresh player defaults"
	)
	awaitCondition(function()
		return player.Character
			and player.Character:FindFirstChild("HumanoidRootPart")
			and player.Character:FindFirstChildOfClass("Humanoid")
	end, 15, "character did not finish loading")
	local began = os.clock()
	sampling = true
	script:SetAttribute("Stage", "first-trip")
	walk(0, 8)
	local initialCount = if channel:GetAttribute("LoopSmoke") then 1 else 5
	for index, z in { 12, 18, 24, 30, 36 } do
		if index > initialCount then
			break
		end
		walk(-12, z)
		collect(index)
	end
	assert(state.cargoValue == initialCount, "near objects worth one coin each")
	assert(
		math.abs(player.Character.Humanoid.WalkSpeed - 16 * (1 - initialCount * 0.1)) < 0.01,
		"cargo reduces movement speed"
	)
	script:SetAttribute("Stage", "full-cargo")
	task.wait(8)
	if channel:GetAttribute("CollectionOnly") then
		return { cargo = state.cargoCount, cargoValue = state.cargoValue, collectionOnly = true }
	end
	root.Action:FireServer("collect", 1)
	task.wait(0.4)
	assert(state.cargoCount == initialCount, "repeated item does not duplicate cargo")
	walk(0, 8)
	walk(0, -8)
	awaitCondition(function()
		return state.coins == initialCount and state.cargoCount == 0 and state.tutorial
	end, 4, "first deposit")
	script:SetAttribute("Stage", "first-bank")
	if not channel:GetAttribute("LoopSmoke") then
		walk(0, 8)
		walk(12, 12)
		collect(1)
		script:SetAttribute("Stage", "waiting-for-closure")
		awaitCondition(function()
			return not state.open
		end, 190, "warehouse did not close")
		awaitCondition(function()
			return player.Character.HumanoidRootPart.Position.Z < 0 and state.cargoCount == 0
		end, 4, "closure did not return player and clear cargo")
		assert(state.coins == 5, "closure preserves banked progress")
		script:SetAttribute("Stage", "closed")
		awaitCondition(function()
			return state.open
		end, 25, "next round did not open")
		walk(0, 8)
		walk(-12, 12)
		collect(1)
		walk(0, 8)
		walk(0, -8)
		awaitCondition(function()
			return state.coins == 6 and state.cargoCount == 0
		end, 4, "next round refresh and second deposit")
	end
	script:SetAttribute("Stage", "load-loop")
	local routes = { 18, 24, 30, 36 }
	local route = 0
	while os.clock() - began < duration and (duration < 600 or not measuring or seconds < 600) do
		if state.open and state.remaining > 35 then
			route = route % #routes + 1
			walk(0, 8)
			walk(12, routes[route])
			collect(1, true)
			walk(0, 8)
			walk(0, -8)
			awaitCondition(function()
				return state.cargoCount == 0
			end, 4, "load-loop deposit was not confirmed")
		else
			task.wait(0.5)
		end
	end
	if duration >= 600 then
		assert(measuring and seconds >= 600, "ten-minute measurement window was not completed")
	end
	sampling = false
	return {
		coins = state.coins,
		cargo = state.cargoCount,
		frames = frames,
		slowFrames = slowFrames,
		sampleSeconds = seconds,
		sampleCount = sampleCount,
		slowSamples = slowSamples,
		minimumFPS = minimumFPS,
		viewport = tostring(workspace.CurrentCamera.ViewportSize),
		touch = game:GetService("UserInputService").TouchEnabled,
		quality = tostring(qualitySettings.SavedQualityLevel),
		input = "Humanoid MoveTo and real client RemoteEvent requests",
	}
end)
sampling = false
stateConnection:Disconnect()
frameConnection:Disconnect()
measurementConnection:Disconnect()
script:SetAttribute("Stage", if ok then "completed" else "failed")
script:SetAttribute("Passed", ok)
script:SetAttribute("Result", if ok then "completed" else tostring(result))
channel:FireServer({
	passed = ok,
	result = if ok
		then result
		else {
			error = tostring(result),
			cargo = state and state.cargoCount,
			target = state and state.target,
			position = player.Character and tostring(player.Character:GetPivot().Position),
			lastAttempt = lastAttempt,
			snapshots = snapshots,
		},
})
if not ok or channel:GetAttribute("CollectionOnly") then
	leaveConnection:Disconnect()
end
