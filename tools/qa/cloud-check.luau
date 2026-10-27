--!strict
return function(
	runId: string,
	userId: number,
	coins: number,
	tutorial: boolean,
	locked: boolean,
	owned: { [string]: boolean }?,
	selected: string?
)
	assert(game:GetService("RunService"):IsStudio(), "cloud QA verification is Studio-only")
	assert(
		#runId > 0 and #runId <= 20 and runId:match("^[%w_%-]+$"),
		"valid isolated QA run required"
	)
	local key = "QA_" .. runId .. "_User_" .. userId
	local store = game:GetService("DataStoreService")
		:GetDataStore("GrabItV1_QA_Verification", "global")
	local options = Instance.new("DataStoreGetOptions")
	options.UseCache = false
	local ok, record = pcall(function()
		return store:GetAsync(key, options)
	end)
	options:Destroy()
	assert(ok, record)
	assert(record, "cloud QA record is missing from global scope")
	assert(record.version == 2, "cloud record uses the current schema")
	assert(
		record.coins == coins and record.tutorial == tutorial,
		"cloud progress matches confirmed game state"
	)
	assert((record.owner ~= nil) == locked, "cloud session lock matches lifecycle")
	if owned then
		for id, value in owned do
			assert(record.owned[id] == value, "confirmed ownership survives cloud reload")
		end
		for id in record.owned do
			assert(owned[id] == true, "cloud reload cannot invent ownership")
		end
	end
	if selected then
		assert(record.selected == selected, "selected design survives cloud reload")
	end
	return {
		key = key,
		coins = record.coins,
		tutorial = record.tutorial,
		locked = locked,
		uncached = true,
		owned = record.owned,
		selected = record.selected,
		version = record.version,
	}
end
