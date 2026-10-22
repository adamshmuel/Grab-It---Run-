--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared
	local module = shared:FindFirstChild("Persistence")
	assert(module, "RED: Persistence must exist before progress can be saved")
	local Persistence = require(module :: ModuleScript)
	local records = {}
	local fail = false
	local clock = 100
	local function update(key, transform)
		if fail then
			error("simulated outage")
		end
		local nextValue = transform(records[key])
		if nextValue then
			records[key] = nextValue
		end
		return nextValue
	end
	local a = Persistence.new(update, "A", function()
		return clock
	end)
	local b = Persistence.new(update, "B", function()
		return clock
	end)
	local data = a:load("player")
	assert(data and data.coins == 0, "new player defaults")
	assert(b:load("player") == nil, "active session rejected")
	assert(a:save("player", 7, true), "deposit saved")
	assert(a:save("player", 7, true), "repeated save is idempotent")
	assert(records.player.coins == 7, "repeat cannot duplicate")
	fail = true
	assert(a:load("other") == nil and records.other == nil, "load failure cannot create defaults")
	assert(not a:save("player", 30, true), "failed save must not acknowledge")
	fail = false
	assert(a:release("player", 7, true), "release saves final progress")
	local joined = b:load("player")
	assert(joined and joined.coins == 7 and joined.tutorial, "rejoin restores confirmed progress")
	assert(not a:save("player", 999, true), "old session cannot overwrite")
	clock += 121
	assert(a:load("player"), "expired lease may be acquired")
	assert(not b:save("player", 10, true), "expired old owner cannot overwrite new session")
	records.broken = { version = 1, coins = -1, tutorial = false }
	assert(a:load("broken") == nil and records.broken.coins == -1, "corrupt records fail closed")
	print("PASS persistence locks, outages, rejoin, retries and stale sessions")
	return 12
end
