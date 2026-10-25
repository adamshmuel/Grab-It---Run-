--!strict
local LoadProgress = {}
function LoadProgress.attempt(store, key: string, deadline: number, now: () -> number)
	if now() >= deadline then
		return nil, "expired"
	end
	local data = store:load(key)
	if now() >= deadline then
		if data then
			store:releaseProfile(key, data)
		end
		return nil, "expired"
	end
	return data, if data then "ready" else "waiting"
end
return table.freeze(LoadProgress)
