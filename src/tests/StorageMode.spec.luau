--!strict
return function()
	local source = game:GetService("ServerScriptService").GrabItModules
		:FindFirstChild("StorageMode")
	assert(source, "storage selection needs an isolated cloud QA mode")
	local Mode = require(source)
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
	return 5
end
