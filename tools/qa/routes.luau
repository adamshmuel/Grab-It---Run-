--!strict
-- GrabItV1.ImprovementsQA: real routes and earned purchases, not production gameplay.
return function(encodedRoutes: string, duration: number, context)
	local root, player = context.root, context.player
	local Catalog = require(root.Shared.Catalog)
	local getState, walk, collect = context.getState, context.walk, context.collect
	local awaitCondition, runner = context.awaitCondition, context.runner
	local config = game:GetService("HttpService"):JSONDecode(encodedRoutes)
	local plans = config.stages or config
	local finishCosmetics = config.finishCosmetics == true
	assert(not finishCosmetics or duration == 900, "bounded full cosmetics run")
	assert(#plans == 3, "route plan covers all stages")
	local journal = {}
	local purchases = {}
	for cycle = 1, if finishCosmetics then 3 else 1 do
		for stage, plan in plans do
			local economyOnly = finishCosmetics and cycle == 3
			runner:SetAttribute("Stage", "route-" .. stage)
			awaitCondition(function()
				return getState().stage == stage and getState().open
			end, 200, "route stage did not open")
			walk(0, -8, 0.9)
			local startRemaining, initialCoins = getState().remaining, getState().coins
			local entries = {}
			for _, ids in plan do
				local expected = 0
				for index, id in ids do
					assert(
						getState().stage == stage and getState().open,
						"route ran out of stage time"
					)
					local item = Catalog.items(stage)[id]
					walk(
						if item.special then 0 else item.x * 2 / 3,
						if item.special then item.z - 4 else item.z,
						0.9
					)
					collect(index)
					assert(getState().collected[id], "route must collect its intended object")
					expected += item.value
				end
				local before = getState().coins
				walk(0, -8, 0.9)
				awaitCondition(function()
					return getState().cargoCount == 0 and getState().coins == before + expected
				end, 2, "route deposit mismatch")
				table.insert(entries, {
					ids = ids,
					remaining = getState().remaining,
					banked = getState().bankedCount,
					reward = getState().coins - initialCoins,
				})
				runner:SetAttribute(
					"RouteJournal",
					game:GetService("HttpService"):JSONEncode({
						completed = journal,
						match = cycle,
						stage = stage,
						trips = entries,
					})
				)
				if
					economyOnly
					and getState().coins >= require(root.Shared.Cosmetics).get("royal").price
				then
					break
				end
			end
			if not economyOnly then
				local minimum = ({ 30, 18, 15 })[stage]
				assert(getState().bankedCount >= minimum, "required banked item count")
				if stage == 1 then
					assert(
						Catalog.stages[stage].seconds - getState().remaining <= 165,
						"stage1 route <=165 seconds"
					)
					assert(getState().canNext, "full solo stage offers early transition")
					root.Action:FireServer("next")
				end
			end
			table.insert(journal, {
				match = cycle,
				stage = stage,
				economyOnly = economyOnly,
				beganRemaining = startRemaining,
				trips = entries,
			})
			if economyOnly then
				break
			end
		end
		if not (finishCosmetics and cycle == 3) then
			awaitCondition(function()
				return getState().phase == "summary"
			end, 110, "match summary missing")
			local savedCoins = getState().coins
			awaitCondition(function()
				return getState().stage == 1 and getState().open
			end, 20, "new match missing")
			assert(
				getState().coins == savedCoins
					and getState().bankedCount == 0
					and getState().capacity == 10,
				"new match resets stage, preserves earnings"
			)
		end
		for _, style in require(root.Shared.Cosmetics).list do
			if style.price == 0 or getState().owned[style.id] then
				continue
			end
			local coins, selected = getState().coins, getState().selected
			root.Action:FireServer("equip", style.id)
			task.wait(0.2)
			assert(getState().selected == selected, "unowned style cannot be equipped")
			root.Action:FireServer("buy", style.id)
			task.wait(0.2)
			root.Action:FireServer("buy", style.id)
			if coins >= style.price then
				awaitCondition(function()
					return getState().owned[style.id] == true
				end, 8, "earned purchase not confirmed")
				assert(
					getState().coins == coins - style.price and getState().selected == selected,
					"single debit without automatic equip"
				)
				task.wait(0.2)
				root.Action:FireServer("equip", style.id)
				awaitCondition(function()
					return getState().selected == style.id
				end, 3, "owned equip not confirmed")
				assert(
					player.Character.Humanoid.WalkSpeed == 16,
					"purchased equipment has no speed advantage"
				)
			else
				task.wait(0.5)
				assert(
					not getState().owned[style.id] and getState().coins == coins,
					"insufficient purchase must not debit"
				)
			end
			table.insert(purchases, {
				id = style.id,
				match = cycle,
				before = coins,
				after = getState().coins,
				owned = getState().owned[style.id] == true,
				selected = getState().selected,
			})
		end
		if getState().owned.royal then
			break
		end
	end
	local continuation = nil
	if finishCosmetics then
		assert(
			getState().owned.canvas and getState().owned.field and getState().owned.royal,
			"all styles earned and purchased"
		)
		for _, item in Catalog.items(getState().stage) do
			if not getState().collected[item.id] and not item.special then
				local before = getState().coins
				walk(item.x * 2 / 3, item.z, 0.9)
				collect(1)
				walk(0, -8, 0.9)
				awaitCondition(function()
					return getState().coins == before + item.value and getState().cargoCount == 0
				end, 3, "play continues after all designs owned")
				continuation = {
					allOwned = true,
					selected = getState().selected,
					deposited = item.value,
					coins = getState().coins,
				}
				break
			end
		end
		assert(continuation, "post-purchase outing completed")
	end
	return {
		routes = journal,
		purchases = purchases,
		continuation = continuation,
		newMatch = true,
		coins = getState().coins,
		input = "normal-speed Humanoid MoveTo and real collect/next remotes; no clock or position changes",
	}
end
