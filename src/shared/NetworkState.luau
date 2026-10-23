--!strict
local NetworkState = {}

function NetworkState.packCollected(collected: { [number]: boolean }): { [string]: boolean }
	local packed = {}
	for id, value in collected do
		if value then
			packed[tostring(id)] = true
		end
	end
	return packed
end

function NetworkState.unpackCollected(packed: { [string]: boolean }): { [number]: boolean }
	local collected = {}
	for key, value in packed do
		local id = tonumber(key)
		if id and value == true then
			collected[id] = true
		end
	end
	return collected
end

return table.freeze(NetworkState)
