--!strict
local Rules = {}
export type PlayerState = {
	coins: number,
	cargo: { number },
	collected: { [number]: boolean },
	roundId: number,
	tutorial: boolean,
}
export type Item = { id: number, x: number, z: number, value: number, zone: number }
local items: { Item } = {}
for zone = 1, 3 do
	for row = 1, 5 do
		for _, x in { -12, 12 } do
			table.insert(items, {
				id = #items + 1,
				x = x,
				z = (zone - 1) * 36 + 6 + row * 6,
				value = ({ 1, 3, 6 })[zone],
				zone = zone,
			})
		end
	end
end
Rules.items = table.freeze(items)
Rules.capacity = 5
Rules.openSeconds = 180
Rules.closedSeconds = 20
function Rules.newPlayer(coins: number?, tutorial: boolean?): PlayerState
	return {
		coins = coins or 0,
		cargo = {},
		collected = {},
		roundId = 0,
		tutorial = tutorial or false,
	}
end
function Rules.round(elapsed: number)
	local cycle = Rules.openSeconds + Rules.closedSeconds
	local within = math.max(elapsed, 0) % cycle
	return {
		id = math.floor(math.max(elapsed, 0) / cycle) + 1,
		open = within < Rules.openSeconds,
		remaining = math.ceil(
			(if within < Rules.openSeconds then Rules.openSeconds else cycle) - within
		),
		warning = within >= 150 and within < 180,
	}
end
function Rules.speed(p: PlayerState): number
	return 16 * (1 - #p.cargo * 0.1)
end
function Rules.value(p: PlayerState): number
	local total = 0
	for _, id in p.cargo do
		total += items[id].value
	end
	return total
end
function Rules.collect(
	p: PlayerState,
	id: number,
	roundId: number,
	open: boolean,
	distance: number
): boolean
	if
		not open
		or distance ~= distance
		or distance < 0
		or distance > 6
		or id % 1 ~= 0
		or not items[id]
		or #p.cargo >= Rules.capacity
	then
		return false
	end
	if p.roundId ~= roundId then
		p.collected = {}
		p.roundId = roundId
	end
	if p.collected[id] then
		return false
	end
	p.collected[id] = true
	table.insert(p.cargo, id)
	return true
end
function Rules.bank(p: PlayerState): number
	local value = Rules.value(p)
	p.coins += value
	table.clear(p.cargo)
	if value > 0 then
		p.tutorial = true
	end
	return value
end
function Rules.lose(p: PlayerState)
	table.clear(p.cargo)
end
return table.freeze(Rules)
