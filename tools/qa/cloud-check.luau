--!strict
return function(runId: string, userId: number, coins: number, tutorial: boolean, locked: boolean)
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
	local record = store:GetAsync(key, options)
	assert(record, "cloud QA record is missing from global scope")
	assert(record.version == 1, "cloud record uses the current schema")
	assert(
		record.coins == coins and record.tutorial == tutorial,
		"cloud progress matches confirmed game state"
	)
	assert((record.owner ~= nil) == locked, "cloud session lock matches lifecycle")
	return {
		key = key,
		coins = record.coins,
		tutorial = record.tutorial,
		locked = locked,
		uncached = true,
	}
end
