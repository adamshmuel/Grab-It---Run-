--!strict
local View = {}
local tiers = {
	{ threshold = 30, name = "Copper", color = { 184, 115, 51 } },
	{ threshold = 100, name = "Silver", color = { 195, 211, 220 } },
	{ threshold = 300, name = "Gold", color = { 255, 201, 63 } },
}
function View.style(coins: number)
	local tier = 0
	for id, entry in tiers do
		if coins >= entry.threshold then
			tier = id
		end
	end
	return {
		tier = tier,
		name = if tier == 0 then "Starter" else tiers[tier].name,
		color = if tier == 0 then { 90, 125, 140 } else tiers[tier].color,
		target = if tier < #tiers then tiers[tier + 1].threshold else nil,
		nextName = if tier < #tiers then tiers[tier + 1].name else nil,
	}
end
function View.inWarehouse(x: number, y: number, z: number): boolean
	return math.abs(x) <= 24 and y >= 0 and y <= 20 and z > 0 and z <= 120
end
function View.inDeposit(x: number, y: number, z: number): boolean
	return math.abs(x) <= 8 and y >= 0 and y <= 10 and z >= -12 and z <= -4
end
function View.nearest(items, collected, _roundId: number, x: number, y: number, z: number): number?
	local best, distance = nil, math.huge
	for _, item in items do
		if not collected[item.id] then
			local d = (x - item.x) ^ 2 + (y - 2.5) ^ 2 + (z - item.z) ^ 2
			local previous = if best then items[best] else nil
			if
				d <= 36
				and (
					d < distance
					or (
						d == distance
						and previous
						and (item.z < previous.z or (item.z == previous.z and item.x < previous.x))
					)
				)
			then
				best = item.id
				distance = d
			end
		end
	end
	return best
end
function View.camera(position: Vector3): CFrame
	return CFrame.lookAt(position + Vector3.new(0, 7, -14), position + Vector3.new(0, 2, 6))
end
return table.freeze(View)
