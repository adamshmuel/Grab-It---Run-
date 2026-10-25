--!strict
return function(): number
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
	local ok, result = pcall(function()
		local S = require(shared.Session)
		local R = require(shared.GameRules)
		local now = 0
		local s = S.new(function()
			return now
		end)
		s:add("a", 0, false, "Adam")
		assert(s:state().phase == "countdown", "RED: first ready player starts a countdown")
		now = 3
		s:tick()
		assert(
			s:state().open and s:state().stage == 1,
			"ImprovementSession.spec: s:state().open and s:state().stage == 1"
		)
		local deadline = s:state().deadline
		s:add("b", 0, false, "Beth")
		assert(
			not s:get("b").ranked and s:state().deadline == deadline,
			'ImprovementSession.spec: not s:get("b").ranked and s:state().deadline == deadline'
		)
		now = 183
		s:tick()
		assert(
			s:state().phase == "results" and s:state().remaining == 5,
			'ImprovementSession.spec: s:state().phase == "results" and s:state().remaining == 5'
		)
		now = 188
		s:tick()
		assert(
			s:state().stage == 2 and s:get("b").ranked and not s:get("b").eligible,
			'ImprovementSession.spec: s:state().stage == 2 and s:get("b").ranked and not s:get("b").eligible'
		)
		assert(
			s:state().mode == "multi" and s:state().remaining == 135,
			'ImprovementSession.spec: s:state().mode == "multi" and s:state().remaining == 135'
		)
		now = 323
		s:tick()
		now = 328
		s:tick()
		assert(
			s:state().stage == 3 and s:state().remaining == 100,
			"ImprovementSession.spec: s:state().stage == 3 and s:state().remaining == 100"
		)
		now = 428
		s:tick()
		assert(
			s:state().phase == "summary",
			'ImprovementSession.spec: s:state().phase == "summary"'
		)
		now = 438
		s:tick()
		assert(
			s:state().stage == 1 and s:get("b").eligible,
			'ImprovementSession.spec: s:state().stage == 1 and s:get("b").eligible'
		)
		assert(
			s:get("a").coins == 0 and s:get("a").matchPoints == 0,
			'ImprovementSession.spec: s:get("a").coins == 0 and s:get("a").matchPoints == 0'
		)
		local rank = shared:FindFirstChild("Ranking")
		assert(rank, "RED: Ranking missing")
		local Ranking = require(rank)
		local rows = Ranking.stage({
			a = { name = "A", stageScore = 222, bankedCount = 27, ranked = true },
			b = { name = "B", stageScore = 234, bankedCount = 20, ranked = true },
			c = { name = "C", stageScore = 234, bankedCount = 20, ranked = true },
			d = { name = "D", stageScore = 999, bankedCount = 30, ranked = false },
		}, 30)
		local by = {}
		for _, row in rows do
			by[row.id] = row
		end
		assert(
			by.b.place == 1 and by.c.place == 1 and by.a.place == 3 and by.d.place == nil,
			"ImprovementSession.spec: by.b.place == 1 and by.c.place == 1 and by.a.place == 3 and by.d.place == nil"
		)
		assert(
			Ranking.points(1) == 10 and Ranking.points(2) == 8,
			"ImprovementSession.spec: Ranking.points(1) == 10 and Ranking.points(2) == 8"
		)
		local solo = S.new(function()
			return now
		end)
		solo:add("x", 0, false, "X")
		now += 3
		solo:tick()
		local p = solo:get("x")
		for _, item in require(shared.Catalog).items(1) do
			if not R.collect(p, item.id, p.roundId, true, 0) then
				R.bank(p, 1)
				assert(
					R.collect(p, item.id, p.roundId, true, 0),
					"ImprovementSession.spec: R.collect(p, item.id, p.roundId, true, 0)"
				)
			end
		end
		R.bank(p, 2)
		assert(
			solo:state().canNext and solo:advance("x"),
			'ImprovementSession.spec: solo:state().canNext and solo:advance("x")'
		)
		assert(
			solo:state().phase == "results" and p.coins == 162,
			'ImprovementSession.spec: solo:state().phase == "results" and p.coins == 162'
		)
		solo:add("y", 0, false, "Y")
		now += 5
		solo:tick()
		assert(
			solo:state().mode == "multi",
			'ImprovementSession.spec: solo:state().mode == "multi"'
		)
		local y = solo:get("y")
		assert(
			solo:collect("y", 1, -12, 2.5, 12),
			'ImprovementSession.spec: solo:collect("y", 1, -12, 2.5, 12)'
		)
		solo:step("y", 0, 3, -8)
		assert(y.coins == 3, "ImprovementSession.spec: y.coins == 3")
		solo:remove("y")
		solo:add("y", 3, true, "Y")
		assert(
			solo:get("y").collected[1] and not solo:get("y").ranked and not solo:get("y").eligible,
			'ImprovementSession.spec: solo:get("y").collected[1] and not solo:get("y").ranked and not solo:get("y").eligible'
		)
		assert(
			not solo:collect("y", 1, -12, 2.5, 12),
			'ImprovementSession.spec: not solo:collect("y", 1, -12, 2.5, 12)'
		)
		solo:remove("x")
		solo:remove("y")
		assert(
			solo:state().phase == "idle",
			'ImprovementSession.spec: solo:state().phase == "idle"'
		)
		local emptyAfterThree = S.new(function()
			return now
		end)
		emptyAfterThree:add("last", 0, false, "Last")
		now += 3
		emptyAfterThree:tick()
		now += 180 + 5 + 135 + 5
		emptyAfterThree:tick()
		assert(emptyAfterThree:state().stage == 3, "reach third stage before empty-server case")
		emptyAfterThree:remove("last")
		emptyAfterThree:add("first", 0, false, "First")
		assert(emptyAfterThree:state().stage == 1, "empty server countdown must show stage one")
		local departed = S.new(function()
			return now
		end)
		departed:add("one", 0, false, "One")
		departed:add("two", 0, false, "Two")
		now += 3
		departed:tick()
		now += 180
		departed:tick()
		departed:remove("two")
		for _, row in departed:rows() do
			assert(row.id ~= "two", "departed player removed from current results")
		end
		return 11
	end)
	shared:Destroy()
	assert(ok, result)
	return result
end
