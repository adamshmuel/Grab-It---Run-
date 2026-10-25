--!strict
return function(): number
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
	local ok, result = pcall(function()
		local module = shared:FindFirstChild("LoadProgress")
		assert(module, "RED: delayed load needs a fail-closed deadline")
		local Loader = require(module)
		local now = 0
		local releases = 0
		local calls = 0
		local store = {
			load = function(_self, _key)
				calls += 1
				now = 16
				return {
					coins = 20,
					owned = { basic = true },
					selected = "basic",
					revision = 1,
					tutorial = true,
				}
			end,
			releaseProfile = function(_self, _key, data)
				releases += 1
				assert(data.coins == 20, "release loaded record unchanged")
				return true
			end,
		}
		local data, status = Loader.attempt(store, "player", 15, function()
			return now
		end)
		assert(
			data == nil and status == "expired" and releases == 1,
			"late load cannot silently unlock gameplay"
		)
		assert(Loader.attempt(store, "player", 15, function()
			return now
		end) == nil and calls == 1, "no new request after deadline")
		return 2
	end)
	shared:Destroy()
	assert(ok, result)
	return result
end
