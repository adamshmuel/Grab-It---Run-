--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
	local module = shared:FindFirstChild("Session")
	assert(module, "RED: session integration must exist before server play")
	local Session = require(module :: ModuleScript)
	local ok, result = pcall(function()
		local elapsed = 0
		local s = Session.new(function()
			return elapsed
		end)
		s:add("new", 0, false)
		s:add("friend", 0, false)
		elapsed = 3
		s:tick()
		local first = s:get("new")
		assert(first.coins == 0 and #first.cargo == 0, "fresh player")
		assert(not s:collect("new", 21, 0, 3, -10), "cannot collect remotely from base")
		assert(s:collect("new", 1, -12, 3, 12), "valid near collection")
		assert(s:collect("friend", 1, -12, 3, 12), "friend has personal copy")
		local bank = s:step("new", 0, 3, -8)
		assert(bank.banked == 2 and first.coins == 2, "deposit")
		assert(s:step("new", 0, 3, -8).banked == 0, "repeated base position cannot duplicate")
		assert(s:collect("new", 21, -12, 3, 72), "second outing")
		elapsed = 183
		assert(not s:collect("new", 22, 12, 3, 72), "collection at closure is rejected")
		local close = s:step("new", -12, 3, 72)
		assert(
			close.returnHome and first.pendingLoss and #first.cargo == 0 and first.coins == 2,
			"failure only loses unbanked cargo"
		)
		elapsed = 188
		assert(s:collect("new", 1, -12, 3, 12), "new round renews item")
		assert(s:step("new", 0, 3, -8).banked == 3 and first.coins == 5, "whole session continues")
		s:remove("new")
		assert(s:get("new") == nil, "departed state cleared")
		print("PASS full session, independent players, deposit, closure and next round")
		return 11
	end)
	shared:Destroy()
	assert(ok, result)
	return result
end
