--!strict
local Cosmetics = require(script.Parent.Cosmetics)
local Persistence = {}
Persistence.__index = Persistence
local function integer(n: any): boolean
	return type(n) == "number" and n >= 0 and n <= 1e12 and n % 1 == 0
end
local function valid(old: any): boolean
	if type(old) ~= "table" or not integer(old.coins) or type(old.tutorial) ~= "boolean" then
		return false
	end
	if
		old.owner ~= nil
		and (
			type(old.owner) ~= "string"
			or type(old.expires) ~= "number"
			or old.expires ~= old.expires
			or math.abs(old.expires) == math.huge
		)
	then
		return false
	end
	if old.version == 1 then
		return true
	end
	if
		old.version ~= 2
		or not integer(old.revision)
		or type(old.owned) ~= "table"
		or old.owned.basic ~= true
		or type(old.selected) ~= "string"
		or not old.owned[old.selected]
	then
		return false
	end
	for id, value in old.owned do
		if type(id) ~= "string" or not Cosmetics.get(id) or value ~= true then
			return false
		end
	end
	local transaction = old.lastTransaction
	if
		transaction ~= nil
		and (
			type(transaction) ~= "table"
			or type(transaction.id) ~= "string"
			or #transaction.id > 64
			or type(transaction.style) ~= "string"
			or not Cosmetics.get(transaction.style)
			or not integer(transaction.revision)
			or transaction.revision > old.revision
			or not integer(transaction.coins)
		)
	then
		return false
	end
	return true
end
local function upgrade(old)
	if old.version == 2 then
		return table.clone(old)
	end
	local owned, selected = Cosmetics.legacy(old.coins)
	return {
		version = 2,
		coins = old.coins,
		tutorial = old.tutorial,
		owned = owned,
		selected = selected,
		revision = 0,
		owner = old.owner,
		expires = old.expires,
	}
end
local function profile(data)
	return {
		version = 2,
		coins = data.coins,
		tutorial = data.tutorial,
		owned = table.clone(data.owned),
		selected = data.selected,
		revision = data.revision,
	}
end
local function same(a, b): boolean
	if a.coins ~= b.coins or a.tutorial ~= b.tutorial or a.selected ~= b.selected then
		return false
	end
	for _, style in Cosmetics.list do
		if a.owned[style.id] ~= b.owned[style.id] then
			return false
		end
	end
	return true
end
function Persistence.new(update, token: string, now: () -> number)
	return setmetatable(
		{ update = update, token = token, now = now, loaded = {}, busy = {} },
		Persistence
	)
end
function Persistence.owns(self, old): boolean
	return valid(old) and old.owner == self.token and old.expires > self.now()
end
function Persistence.load(self, key: string)
	if self.busy[key] then
		return nil
	end
	self.busy[key] = true
	local ok, result = pcall(self.update, key, function(old)
		if old == nil then
			old = {
				version = 2,
				coins = 0,
				tutorial = false,
				owned = { basic = true },
				selected = "basic",
				revision = 0,
			}
		end
		if
			not valid(old) or (old.owner and old.owner ~= self.token and old.expires > self.now())
		then
			return nil
		end
		local nextValue = upgrade(old)
		nextValue.owner = self.token
		nextValue.expires = self.now() + 120
		return nextValue
	end)
	self.busy[key] = nil
	if ok and result and result.owner == self.token then
		self.loaded[key] = true
		return result
	end
	return nil
end
function Persistence.writeProfile(self, key: string, data, release: boolean): boolean
	local incoming = profile(data)
	if not self.loaded[key] or self.busy[key] or not valid(incoming) then
		return false
	end
	self.busy[key] = true
	local ok, result = pcall(self.update, key, function(old)
		if
			not self:owns(old)
			or old.version ~= 2
			or incoming.revision < old.revision
			or (incoming.revision == old.revision and not same(incoming, old))
		then
			return nil
		end
		local nextValue = profile(incoming)
		nextValue.lastTransaction = old.lastTransaction
		nextValue.owner = if release then nil else self.token
		nextValue.expires = if release then nil else self.now() + 120
		return nextValue
	end)
	self.busy[key] = nil
	if ok and result and result.revision == incoming.revision and same(result, incoming) then
		if release then
			self.loaded[key] = nil
		end
		return true
	end
	return false
end
function Persistence.saveProfile(self, key: string, data): boolean
	return self:writeProfile(key, data, false)
end
function Persistence.releaseProfile(self, key: string, data): boolean
	return self:writeProfile(key, data, true)
end
function Persistence.purchase(self, key: string, id: string, data, transaction: string)
	local style = Cosmetics.get(id)
	if not style or not self.loaded[key] or self.busy[key] or not valid(profile(data)) then
		return "rejected", nil
	end
	self.busy[key] = true
	local rejection = "pending"
	local ok, result = pcall(self.update, key, function(old)
		if not self:owns(old) or old.version ~= 2 then
			return nil
		end
		if old.lastTransaction and old.lastTransaction.id == transaction then
			return old
		end
		if old.owned[id] then
			rejection = "owned"
			return nil
		end
		if
			data.revision < old.revision or (data.revision == old.revision and not same(data, old))
		then
			return nil
		end
		if data.coins < style.price then
			rejection = "insufficient"
			return nil
		end
		local nextValue = profile(data)
		nextValue.coins -= style.price
		nextValue.owned[id] = true
		nextValue.revision += 1
		nextValue.owner = self.token
		nextValue.expires = self.now() + 120
		nextValue.lastTransaction =
			{ id = transaction, style = id, revision = nextValue.revision, coins = nextValue.coins }
		return nextValue
	end)
	self.busy[key] = nil
	if not ok then
		return "pending", nil
	end
	if
		result
		and result.owner == self.token
		and result.lastTransaction
		and result.lastTransaction.id == transaction
	then
		return "confirmed", result
	end
	return rejection, nil
end
return Persistence
