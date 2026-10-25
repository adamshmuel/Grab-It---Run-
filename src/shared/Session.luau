--!strict
local Rules = require(script.Parent.GameRules)
local Catalog = require(script.Parent.Catalog)
local View = require(script.Parent.Presentation)
local Ranking = require(script.Parent.Ranking)
local Session = {}
Session.__index = Session
function Session.new(clock: () -> number)
	return setmetatable({
		clock = clock,
		players = {},
		phase = "idle",
		stage = 1,
		roundId = 0,
		deadline = 0,
		startedAt = 0,
		mode = "solo",
		cache = {},
		results = {},
		matchResults = {},
		generation = 0,
	}, Session)
end
function Session.get(self, id: string)
	return self.players[id]
end
function Session.count(self): number
	local n = 0
	for _ in self.players do
		n += 1
	end
	return n
end
function Session.beginRun(self, at: number): ()
	self.cache = {}
	for _, p in self.players do
		p.matchPoints = 0
		p.runEarnings = 0
		p.stageEarnings = { 0, 0, 0 }
		p.eligible = true
	end
	self:beginStage(1, at)
end
function Session.beginStage(self, stage: number, at: number): ()
	self.stage = stage
	self.roundId += 1
	self.phase = "active"
	self.startedAt = at
	self.deadline = at + Catalog.stages[stage].seconds
	self.mode = if self:count() == 1 then "solo" else "multi"
	self.generation += 1
	for _, p in self.players do
		Rules.beginStage(p, stage, self.roundId)
		p.ranked = true
	end
	self.results = {}
	self.matchResults = {}
end
function Session.add(self, id: string, coins: number, tutorial: boolean, name: string?)
	self:tick()
	local p = Rules.newPlayer(coins, tutorial)
	p.name = name or id
	p.eligible = false
	p.ranked = false
	Rules.beginStage(p, self.stage, self.roundId)
	local saved = self.cache[id]
	if saved and saved.roundId == self.roundId then
		p.banked = table.clone(saved.banked)
		p.collected = table.clone(saved.banked)
		p.bankedCount = saved.bankedCount
		p.stageScore = saved.stageScore
		p.stageEarnings = table.clone(saved.stageEarnings)
		p.runEarnings = saved.runEarnings
		p.finishTime = saved.finishTime
	end
	self.players[id] = p
	if self.phase == "idle" then
		self.phase = "countdown"
		self.deadline = self.clock() + 3
	end
	return p
end
function Session.remove(self, id: string): ()
	local p = self.players[id]
	if not p then
		return
	end
	self.cache[id] = {
		roundId = self.roundId,
		banked = table.clone(p.banked),
		bankedCount = p.bankedCount,
		stageScore = p.stageScore,
		finishTime = p.finishTime,
		runEarnings = p.runEarnings,
		stageEarnings = table.clone(p.stageEarnings),
	}
	self.players[id] = nil
	for i = #self.results, 1, -1 do
		if self.results[i].id == id then
			table.remove(self.results, i)
		end
	end
	self.matchResults = Ranking.match(self.players)
	if self:count() == 0 then
		self.phase = "idle"
		self.stage = 1
		self.cache = {}
		self.results = {}
		self.matchResults = {}
	end
end
function Session.allComplete(self): boolean
	if self:count() == 0 then
		return false
	end
	for _, p in self.players do
		if p.bankedCount < #Catalog.items(self.stage) then
			return false
		end
	end
	return true
end
function Session.finish(self, at: number): ()
	if self.phase ~= "active" then
		return
	end
	self.results = Ranking.stage(self.players, #Catalog.items(self.stage))
	for _, row in self.results do
		local p = self.players[row.id]
		if row.place then
			p.matchPoints += Ranking.points(row.place)
		end
		if #p.cargo > 0 then
			p.pendingLoss = true
		end
		Rules.lose(p)
	end
	self.phase = if self.stage == 3 then "summary" else "results"
	self.deadline = at + (if self.stage == 3 then 10 else 5)
	self.matchResults = Ranking.match(self.players)
	self.generation += 1
end
function Session.tick(self): ()
	local now = self.clock()
	for _ = 1, 8 do
		if self.phase == "idle" or now < self.deadline then
			break
		end
		local boundary = self.deadline
		if self.phase == "countdown" or self.phase == "summary" then
			self:beginRun(boundary)
		elseif self.phase == "active" then
			self:finish(boundary)
		elseif self.phase == "results" then
			self:beginStage(self.stage + 1, boundary)
		end
	end
	if self.phase == "active" and self.mode == "multi" and self:allComplete() then
		self:finish(now)
	end
end
function Session.advance(self, id: string): boolean
	self:tick()
	if
		not self.players[id]
		or self.phase ~= "active"
		or self.mode ~= "solo"
		or not self:allComplete()
	then
		return false
	end
	self:finish(self.clock())
	return true
end
function Session.playAgain(self, id: string): boolean
	self:tick()
	if not self.players[id] or self.phase ~= "summary" or self.mode ~= "solo" then
		return false
	end
	self.deadline = math.min(self.deadline, self.clock() + 3)
	return true
end
function Session.state(self)
	local remaining = math.max(0, math.ceil(self.deadline - self.clock()))
	return {
		id = self.roundId,
		roundId = self.roundId,
		stage = self.stage,
		phase = self.phase,
		mode = self.mode,
		open = self.phase == "active",
		remaining = remaining,
		deadline = self.deadline,
		warning = self.phase == "active" and remaining <= 15,
		canNext = self.phase == "active" and self.mode == "solo" and self:allComplete(),
		generation = self.generation,
	}
end
function Session.collect(self, id: string, itemId: number, x: number, y: number, z: number): boolean
	self:tick()
	local p = self.players[id]
	if not p or self.phase ~= "active" or not View.inWarehouse(x, y, z) then
		return false
	end
	local items = Catalog.items(self.stage)
	if View.nearest(items, p.collected, self.roundId, x, y, z) ~= itemId then
		return false
	end
	local item = items[itemId]
	if not item then
		return false
	end
	return Rules.collect(
		p,
		itemId,
		self.roundId,
		true,
		math.sqrt((x - item.x) ^ 2 + (y - 2.5) ^ 2 + (z - item.z) ^ 2)
	)
end
function Session.step(self, id: string, x: number, y: number, z: number)
	self:tick()
	local p = self.players[id]
	if not p then
		return { banked = 0, lost = false }
	end
	if self.phase ~= "active" then
		local lost = #p.cargo > 0
		Rules.lose(p)
		return { banked = 0, lost = lost, returnHome = true }
	end
	if View.inDeposit(x, y, z) then
		local amount, special = Rules.bank(p, self.clock() - self.startedAt)
		return { banked = amount, special = special, lost = false }
	end
	return { banked = 0, lost = false }
end
function Session.rows(self)
	return if self.phase == "active"
		then Ranking.stage(self.players, #Catalog.items(self.stage))
		else self.results
end
return Session
