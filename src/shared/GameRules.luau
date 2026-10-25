--!strict
local Catalog = require(script.Parent.Catalog)
local Rules = {}
export type PlayerState = {
	name: string?,
	pendingLoss: boolean,
	coins: number,
	cargo: { number },
	collected: { [number]: boolean },
	banked: { [number]: boolean },
	roundId: number,
	stage: number,
	tutorial: boolean,
	stageScore: number,
	bankedCount: number,
	finishTime: number?,
	matchPoints: number,
	runEarnings: number,
	stageEarnings: { number },
	ranked: boolean,
	eligible: boolean,
	owned: { [string]: boolean },
	selected: string,
	revision: number,
}
export type Item = Catalog.Item
function Rules.newPlayer(coins: number?, tutorial: boolean?): PlayerState
	return {
		coins = coins or 0,
		pendingLoss = false,
		tutorial = tutorial or false,
		cargo = {},
		collected = {},
		banked = {},
		roundId = 1,
		stage = 1,
		stageScore = 0,
		bankedCount = 0,
		matchPoints = 0,
		runEarnings = 0,
		stageEarnings = { 0, 0, 0 },
		ranked = false,
		eligible = false,
		owned = { basic = true },
		selected = "basic",
		revision = 0,
	}
end
function Rules.beginStage(p: PlayerState, stage: number, roundId: number): ()
	p.stage = stage
	p.roundId = roundId
	p.cargo = {}
	p.collected = {}
	p.banked = {}
	p.stageScore = 0
	p.bankedCount = 0
	p.finishTime = nil
end
function Rules.weight(p: PlayerState): number
	local total = 0
	for _, id in p.cargo do
		total += Catalog.items(p.stage)[id].weight
	end
	return total
end
function Rules.speed(p: PlayerState): number
	return 16 * (1 - 0.35 * Rules.weight(p) / Catalog.stages[p.stage].capacity)
end
function Rules.value(p: PlayerState): number
	local total = 0
	for _, id in p.cargo do
		total += Catalog.items(p.stage)[id].value
	end
	return total
end
function Rules.cargoDisplay(p: PlayerState): { weight: string, value: string, hidden: boolean }
	local w, v, hidden = 0, 0, false
	for _, id in p.cargo do
		local item = Catalog.items(p.stage)[id]
		if item.special then
			hidden = true
		else
			w += item.weight
			v += item.value
		end
	end
	local function text(n: number): string
		return if hidden then (if n == 0 then "?" else tostring(n) .. " + ?") else tostring(n)
	end
	return { weight = text(w), value = text(v), hidden = hidden }
end
function Rules.collect(
	p: PlayerState,
	id: number,
	roundId: number,
	open: boolean,
	distance: number
): boolean
	local items = Catalog.items(p.stage)
	if
		not open
		or distance ~= distance
		or distance < 0
		or distance > 6
		or id % 1 ~= 0
		or not items[id]
		or p.roundId ~= roundId
		or p.collected[id]
	then
		return false
	end
	if Rules.weight(p) + items[id].weight > Catalog.stages[p.stage].capacity then
		return false
	end
	p.collected[id] = true
	table.insert(p.cargo, id)
	return true
end
function Rules.bank(p: PlayerState, elapsed: number?): (number, number)
	local value, special = Rules.value(p), 0
	for _, id in p.cargo do
		p.banked[id] = true
		p.bankedCount += 1
		local item = Catalog.items(p.stage)[id]
		if item.special then
			special = item.value
		end
	end
	p.coins += value
	p.stageScore += value
	p.runEarnings += value
	p.stageEarnings[p.stage] += value
	if value > 0 then
		p.tutorial = true
		p.revision += 1
	end
	table.clear(p.cargo)
	if p.bankedCount == #Catalog.items(p.stage) and not p.finishTime then
		p.finishTime = math.round((elapsed or 0) * 100) / 100
	end
	return value, special
end
function Rules.lose(p: PlayerState): ()
	for _, id in p.cargo do
		if not p.banked[id] then
			p.collected[id] = nil
		end
	end
	table.clear(p.cargo)
end
return table.freeze(Rules)
