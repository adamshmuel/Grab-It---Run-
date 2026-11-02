--!strict
return function(): number
	local shared = game.ReplicatedStorage.GrabIt.Shared:Clone()
	local ok, result = pcall(function()
		local C = require(shared.Catalog)
		local S = require(shared.Session)
		assert(#C.stages == 5, "A match contains five stages")
		assert(C.stages[4].seconds == 80 and C.stages[4].capacity == 22, "Expedition stage budget")
		assert(
			C.stages[5].seconds == 60 and C.stages[5].capacity == 26,
			"Final minute and capacity"
		)
		for stage = 1, 5 do
			local baseline = C.items(stage)
			assert(
				#baseline == (if stage >= 3 then 31 else 30),
				"One additional special in each late stage"
			)
			if stage >= 3 then
				assert(baseline[31].special and baseline[31].z == 114, "Dedicated far-end special")
			end
		end
		for stage, expected in { [2] = 750, [3] = 800, [4] = 877, [5] = 834 } do
			assert(
				C.variantCount(stage) == expected,
				"Every allowed composition remains selectable"
			)
			local baseWeight, baseValue = 0, 0
			for _, kind in C.stages[stage].kinds do
				baseWeight += 6 * kind.weight
				baseValue += 6 * kind.value
			end
			for variant = 1, expected do
				local items = C.items(stage, { variant = variant, flips = variant % 32768 })
				local counts, weight, value = { 0, 0, 0, 0, 0 }, 0, 0
				for id = 1, 30 do
					local item = items[id]
					assert(item.id == id and not item.special, "Slot IDs remain regular and stable")
					assert(
						math.abs(item.x) == 12 and item.z == 12 + math.floor((id - 1) / 2) * 6,
						"Fixed accessible slots"
					)
					counts[item.kind] += 1
					weight += item.weight
					value += item.value
				end
				local seen = {}
				for _, n in counts do
					assert(n >= 2 and n <= 10 and not seen[n], "Five different per-type quantities")
					seen[n] = true
				end
				assert(
					math.abs(weight - baseWeight) * 10 <= baseWeight,
					"Aggregate weight stays within 10 percent"
				)
				assert(
					math.abs(value - baseValue) * 10 <= baseValue,
					"Aggregate value stays within 10 percent"
				)
				if stage >= 4 then
					local n = if stage == 4 then 8 else 6
					local total, light = 0, {}
					for id = 1, n do
						light[id] = items[id].weight
						total += light[id]
					end
					local fits = false
					for mask = 0, 2 ^ n - 1 do
						local first = 0
						for id, w in light do
							if bit32.band(mask, 2 ^ (id - 1)) ~= 0 then
								first += w
							end
						end
						if
							first <= C.stages[stage].capacity
							and total - first <= C.stages[stage].capacity
						then
							fits = true
							break
						end
					end
					assert(fits, "Required lightweight items fit in two trips")
				end
			end
		end
		local Rules = require(shared.GameRules)
		for stage = 4, 5 do
			local p = Rules.newPlayer()
			local layout = C.nextLayout(stage, Random.new(stage))
			Rules.beginStage(p, stage, stage, layout)
			assert(Rules.collect(p, 31, stage, true, 0), "New special fits stage capacity")
			local display = Rules.cargoDisplay(p)
			assert(
				display.hidden and display.weight == "?" and display.value == "?",
				"New special does not leak weight or value"
			)
			Rules.lose(p)
			assert(
				not p.collected[31] and Rules.collect(p, 31, stage, true, 0),
				"Lost special returns to its original slot"
			)
			local reward = Rules.bank(p, 10)
			assert(
				reward == C.items(stage, layout)[31].value and p.banked[31],
				"Special becomes known only after banking"
			)
		end
		local now = 0
		local session = S.new(function()
			return now
		end, Random.new(17))
		local a = session:add("a", 0, false)
		now = 3
		session:tick()
		session:beginStage(2, now)
		local layout = session.layout
		local items = C.items(2, layout)
		local b = session:add("b", 0, false)
		assert(
			a.layout == layout and b.layout == layout,
			"Current and late players share one server layout"
		)
		local changed = nil
		for id = 1, 30 do
			if items[id].model ~= C.items(2)[id].model then
				changed = id
				break
			end
		end
		local id = assert(changed, "Random quantities differ from the fixed preview")
		local item = items[id]
		assert(session:collect("a", id, item.x, 2.5, item.z), "Collect from the live layout")
		session:step("a", 0, 4, -8)
		assert(a.coins == item.value and a.bankedCount == 1, "Banking uses actual layout value")
		session:remove("a")
		local rejoined = session:add("a", 0, true)
		assert(
			rejoined.layout == layout and rejoined.banked[id],
			"Rejoin preserves layout and banked slot"
		)
		assert(
			not session:collect("a", id, item.x, 2.5, item.z),
			"Rejoin cannot duplicate a banked item"
		)
		session:beginStage(2, now)
		assert(
			session.layout.variant ~= layout.variant,
			"Next attempt of the same stage changes composition"
		)
		local run = S.new(function()
			return now
		end, Random.new(5))
		local p = run:add("solo", 0, false)
		now += 3
		run:tick()
		assert(#p.stageEarnings == 5, "Personal results include all five stages")
		for stage = 1, 5 do
			assert(run.stage == stage and run.phase == "active", "Each stage starts once")
			now += C.stages[stage].seconds
			run:tick()
			assert(
				run.phase == (if stage == 5 then "summary" else "results"),
				"Only stage five ends the match"
			)
			if stage < 5 then
				now += 5
				run:tick()
			end
		end
		assert(p.matchPoints == 50, "All five stage placements contribute to the match")
		local multi = S.new(function()
			return now
		end, Random.new(10))
		multi:add("first", 0, false)
		multi:add("second", 0, false)
		multi:beginStage(5, now)
		multi:add("late", 0, false)
		for _, name in { "first", "second", "late" } do
			local player = multi:get(name)
			for _, cargoItem in C.items(5, multi.layout) do
				if not Rules.collect(player, cargoItem.id, player.roundId, true, 0) then
					Rules.bank(player, 1)
					assert(
						Rules.collect(player, cargoItem.id, player.roundId, true, 0),
						"New-stage item fits an empty bag"
					)
				end
			end
			Rules.bank(player, 2)
			multi:tick()
			assert(
				multi.phase == (if name == "late" then "summary" else "active"),
				"Shared final stage waits for the Unranked late joiner too"
			)
		end
		return 5
	end)
	shared:Destroy()
	assert(ok, result)
	return result
end
