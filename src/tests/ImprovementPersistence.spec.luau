--!strict
return function(): number
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
	local ok, result = pcall(function()
		local P = require(shared.Persistence)
		local records = {}
		local now = 10
		local drop = false
		local broken = false
		local function update(key, transform)
			if broken then
				error("outage")
			end
			local value = transform(records[key])
			if value then
				records[key] = value
			end
			if drop then
				drop = false
				error("response lost AFTER commit")
			end
			return value
		end
		local a = P.new(update, "a", function()
			return now
		end)
		local b = P.new(update, "b", function()
			return now
		end)
		local fresh = a:load("new")
		assert(
			fresh and fresh.version == 2 and fresh.owned.basic and fresh.selected == "basic",
			"RED: versioned cosmetic record missing"
		)
		assert(b:load("new") == nil, 'ImprovementPersistence.spec: b:load("new") == nil')
		for _, coins in { 0, 29, 30, 99, 100, 299, 300 } do
			local key = "legacy" .. coins
			records[key] = { version = 1, coins = coins, tutorial = true }
			local d = a:load(key)
			assert(
				d and d.coins == coins and d.tutorial,
				"ImprovementPersistence.spec: d and d.coins == coins and d.tutorial"
			)
			assert(
				(d.owned.canvas == true) == (coins >= 30),
				"ImprovementPersistence.spec: (d.owned.canvas == true) == (coins >= 30)"
			)
			assert(
				(d.owned.field == true) == (coins >= 100),
				"ImprovementPersistence.spec: (d.owned.field == true) == (coins >= 100)"
			)
			assert(
				(d.owned.royal == true) == (coins >= 300),
				"ImprovementPersistence.spec: (d.owned.royal == true) == (coins >= 300)"
			)
		end
		assert(
			a:saveProfile("new", {
				coins = 120,
				tutorial = true,
				owned = { basic = true },
				selected = "basic",
				revision = 1,
			}),
			'ImprovementPersistence.spec: a:saveProfile( "new", { coins = 120, tutorial = true, owned = { basic = true }, selected = "basic", '
		)
		local snapshot = {
			coins = 120,
			tutorial = true,
			owned = { basic = true },
			selected = "basic",
			revision = 1,
		}
		drop = true
		local status = a:purchase("new", "canvas", snapshot, "purchase-1")
		assert(
			status == "pending" and records.new.coins == 20 and records.new.owned.canvas,
			'ImprovementPersistence.spec: status == "pending" and records.new.coins == 20 and records.new.owned.canvas'
		)
		local status2, confirmed = a:purchase("new", "canvas", snapshot, "purchase-1")
		assert(
			status2 == "confirmed" and confirmed.coins == 20,
			'ImprovementPersistence.spec: status2 == "confirmed" and confirmed.coins == 20'
		)
		assert(
			a:saveProfile("new", {
				coins = 40,
				tutorial = true,
				owned = { basic = true, canvas = true },
				selected = "canvas",
				revision = 3,
			}),
			'ImprovementPersistence.spec: a:saveProfile("new", { coins = 40, tutorial = true, owned = { basic = true, canvas = true }, selecte'
		)
		assert(
			not a:saveProfile("new", snapshot) and records.new.coins == 40,
			"stale pre-purchase snapshot cannot restore balance"
		)
		local again = a:purchase("new", "canvas", {
			coins = 40,
			tutorial = true,
			owned = { basic = true, canvas = true },
			selected = "canvas",
			revision = 3,
		}, "purchase-2")
		assert(
			again == "owned" and records.new.coins == 40,
			'ImprovementPersistence.spec: again == "owned" and records.new.coins == 40'
		)
		assert(
			a:purchase("new", "royal", {
				coins = 40,
				tutorial = true,
				owned = { basic = true, canvas = true },
				selected = "canvas",
				revision = 3,
			}, "purchase-3") == "insufficient",
			'ImprovementPersistence.spec: a:purchase("new", "royal", { coins = 40, tutorial = true, owned = { basic = true, canvas = true }, s'
		)
		broken = true
		assert(
			a:load("missing") == nil and records.missing == nil,
			'ImprovementPersistence.spec: a:load("missing") == nil and records.missing == nil'
		)
		broken = false
		assert(
			a:releaseProfile("new", {
				coins = 40,
				tutorial = true,
				owned = { basic = true, canvas = true },
				selected = "canvas",
				revision = 3,
			}),
			'ImprovementPersistence.spec: a:releaseProfile("new", { coins = 40, tutorial = true, owned = { basic = true, canvas = true }, sele'
		)
		local restored = b:load("new")
		assert(
			restored.coins == 40 and restored.selected == "canvas" and restored.owned.canvas,
			'ImprovementPersistence.spec: restored.coins == 40 and restored.selected == "canvas" and restored.owned.canvas'
		)
		assert(
			not a:saveProfile("new", snapshot),
			'ImprovementPersistence.spec: not a:saveProfile("new", snapshot)'
		)
		records.lease = { version = 1, coins = 120, tutorial = false }
		local lease = a:load("lease")
		drop = true
		assert(
			a:purchase("lease", "canvas", lease, "unknown-lease") == "pending",
			"response dropped after committed purchase"
		)
		now += 121
		assert(b:load("lease"), "new session after lease expiry")
		assert(
			a:purchase("lease", "canvas", lease, "unknown-lease") == "pending",
			"lost lease cannot prove an unknown purchase failed"
		)
		records.infinite =
			{ version = 1, coins = 1, tutorial = false, owner = "bad", expires = math.huge }
		assert(a:load("infinite") == nil, "non-finite lease fails closed")
		local profileModule = shared:FindFirstChild("Profile")
		assert(profileModule, "RED: concurrent purchase reconciliation must be testable")
		local Profile = require(profileModule)
		local player = {
			coins = 120,
			tutorial = true,
			owned = { basic = true },
			selected = "basic",
			revision = 1,
			stageScore = 50,
			runEarnings = 80,
		}
		local before = Profile.capture(player)
		player.coins += 20
		player.revision += 1
		player.stageScore += 20
		player.runEarnings += 20
		assert(
			Profile.confirmPurchase(player, before, {
				coins = 20,
				owned = { basic = true, canvas = true },
				selected = "basic",
				tutorial = true,
				revision = 2,
			}),
			"deposit during purchase requires another save"
		)
		assert(
			player.coins == 40
				and player.owned.canvas
				and player.selected == "basic"
				and player.revision == 3,
			"merge debit without losing concurrent deposit or auto-equipping"
		)
		assert(
			player.stageScore == 70 and player.runEarnings == 100,
			"purchase cannot change earned competitive score"
		)
		records.corruptTransaction = {
			version = 2,
			coins = 100,
			tutorial = false,
			owned = { basic = true },
			selected = "basic",
			revision = 0,
			lastTransaction = true,
		}
		assert(a:load("corruptTransaction") == nil, "invalid transaction metadata fails closed")
		return 21
	end)
	shared:Destroy()
	assert(ok, result)
	return result
end
