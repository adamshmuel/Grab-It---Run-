--!strict
return function(): number
	local source = game:GetService("ReplicatedStorage").GrabIt.Shared
	local shared = source:Clone()
	local count = 0
	local function test(name: string, body: () -> ())
		local ok, err = pcall(body)
		assert(ok, name .. ": " .. tostring(err))
		count += 1
	end
	local ok, err = pcall(function()
		test("catalog has five types and thirty regulars at each stage", function()
			local c = shared:FindFirstChild("Catalog")
			assert(c, "RED: Catalog missing")
			local Catalog = require(c)
			for stage = 1, 3 do
				local items = Catalog.items(stage)
				assert(
					#items == (if stage == 3 then 31 else 30),
					"ImprovementRules.spec: #items == (if stage == 3 then 31 else 30)"
				)
				local counts = {}
				local weight, value = 0, 0
				for _, item in items do
					if not item.special then
						counts[item.kind] = (counts[item.kind] or 0) + 1
					end
					weight += item.weight
					value += item.value
				end
				local kinds = 0
				for _, n in counts do
					assert(n == 6, "ImprovementRules.spec: n == 6")
					kinds += 1
				end
				assert(kinds == 5, "ImprovementRules.spec: kinds == 5")
				assert(
					value == ({ 162, 276, 433 })[stage] and weight == ({ 90, 138, 200 })[stage],
					"ImprovementRules.spec: value == ({ 162, 276, 433 })[stage] and weight == ({ 90, 138, 200 })[stage]"
				)
				assert(
					items[30].z == 96 and items[1].x == -12 and items[2].x == 12,
					"ImprovementRules.spec: items[30].z == 96 and items[1].x == -12 and items[2].x == 12"
				)
			end
		end)
		test("eight items fit by total weight and a ninth overweight item is rejected", function()
			local R = require(shared.GameRules)
			local p = R.newPlayer()
			for id = 1, 8 do
				assert(
					R.collect(p, id, 1, true, 1),
					"ImprovementRules.spec: R.collect(p, id, 1, true, 1)"
				)
			end
			assert(
				R.weight(p) == 10 and #p.cargo == 8 and math.abs(R.speed(p) - 10.4) < 1e-8,
				"ImprovementRules.spec: R.weight(p) == 10 and #p.cargo == 8 and math.abs(R.speed(p) - 10.4) < 1e-8"
			)
			assert(
				not R.collect(p, 9, 1, true, 1) and #p.cargo == 8,
				"ImprovementRules.spec: not R.collect(p, 9, 1, true, 1) and #p.cargo == 8"
			)
		end)
		test("loss restores unbanked slots but never banked slots", function()
			local R = require(shared.GameRules)
			local p = R.newPlayer()
			assert(
				R.collect(p, 1, 1, true, 1),
				"ImprovementRules.spec: R.collect(p, 1, 1, true, 1)"
			)
			assert(R.bank(p) == 2, "ImprovementRules.spec: R.bank(p) == 2")
			assert(
				R.collect(p, 2, 1, true, 1),
				"ImprovementRules.spec: R.collect(p, 2, 1, true, 1)"
			)
			R.lose(p)
			assert(
				p.coins == 2 and not p.collected[2] and p.collected[1],
				"ImprovementRules.spec: p.coins == 2 and not p.collected[2] and p.collected[1]"
			)
			assert(
				R.collect(p, 2, 1, true, 1),
				"ImprovementRules.spec: R.collect(p, 2, 1, true, 1)"
			)
			assert(
				not R.collect(p, 1, 1, true, 1),
				"ImprovementRules.spec: not R.collect(p, 1, 1, true, 1)"
			)
		end)
		test("special cargo exposes only known regular weight and value", function()
			local R = require(shared.GameRules)
			local p = R.newPlayer()
			R.beginStage(p, 3, 3)
			assert(
				R.collect(p, 31, 3, true, 1),
				"ImprovementRules.spec: R.collect(p, 31, 3, true, 1)"
			)
			assert(
				R.collect(p, 7, 3, true, 1),
				"ImprovementRules.spec: R.collect(p, 7, 3, true, 1)"
			)
			local display = R.cargoDisplay(p)
			assert(
				display.weight == "4 + ?" and display.value == "7 + ?",
				'ImprovementRules.spec: display.weight == "4 + ?" and display.value == "7 + ?"'
			)
			assert(
				R.weight(p) == 18 and not R.collect(p, 1, 3, true, 1),
				"ImprovementRules.spec: R.weight(p) == 18 and not R.collect(p, 1, 3, true, 1)"
			)
			assert(
				R.bank(p) == 62 and p.stageScore == 62 and p.bankedCount == 2,
				"ImprovementRules.spec: R.bank(p) == 62 and p.stageScore == 62 and p.bankedCount == 2"
			)
		end)
		test("invalid collection never mutates new player", function()
			local R = require(shared.GameRules)
			local p = R.newPlayer()
			for _, v in { 0, -1, 99, 1.5, math.huge, 0 / 0 } do
				assert(
					not R.collect(p, v, 1, true, 0),
					"ImprovementRules.spec: not R.collect(p, v, 1, true, 0)"
				)
			end
			assert(
				not R.collect(p, 1, 1, true, 0 / 0),
				"ImprovementRules.spec: not R.collect(p, 1, 1, true, 0 / 0)"
			)
			assert(
				not R.collect(p, 1, 1, false, 0),
				"ImprovementRules.spec: not R.collect(p, 1, 1, false, 0)"
			)
			assert(#p.cargo == 0, "ImprovementRules.spec: #p.cargo == 0")
		end)
	end)
	shared:Destroy()
	assert(ok, err)
	return count
end
