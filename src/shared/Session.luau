--!strict
local Rules = require(script.Parent.GameRules)
local View = require(script.Parent.Presentation)
local Session = {}
Session.__index = Session
function Session.new(clock: () -> number)
	return setmetatable({ clock = clock, players = {} :: { [string]: Rules.PlayerState } }, Session)
end
function Session.add(self, id: string, coins: number, tutorial: boolean)
	self.players[id] = Rules.newPlayer(coins, tutorial)
end
function Session.get(self, id: string): Rules.PlayerState?
	return self.players[id]
end
function Session.remove(self, id: string)
	self.players[id] = nil
end
function Session.collect(self, id: string, itemId: number, x: number, y: number, z: number): boolean
	local p = self.players[id]
	local r = Rules.round(self.clock())
	if not p or not View.inWarehouse(x, y, z) then
		return false
	end
	local collected = if p.roundId == r.id then p.collected else {}
	if View.nearest(Rules.items, collected, r.id, x, y, z) ~= itemId then
		return false
	end
	local item = Rules.items[itemId]
	local distance = math.sqrt((x - item.x) ^ 2 + (y - 2.5) ^ 2 + (z - item.z) ^ 2)
	return Rules.collect(p, itemId, r.id, r.open, distance)
end
function Session.step(self, id: string, x: number, y: number, z: number)
	local p = self.players[id]
	local r = Rules.round(self.clock())
	if not p then
		return { banked = 0, lost = false }
	end
	local lost = false
	if z > 0 and (not r.open or (p.roundId ~= 0 and p.roundId ~= r.id and #p.cargo > 0)) then
		lost = #p.cargo > 0
		Rules.lose(p)
		return { banked = 0, lost = lost, returnHome = true }
	end
	return { banked = if View.inDeposit(x, y, z) then Rules.bank(p) else 0, lost = lost }
end
return Session
