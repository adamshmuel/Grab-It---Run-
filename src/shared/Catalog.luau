--!strict
local Catalog = {}
export type Item = {
	id: number,
	kind: number,
	name: string,
	weight: number,
	value: number,
	size: { number },
	x: number,
	z: number,
	special: boolean,
	model: number,
}
local stages = {
	{
		name = "Toy Dash",
		seconds = 180,
		capacity = 10,
		kinds = {
			{ name = "Rubber Duck", weight = 1, value = 2, size = { 1.2, 1.2, 1.6 }, model = 1 },
			{ name = "Toy Robot", weight = 2, value = 3, size = { 1.5, 1.9, 1.3 }, model = 2 },
			{ name = "Toy Drum", weight = 3, value = 5, size = { 1.8, 1.6, 1.8 }, model = 3 },
			{ name = "Toy Car", weight = 4, value = 7, size = { 2.4, 1.3, 1.6 }, model = 4 },
			{ name = "Toy Chest", weight = 5, value = 10, size = { 2.5, 1.9, 1.8 }, model = 5 },
		},
	},
	{
		name = "Tech Run",
		seconds = 135,
		capacity = 14,
		kinds = {
			{ name = "Headphones", weight = 2, value = 3, size = { 1.8, 1.7, 1 }, model = 6 },
			{ name = "Camera", weight = 3, value = 5, size = { 1.8, 1.4, 1.2 }, model = 7 },
			{ name = "Speaker", weight = 4, value = 8, size = { 1.7, 2.3, 1.5 }, model = 8 },
			{ name = "Drone", weight = 6, value = 12, size = { 2.8, 1.2, 2.8 }, model = 9 },
			{ name = "Generator", weight = 8, value = 18, size = { 2.8, 2.6, 2.3 }, model = 10 },
		},
	},
	{
		name = "Golden Rush",
		seconds = 100,
		capacity = 18,
		kinds = {
			{ name = "Gem Cluster", weight = 3, value = 5, size = { 1.6, 1.9, 1.5 }, model = 11 },
			{ name = "Golden Goblet", weight = 4, value = 7, size = { 1.6, 2.2, 1.6 }, model = 12 },
			{ name = "Royal Crown", weight = 6, value = 11, size = { 2.3, 1.4, 2.3 }, model = 13 },
			{
				name = "Ancient Statue",
				weight = 8,
				value = 16,
				size = { 2.2, 2.7, 1.9 },
				model = 14,
			},
			{
				name = "Treasure Chest",
				weight = 10,
				value = 24,
				size = { 2.9, 2.2, 2.2 },
				model = 15,
			},
		},
	},
	{
		name = "Expedition Run",
		seconds = 80,
		capacity = 22,
		kinds = {
			{
				name = "Camping Lantern",
				weight = 4,
				value = 7,
				size = { 1.5, 2.2, 1.5 },
				model = 17,
			},
			{ name = "Binoculars", weight = 6, value = 12, size = { 2.2, 1.3, 1.7 }, model = 18 },
			{ name = "Hiking Boots", weight = 8, value = 18, size = { 2.2, 1.5, 2.1 }, model = 19 },
			{
				name = "Metal Detector",
				weight = 10,
				value = 25,
				size = { 2.3, 2.5, 1.8 },
				model = 20,
			},
			{ name = "Camping Tent", weight = 12, value = 34, size = { 3, 2.4, 3 }, model = 21 },
		},
	},
	{
		name = "Space Sprint",
		seconds = 60,
		capacity = 26,
		kinds = {
			{
				name = "Astronaut Helmet",
				weight = 5,
				value = 10,
				size = { 1.9, 1.9, 1.7 },
				model = 23,
			},
			{ name = "Moon Rover", weight = 7, value = 16, size = { 3, 2, 2.3 }, model = 24 },
			{ name = "Satellite", weight = 10, value = 25, size = { 3.2, 2, 2.6 }, model = 25 },
			{ name = "Mini Rocket", weight = 13, value = 37, size = { 2, 3.2, 2 }, model = 26 },
			{ name = "Lunar Lander", weight = 16, value = 52, size = { 3, 3, 3 }, model = 27 },
		},
	},
}
Catalog.stages = stages

export type Layout = { variant: number, flips: number }
local specials = {
	[3] = { name = "Golden Reactor", weight = 14, value = 55, size = { 3.4, 3.8, 3.4 }, model = 16 },
	[4] = {
		name = "Explorer Telescope",
		weight = 18,
		value = 80,
		size = { 3.4, 3.4, 3.4 },
		model = 22,
	},
	[5] = { name = "Flying Saucer", weight = 22, value = 110, size = { 3.8, 2.4, 3.8 }, model = 28 },
}
local variants: { [number]: { { number } } } = {}
local function twoTrips(stage: number, counts: { number }): boolean
	local definition = stages[stage]
	local remaining = if stage == 4 then 8 else 6
	local sums: { [number]: boolean } = { [0] = true }
	local total = 0
	for kind, count in counts do
		for _ = 1, math.min(count, remaining) do
			local weight = definition.kinds[kind].weight
			total += weight
			for sum = definition.capacity - weight, 0, -1 do
				if sums[sum] then
					sums[sum + weight] = true
				end
			end
		end
		remaining -= math.min(count, remaining)
		if remaining == 0 then
			break
		end
	end
	for sum in sums do
		if total - sum <= definition.capacity then
			return true
		end
	end
	return false
end
local function compositions(stage: number): { { number } }
	if variants[stage] then
		return variants[stage]
	end
	local definition = assert(stages[stage], "Invalid stage")
	local list = {}
	local baseWeight, baseValue = 0, 0
	for _, kind in definition.kinds do
		baseWeight += 6 * kind.weight
		baseValue += 6 * kind.value
	end
	for a = 2, 10 do
		for b = 2, 10 do
			for c = 2, 10 do
				for d = 2, 10 do
					local counts = { a, b, c, d, 30 - a - b - c - d }
					local seen, valid = {}, true
					local weight, value = 0, 0
					for kind, count in counts do
						if count < 2 or count > 10 or seen[count] then
							valid = false
							break
						end
						seen[count] = true
						weight += count * definition.kinds[kind].weight
						value += count * definition.kinds[kind].value
					end
					if
						valid
						and math.abs(weight - baseWeight) * 10 <= baseWeight
						and math.abs(value - baseValue) * 10 <= baseValue
						and (stage < 4 or twoTrips(stage, counts))
					then
						table.insert(list, table.freeze(counts))
					end
				end
			end
		end
	end
	variants[stage] = table.freeze(list)
	return variants[stage]
end
function Catalog.variantCount(stage: number): number
	return if stage == 1 then 1 else #compositions(stage)
end
function Catalog.nextLayout(stage: number, random: Random, previous: Layout?): Layout?
	if stage == 1 then
		return nil
	end
	local count = Catalog.variantCount(stage)
	local variant = random:NextInteger(1, count - (if previous then 1 else 0))
	if previous and variant >= previous.variant then
		variant += 1
	end
	return table.freeze({ variant = variant, flips = random:NextInteger(0, 32767) })
end
local baseline: { [number]: { Item } } = {}
local cached: { [number]: { layout: Layout, items: { Item } } } = {}
function Catalog.items(stage: number, layout: Layout?): { Item }
	local definition = assert(stages[stage], "Invalid stage")
	if not layout and baseline[stage] then
		return baseline[stage]
	end
	local last = cached[stage]
	if
		layout
		and last
		and last.layout.variant == layout.variant
		and last.layout.flips == layout.flips
	then
		return last.items
	end
	local counts = if layout
		then assert(compositions(stage)[layout.variant], "Invalid variant")
		else { 6, 6, 6, 6, 6 }
	local kinds = {}
	for kind, count in counts do
		for _ = 1, count do
			table.insert(kinds, kind)
		end
	end
	local items: { Item } = {}
	for row = 1, 15 do
		local flipped = layout ~= nil and bit32.band(layout.flips, 2 ^ (row - 1)) ~= 0
		for column, x in { -12, 12 } do
			local kind = kinds[(row - 1) * 2 + (if flipped then 3 - column else column)]
			local source = definition.kinds[kind]
			table.insert(
				items,
				table.freeze({
					id = #items + 1,
					kind = kind,
					name = source.name,
					weight = source.weight,
					value = source.value,
					size = source.size,
					x = x,
					z = 12 + (row - 1) * 6,
					special = false,
					model = source.model,
				})
			)
		end
	end
	local special = specials[stage]
	if special then
		table.insert(
			items,
			table.freeze({
				id = 31,
				kind = 6,
				name = special.name,
				weight = special.weight,
				value = special.value,
				size = special.size,
				x = 0,
				z = 114,
				special = true,
				model = special.model,
			})
		)
	end
	table.freeze(items)
	if layout then
		cached[stage] = { layout = layout, items = items }
	else
		baseline[stage] = items
	end
	return items
end
return table.freeze(Catalog)
