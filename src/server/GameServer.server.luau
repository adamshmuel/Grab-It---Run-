--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local root = game:GetService("ReplicatedStorage"):WaitForChild("GrabIt")
local Rules = require(root.Shared.GameRules)
local Catalog = require(root.Shared.Catalog)
local Cosmetics = require(root.Shared.Cosmetics)
local View = require(root.Shared.Presentation)
local Wire = require(root.Shared.NetworkState)
local Session = require(root.Shared.Session)
local Persistence = require(root.Shared.Persistence)
local Profile = require(root.Shared.Profile)
local LoadProgress = require(root.Shared.LoadProgress)
local World = require(script.Parent.GrabItModules.World)
local Appearance = require(script.Parent.GrabItModules.Appearance)
local StorageMode = require(script.Parent.GrabItModules.StorageMode)
local session = Session.new(function()
	return workspace:GetServerTimeNow()
end)
local world = World.build()
local studio = RunService:IsStudio()
local storage = StorageMode.select(
	studio,
	if studio then game:GetService("ServerStorage"):GetAttribute("GrabItQACloudRun") else nil
)
local dataStore = if storage.memory
	then nil
	else DataStoreService:GetDataStore(assert(storage.name, "Store name missing"), "global")
local memory = {}
local function update(key, transform)
	if storage.memory then
		local value = transform(memory[key])
		if value then
			memory[key] = value
		end
		return value
	end
	assert(dataStore, "Store missing")
	return dataStore:UpdateAsync(key, function(old)
		local value = transform(old)
		if value and not studio then
			return value, { tonumber(string.sub(key, 6)) }
		end
		return value
	end)
end
local entries = {}
local stopping = false
local snapshot = Profile.capture
local function notice(player, text: string, kind: string): ()
	if player.Parent then
		root.Notice:FireClient(player, text, kind)
	end
end
local function resetPosition(entry, character: Model): ()
	local destination = CFrame.new(0, 4, -18) * CFrame.Angles(0, math.pi, 0)
	character:PivotTo(destination)
	entry.lastPosition = destination.Position
	entry.budget = 6
	entry.lastMovement = os.clock()
end
local function movement(entry, position: Vector3): boolean
	if
		position.X ~= position.X
		or position.Y ~= position.Y
		or position.Z ~= position.Z
		or position.Magnitude == math.huge
	then
		return false
	end
	local now = os.clock()
	local p = entry.p
	entry.budget =
		math.min(6, entry.budget + (now - entry.lastMovement) * (if p then Rules.speed(p) else 16))
	entry.lastMovement = now
	local distance = (position - entry.lastPosition).Magnitude
	if distance > entry.budget + 1 then
		return false
	end
	entry.budget = math.max(0, entry.budget - distance)
	entry.lastPosition = position
	return true
end
local function appearance(player, entry): ()
	if entry.p and player.Character then
		Appearance.update(player.Character, entry.p)
	end
end
local function dirty(entry): ()
	entry.dirtyAt = entry.dirtyAt or os.clock()
end
local function save(entry, release: boolean): boolean
	if not entry.p or entry.saving or entry.pending then
		return false
	end
	entry.saving = true
	local data = snapshot(entry.p)
	local ok = if release
		then entry.store:releaseProfile(entry.key, data)
		else entry.store:saveProfile(entry.key, data)
	entry.saving = false
	entry.nextSaveAt = os.clock() + 5
	if ok then
		entry.lastSaved = os.clock()
		if entry.p.revision == data.revision then
			entry.dirtyAt = nil
			entry.status = "Saved"
		end
	end
	return ok
end
local function purchase(player, entry, id: string): ()
	if entry.pending or entry.p.owned[id] then
		return
	end
	local style = Cosmetics.get(id)
	if not style or entry.p.coins < style.price then
		notice(player, "Not enough Coins", "warning")
		return
	end
	local pending =
		{ id = HttpService:GenerateGUID(false), style = id, started = os.clock(), snapshot = nil }
	entry.pending = pending
	task.spawn(function()
		local delaySeconds = 1
		while entry.pending == pending do
			if entry.saving then
				task.wait(0.2)
				continue
			end
			if not pending.snapshot then
				pending.snapshot = snapshot(entry.p)
			end
			entry.saving = true
			local status, confirmed =
				entry.store:purchase(entry.key, id, pending.snapshot, pending.id)
			entry.saving = false
			if status == "confirmed" then
				local p = entry.p
				if Profile.confirmPurchase(p, pending.snapshot, confirmed) then
					dirty(entry)
				else
					entry.dirtyAt = nil
					entry.status = "Saved"
				end
				entry.pending = nil
				entry.lastSaved = os.clock()
				entry.nextSaveAt = os.clock() + 5
				appearance(player, entry)
				notice(player, "Purchased " .. style.name, "style")
				return
			elseif status ~= "pending" then
				entry.pending = nil
				notice(player, "Purchase unavailable. Try again", "warning")
				return
			end
			-- An error may follow a committed write. Retry the same transaction, never a new debit.
			if stopping and os.clock() - pending.started > 24 then
				return
			end
			if not player.Parent and os.clock() - pending.started > 20 then
				return
			end
			task.wait(delaySeconds)
			delaySeconds = math.min(4, delaySeconds * 2)
		end
	end)
end
local function send(player, entry, r, rows): ()
	if not player.Parent then
		return
	end
	local p = entry.p
	local center = if player.Character
		then player.Character:FindFirstChild("HumanoidRootPart")
		else nil
	local collected = if p then p.collected else {}
	local items = Catalog.items(r.stage)
	local target = if p
			and center
			and r.open
			and View.inWarehouse(center.Position.X, center.Position.Y, center.Position.Z)
		then View.nearest(
			items,
			collected,
			r.id,
			center.Position.X,
			center.Position.Y,
			center.Position.Z
		)
		else nil
	local display = if p then Rules.cargoDisplay(p) else { weight = "0", value = "0" }
	local saveStatus = entry.status
	if p and entry.dirtyAt then
		saveStatus = if os.clock() - entry.dirtyAt >= 10
			then "Not saved yet. Rejoining may lose recent progress."
			else "Saving"
	end
	if storage.memory and p and not entry.dirtyAt then
		saveStatus = "Studio session only"
	end
	local pending = entry.pending
	local purchaseStatus = if pending
		then (if os.clock() - pending.started >= 10
			then "Purchase pending. Rejoining may delay confirmation."
			else "Purchase pending")
		else ""
	local state = {
		coins = if p then p.coins else 0,
		cargoCount = if p then #p.cargo else 0,
		cargoWeight = display.weight,
		cargoValue = display.value,
		capacity = Catalog.stages[r.stage].capacity,
		stage = r.stage,
		stageName = Catalog.stages[r.stage].name,
		totalItems = #items,
		bankedCount = if p then p.bankedCount else 0,
		open = r.open,
		phase = r.phase,
		mode = r.mode,
		remaining = r.remaining,
		warning = r.warning,
		roundId = r.id,
		target = target,
		ready = p ~= nil,
		save = saveStatus,
		tutorial = if p then p.tutorial else false,
		collected = Wire.packCollected(collected),
		tooHeavy = p ~= nil
			and target ~= nil
			and Rules.weight(p) + items[target].weight > Catalog.stages[r.stage].capacity,
		inBase = center ~= nil and center.Position.Z <= 0,
		canNext = r.canNext and p ~= nil,
		owned = if p then p.owned else { basic = true },
		selected = if p then p.selected else "basic",
		purchase = purchaseStatus,
		rows = rows,
		matchRows = if r.phase == "summary" then session.matchResults else {},
		personal = {
			earnings = if p then p.runEarnings else 0,
			stages = if p then p.stageEarnings else { 0, 0, 0 },
		},
	}
	local signature = HttpService:JSONEncode(state)
	if signature ~= entry.lastState then
		entry.lastState = signature
		root.State:FireClient(player, state)
	end
end
local collision = game:GetService("PhysicsService")
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
local function characterAdded(player, entry, character: Model): ()
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
	if entry.p then
		Rules.lose(entry.p)
	end
	if entry.deathConnection then
		entry.deathConnection:Disconnect()
	end
	entry.deathConnection = humanoid.Died:Connect(function()
		if entry.p then
			local hadCargo = #entry.p.cargo > 0
			Rules.lose(entry.p)
			appearance(player, entry)
			if hadCargo then
				notice(player, "Cargo lost. Banked coins kept", "lost")
			end
		end
	end)
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoJumpEnabled = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	resetPosition(entry, character)
	appearance(player, entry)
end
local function joined(player): ()
	if entries[player] then
		return
	end
	local entry = {
		key = storage.keyPrefix .. "User_" .. player.UserId,
		sessionId = tostring(player.UserId),
		store = Persistence.new(update, HttpService:GenerateGUID(false), os.time),
		status = "Loading progress",
		lastSaved = os.clock(),
		nextSaveAt = os.clock() + 5,
		lastRequest = 0,
		lastMovement = os.clock(),
		lastPosition = Vector3.new(0, 4, -18),
		budget = 6,
		connections = {},
	}
	entry.loadDeadline = os.clock() + 15
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
		local deadline = entry.loadDeadline
		repeat
			local data, loading = LoadProgress.attempt(entry.store, entry.key, deadline, os.clock)
			if loading == "expired" then
				break
			end
			if data then
				if entries[player] ~= entry or stopping then
					entry.store:releaseProfile(entry.key, data)
					return
				end
				local p =
					session:add(entry.sessionId, data.coins, data.tutorial, player.DisplayName)
				p.owned = table.clone(data.owned)
				p.selected = data.selected
				p.revision = data.revision
				entry.p = p
				entry.status = "Saved"
				appearance(player, entry)
				return
			end
			if entries[player] ~= entry or stopping then
				return
			end
			task.wait(1)
		until os.clock() >= deadline
		entry.status = "Progress unavailable. Rejoin to retry"
	end)
end
root.Action.OnServerEvent:Connect(function(player, action, arg)
	local entry = entries[player]
	if not entry or type(action) ~= "string" or os.clock() - entry.lastRequest < 0.12 then
		return
	end
	entry.lastRequest = os.clock()
	if action == "ready" then
		entry.lastState = nil
		return
	end
	local p = entry.p
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
	session:tick()
	local r = session:state()
	if action == "next" then
		session:advance(entry.sessionId)
		return
	end
	if action == "again" then
		session:playAgain(entry.sessionId)
		return
	end
	if action == "buy" or action == "equip" then
		if
			type(arg) ~= "string"
			or #arg > 16
			or not Cosmetics.get(arg)
			or (r.open and not (center.Position.Z <= 0 and math.abs(center.Position.X) <= 24))
		then
			return
		end
		if action == "buy" then
			purchase(player, entry, arg)
		elseif Cosmetics.equip(p, arg) then
			dirty(entry)
			appearance(player, entry)
		end
		return
	end
	local items = Catalog.items(r.stage)
	if
		action ~= "collect"
		or type(arg) ~= "number"
		or arg % 1 ~= 0
		or not items[arg]
		or not r.open
	then
		return
	end
	local item = items[arg]
	local params = RaycastParams.new()
	params.CollisionGroup = "GrabItPlayers"
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, world.Items }
	local point = Vector3.new(item.x, 2.5, item.z)
	if workspace:Raycast(center.Position, point - center.Position, params) then
		return
	end
	if
		session:collect(
			entry.sessionId,
			arg,
			center.Position.X,
			center.Position.Y,
			center.Position.Z
		)
	then
		humanoid.WalkSpeed = Rules.speed(p)
		appearance(player, entry)
		notice(player, "Collected", "collect")
	elseif Rules.weight(p) + item.weight > Catalog.stages[p.stage].capacity then
		notice(player, "Too heavy", "warning")
	end
end)
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
	local entry = entries[player]
	if not entry then
		return
	end
	entries[player] = nil
	session:remove(entry.sessionId)
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
		local deadline = os.clock() + 24
		repeat
			if not entry.saving and not entry.pending and save(entry, true) then
				return
			end
			task.wait(1)
		until os.clock() >= deadline
	end)
end)
for _, player in Players:GetPlayers() do
	joined(player)
end
local accumulated = 0
local previousStage = 1
RunService.Heartbeat:Connect(function(dt)
	accumulated += dt
	if accumulated < 0.1 then
		return
	end
	accumulated = 0
	session:tick()
	local r = session:state()
	if r.stage ~= previousStage then
		World.setStage(world, r.stage)
		previousStage = r.stage
	end
	World.setOpen(world, r.open)
	for player, entry in entries do
		if not entry.p and os.clock() >= entry.loadDeadline then
			entry.status = "Progress unavailable. Rejoin to retry"
		end
		local p = entry.p
		if p and p.pendingLoss then
			notice(player, "Cargo lost. Banked coins kept", "lost")
			p.pendingLoss = false
		end
		local character = player.Character
		local center = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		if center and humanoid then
			if entry.generation ~= r.generation then
				resetPosition(entry, character)
				entry.generation = r.generation
				appearance(player, entry)
			end
			center.Anchored = not p or not r.open
			if p and r.open and humanoid.Health > 0 then
				humanoid.WalkSpeed = Rules.speed(p)
				if not movement(entry, center.Position) then
					character:PivotTo(CFrame.new(entry.lastPosition))
				end
				local pos = center.Position
				if
					math.abs(pos.X) > 26
					or pos.Z > 122
					or pos.Z < -26
					or pos.Y < 0
					or pos.Y > 22
				then
					local had = #p.cargo > 0
					Rules.lose(p)
					resetPosition(entry, character)
					appearance(player, entry)
					if had then
						notice(player, "Cargo lost. Banked coins kept", "lost")
					end
				else
					local event = session:step(entry.sessionId, pos.X, pos.Y, pos.Z)
					if event.banked > 0 then
						dirty(entry)
						appearance(player, entry)
						notice(
							player,
							"Banked +"
								.. event.banked
								.. (
									if event.special > 0
										then " | Golden Reactor +" .. event.special
										else ""
								),
							"bank"
						)
					end
				end
			end
		end
		if
			p
			and not entry.saving
			and not entry.pending
			and os.clock() >= entry.nextSaveAt
			and (entry.dirtyAt or os.clock() - entry.lastSaved >= 30)
		then
			task.spawn(save, entry, false)
		end
	end
	session:tick()
	r = session:state()
	local rows = session:rows()
	for player, entry in entries do
		send(player, entry, r, rows)
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
				if not entry.saving and not entry.pending and save(entry, true) then
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
	"GrabIt V1 improvements server ready; persistence:",
	if storage.memory
		then "isolated Studio memory"
		elseif studio then "isolated QA store"
		else "DataStore"
)
