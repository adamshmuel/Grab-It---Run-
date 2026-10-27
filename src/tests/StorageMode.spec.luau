--!strict
return function()
	local source = game:GetService("ServerScriptService").GrabItModules
		:FindFirstChild("StorageMode")
	assert(source, "storage selection needs an isolated cloud QA mode")
	local copy = source:Clone()
	local ok, result = pcall(function()
		local Mode = require(copy)
		local live = Mode.select(false, "qa_cloud_01")
		assert(
			not live.memory and live.name == "GrabItV1_PlayerData" and live.keyPrefix == "",
			"live storage ignores QA markers"
		)
		local normal = Mode.select(true, nil)
		assert(
			normal.memory and normal.name == nil and normal.keyPrefix == "",
			"ordinary Studio stays isolated"
		)
		local qa = Mode.select(true, "qa_cloud_01")
		assert(
			not qa.memory and qa.name == "GrabItV1_QA_Verification",
			"cloud QA has a fixed separate store"
		)
		assert(qa.keyPrefix == "QA_qa_cloud_01_", "cloud QA keys belong to one explicit run")
		for _, value in { false, 10, {}, "", "../production", string.rep("x", 21) } do
			assert(Mode.select(true, value).memory, "invalid QA markers cannot enable cloud writes")
		end
		local longest = Mode.select(true, string.rep("x", 20))
		assert(
			#(longest.keyPrefix .. "User_" .. string.rep("9", 20)) <= 50,
			"run prefix fits the datastore key limit"
		)
		local args = { marker = "GrabItV1.IsolatedCloudQA", runId = "qa_runtime_01" }
		local runtime = Mode.select(true, nil, args)
		assert(
			not runtime.memory
				and runtime.name == "GrabItV1_QA_Verification"
				and runtime.keyPrefix == "QA_qa_runtime_01_",
			"native test args must opt into the same isolated QA store"
		)
		assert(
			Mode.select(false, nil, args).name == "GrabItV1_PlayerData",
			"live servers ignore native QA args"
		)
		assert(
			Mode.select(true, "attribute", args).keyPrefix == "QA_attribute_",
			"explicit attribute has priority"
		)
		assert(Mode.select(true, false, args).memory, "invalid explicit marker fails closed")
		for _, bad in
			{
				{},
				false,
				"qa_runtime_01",
				{ marker = "other", runId = "qa_runtime_01" },
				{ marker = args.marker, runId = "../production" },
				{ marker = args.marker, runId = string.rep("x", 21) },
			}
		do
			assert(
				Mode.select(true, nil, bad).memory,
				"unknown or malformed native args stay memory-only"
			)
		end
		return 8
	end)
	copy:Destroy()
	assert(ok, result)
	return result
end
