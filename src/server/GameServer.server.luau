--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local root = game:GetService("ReplicatedStorage"):WaitForChild("GrabIt")
local Rules = require(root.Shared.GameRules)
local View = require(root.Shared.Presentation)
local Wire = require(root.Shared.NetworkState)
local Session = require(root.Shared.Session)
local Persistence = require(root.Shared.Persistence)
local World = require(script.Parent.GrabItModules.World)
local Appearance = require(script.Parent.GrabItModules.Appearance)
local world = World.build()
local start = workspace:GetServerTimeNow()
local session = Session.new(function()
	return workspace:GetServerTimeNow() - start
end)
local studio = RunService:IsStudio()
local memory = {}
local dataStore = if not studio then DataStoreService:GetDataStore("GrabItV1_PlayerData") else nil
local function update(key, transform)
	if studio then
		local result = transform(memory[key])
		if result then
			memory[key] = result
		end
		return result
	end
	return dataStore:UpdateAsync(key, function(old)
		local result = transform(old)
		if result then
			return result, { tonumber(string.sub(key, 6)) }
		end
		return nil
	end)
end
local entries = {}
local stopping = false
local function notice(player, text, kind)
	root.Notice:FireClient(player, text, kind)
end
local function resetPosition(entry, character)
	local destination = CFrame.new(0, 4, -18) * CFrame.Angles(0, math.pi, 0)
	character:PivotTo(destination)
	entry.lastPosition = destination.Position
	entry.budget = 6
	entry.lastMovement = os.clock()
end
local function movement(entry, position)
	local now = os.clock()
	local p = session:get(entry.sessionId)
	entry.budget =
		math.min(6, entry.budget + (now - entry.lastMovement) * (if p then Rules.speed(p) else 16))
	entry.lastMovement = now
	local traveled = (position - entry.lastPosition).Magnitude
	if traveled > entry.budget + 1 or position.Y ~= position.Y then
		return false
	end
	entry.budget = math.max(0, entry.budget - traveled)
	entry.lastPosition = position
	return true
end
local function appearance(player)
	local entry = entries[player]
	local p = if entry then session:get(entry.sessionId) else nil
	local character = player.Character
	if p and character then
		Appearance.update(character, p)
	end
end
local function send(player, entry)
	if not player.Parent then
		return
	end
	local p = session:get(entry.sessionId)
	local round = Rules.round(workspace:GetServerTimeNow() - start)
	local character = player.Character
	local center = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local collected = if p and p.roundId == round.id then p.collected else {}
	local target = if p
			and center
			and round.open
			and View.inWarehouse(center.Position.X, center.Position.Y, center.Position.Z)
		then View.nearest(
			Rules.items,
			collected,
			round.id,
			center.Position.X,
			center.Position.Y,
			center.Position.Z
		)
		else nil
	local save = entry.status
	if p and entry.dirtyAt then
		save = if os.clock() - entry.dirtyAt >= 10
			then "Not saved yet. Rejoining may lose recent progress."
			else "Saving"
	end
	if studio and p and not entry.dirtyAt then
		save = "Studio session only"
	end
	local state = {
		coins = if p then p.coins else 0,
		cargoCount = if p then #p.cargo else 0,
		cargoValue = if p then Rules.value(p) else 0,
		open = round.open,
		remaining = round.remaining,
		warning = round.warning,
		roundId = round.id,
		target = target,
		ready = p ~= nil,
		save = save,
		tutorial = if p then p.tutorial else false,
		collected = Wire.packCollected(collected),
	}
	local signature = HttpService:JSONEncode(state)
	if signature ~= entry.lastState then
		entry.lastState = signature
		root.State:FireClient(player, state)
	end
end
local function save(entry, release)
	if not session:get(entry.sessionId) or entry.saving then
		return false
	end
	entry.saving = true
	local p = session:get(entry.sessionId)
	local coins, tutorial = p.coins, p.tutorial
	local ok = if release
		then entry.store:release(entry.key, coins, tutorial)
		else entry.store:save(entry.key, coins, tutorial)
	entry.saving = false
	if ok then
		entry.lastSaved = os.clock()
		if p.coins == coins then
			entry.dirtyAt = nil
			entry.status = "Saved"
		end
	end
	return ok
end
local collision = game:GetService("PhysicsService")
-- Compatibility with the locally verified Studio build; prefer workspace-scoped APIs when available.
local workspaceGroups = pcall(function()
	workspace:RegisterCollisionGroup("GrabItPlayers")
	workspace:CollisionGroupSetCollidable("GrabItPlayers", "GrabItPlayers", false)
end)
if not workspaceGroups then
	if not collision:IsCollisionGroupRegistered("GrabItPlayers") then
		collision:RegisterCollisionGroup("GrabItPlayers")
	end
	collision:CollisionGroupSetCollidable("GrabItPlayers", "GrabItPlayers", false)
end
local function characterAdded(player, entry, character)
	if entry.characterConnection then
		entry.characterConnection:Disconnect()
	end
	local function setup(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "GrabItPlayers"
		end
	end
	for _, part in character:GetDescendants() do
		setup(part)
	end
	entry.characterConnection = character.DescendantAdded:Connect(setup)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local center = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoid or not center or entries[player] ~= entry then
		return
	end
	local p = session:get(entry.sessionId)
	if p then
		Rules.lose(p)
	end
	if entry.deathConnection then
		entry.deathConnection:Disconnect()
	end
	entry.deathConnection = humanoid.Died:Connect(function()
		local current = session:get(entry.sessionId)
		if current then
			Rules.lose(current)
			appearance(player)
		end
	end)
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoJumpEnabled = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	resetPosition(entry, character)
	appearance(player)
end
local function joined(player)
	if entries[player] then
		return
	end
	local entry = {
		key = "User_" .. player.UserId,
		sessionId = HttpService:GenerateGUID(false),
		store = Persistence.new(update, HttpService:GenerateGUID(false), os.time),
		status = "Loading progress",
		lastSaved = os.clock(),
		lastRequest = 0,
		lastMovement = os.clock(),
		lastPosition = Vector3.new(0, 4, -18),
		budget = 6,
		connections = {},
	}
	entries[player] = entry
	table.insert(
		entry.connections,
		player.CharacterAdded:Connect(function(character)
			task.spawn(characterAdded, player, entry, character)
		end)
	)
	if player.Character then
		task.spawn(characterAdded, player, entry, player.Character)
	end
	task.spawn(function()
		local deadline = os.clock() + 15
		repeat
			local data = entry.store:load(entry.key)
			if data then
				if entries[player] ~= entry or stopping then
					entry.store:release(entry.key, data.coins, data.tutorial)
					return
				end
				session:add(entry.sessionId, data.coins, data.tutorial)
				entry.status = "Saved"
				appearance(player)
				send(player, entry)
				return
			end
			if entries[player] ~= entry or stopping then
				return
			end
			task.wait(1)
		until os.clock() >= deadline
		entry.status = "Progress unavailable. Rejoin to retry"
		send(player, entry)
	end)
end
root.Action.OnServerEvent:Connect(function(player, action, itemId)
	local entry = entries[player]
	if not entry or os.clock() - entry.lastRequest < 0.12 then
		return
	end
	entry.lastRequest = os.clock()
	if action == "ready" then
		entry.lastState = nil
		send(player, entry)
		return
	end
	if
		action ~= "collect"
		or type(itemId) ~= "number"
		or itemId % 1 ~= 0
		or not Rules.items[itemId]
	then
		return
	end
	local p = session:get(entry.sessionId)
	local character = player.Character
	local center = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if
		not p
		or not center
		or not humanoid
		or humanoid.Health <= 0
		or not movement(entry, center.Position)
	then
		return
	end
	local params = RaycastParams.new()
	params.CollisionGroup = "GrabItPlayers"
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, world.Items }
	local point = Vector3.new(Rules.items[itemId].x, 2.5, Rules.items[itemId].z)
	if workspace:Raycast(center.Position, point - center.Position, params) then
		return
	end
	if
		session:collect(
			entry.sessionId,
			itemId,
			center.Position.X,
			center.Position.Y,
			center.Position.Z
		)
	then
		humanoid.WalkSpeed = Rules.speed(p)
		appearance(player)
		notice(player, "Collected +" .. Rules.items[itemId].value, "collect")
		send(player, entry)
	end
end)
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
	local entry = entries[player]
	if not entry then
		return
	end
	entries[player] = nil
	for _, connection in entry.connections do
		connection:Disconnect()
	end
	if entry.characterConnection then
		entry.characterConnection:Disconnect()
	end
	if entry.deathConnection then
		entry.deathConnection:Disconnect()
	end
	task.spawn(function()
		local deadline = os.clock() + 20
		repeat
			if not entry.saving and save(entry, true) then
				break
			end
			task.wait(1)
		until os.clock() >= deadline
		session:remove(entry.sessionId)
	end)
end)
for _, player in Players:GetPlayers() do
	joined(player)
end
local previousOpen = nil
local accumulated = 0
RunService.Heartbeat:Connect(function(dt)
	accumulated += dt
	if accumulated < 0.1 then
		return
	end
	accumulated = 0
	local round = Rules.round(workspace:GetServerTimeNow() - start)
	if previousOpen ~= round.open then
		World.setOpen(world, round.open)
		previousOpen = round.open
	end
	for player, entry in entries do
		local p = session:get(entry.sessionId)
		local character = player.Character
		local center = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		if center and humanoid then
			if not p then
				center.Anchored = true
			else
				center.Anchored = false
				humanoid.WalkSpeed = Rules.speed(p)
				if not movement(entry, center.Position) then
					character:PivotTo(CFrame.new(entry.lastPosition))
				end
				local pos = center.Position
				local previousTier = View.style(p.coins).tier
				local event = session:step(entry.sessionId, pos.X, pos.Y, pos.Z)
				if
					event.returnHome
					or math.abs(pos.X) > 26
					or pos.Z > 122
					or pos.Z < -26
					or pos.Y < 0
					or pos.Y > 22
				then
					resetPosition(entry, character)
				end
				if event.lost then
					appearance(player)
					notice(player, "Cargo lost. Banked coins kept", "lost")
				end
				if event.banked > 0 then
					entry.dirtyAt = entry.dirtyAt or os.clock()
					appearance(player)
					notice(player, "Banked +" .. event.banked, "bank")
					local style = View.style(p.coins)
					if style.tier > previousTier then
						notice(player, "Style unlocked: " .. style.name, "style")
					end
				end
				if
					not entry.saving
					and (
						(entry.dirtyAt and os.clock() - entry.lastSaved >= 5)
						or os.clock() - entry.lastSaved >= 30
					)
				then
					task.spawn(save, entry, false)
				end
			end
		end
		send(player, entry)
	end
end)
game:BindToClose(function()
	stopping = true
	local pending = 0
	for _, entry in entries do
		pending += 1
		task.spawn(function()
			local deadline = os.clock() + 24
			repeat
				if not entry.saving and save(entry, true) then
					break
				end
				task.wait(0.5)
			until os.clock() >= deadline
			pending -= 1
		end)
	end
	local deadline = os.clock() + 25
	while pending > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)
print(
	"GrabIt V1 server ready; persistence:",
	if studio then "isolated Studio memory" else "DataStore"
)
