--!strict
local View = {}
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
	local focus = position + Vector3.new(0, 2, 0)
	return CFrame.lookAt(focus + Vector3.new(0, 5, -14).Unit * 14, focus)
end
function View.collectionTarget(items, state, position: Vector3?): number?
	if
		not state.ready
		or not state.open
		or not position
		or not View.inWarehouse(position.X, position.Y, position.Z)
	then
		return nil
	end
	return View.nearest(items, state.collected, state.roundId, position.X, position.Y, position.Z)
end
return table.freeze(View)
