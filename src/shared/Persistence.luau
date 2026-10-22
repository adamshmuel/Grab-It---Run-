--!strict
local Persistence = {}
Persistence.__index = Persistence
export type Record = {
	version: number,
	coins: number,
	tutorial: boolean,
	owner: string?,
	expires: number?,
}
local function valid(record: any): boolean
	return type(record) == "table"
		and record.version == 1
		and type(record.coins) == "number"
		and record.coins >= 0
		and record.coins <= 1e12
		and record.coins % 1 == 0
		and type(record.tutorial) == "boolean"
		and (
			record.owner == nil
			or (
				type(record.owner) == "string"
				and type(record.expires) == "number"
				and record.expires == record.expires
			)
		)
end
function Persistence.new(update: (string, (any) -> any) -> any, token: string, now: () -> number)
	return setmetatable(
		{ update = update, token = token, now = now, loaded = {} :: { [string]: boolean } },
		Persistence
	)
end
function Persistence.load(self, key: string): Record?
	local now = self.now()
	local ok, result = pcall(self.update, key, function(old)
		if old == nil then
			old = { version = 1, coins = 0, tutorial = false }
		end
		if not valid(old) or (old.owner and old.owner ~= self.token and old.expires > now) then
			return nil
		end
		return {
			version = 1,
			coins = old.coins,
			tutorial = old.tutorial,
			owner = self.token,
			expires = now + 120,
		}
	end)
	if ok and result and result.owner == self.token then
		self.loaded[key] = true
		return result
	end
	return nil
end
function Persistence.write(
	self,
	key: string,
	coins: number,
	tutorial: boolean,
	release: boolean
): boolean
	if not self.loaded[key] or not valid({ version = 1, coins = coins, tutorial = tutorial }) then
		return false
	end
	local now = self.now()
	local ok, result = pcall(self.update, key, function(old)
		if not valid(old) or old.owner ~= self.token or old.expires <= now then
			return nil
		end
		return {
			version = 1,
			coins = math.max(old.coins, coins),
			tutorial = old.tutorial or tutorial,
			owner = if release then nil else self.token,
			expires = if release then nil else now + 120,
		}
	end)
	if not ok or not result then
		return false
	end
	if release then
		self.loaded[key] = nil
	end
	return result.coins >= coins and (release or result.owner == self.token)
end
function Persistence.save(self, key: string, coins: number, tutorial: boolean): boolean
	return self:write(key, coins, tutorial, false)
end
function Persistence.release(self, key: string, coins: number, tutorial: boolean): boolean
	return self:write(key, coins, tutorial, true)
end
return Persistence
