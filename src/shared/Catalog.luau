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
}
Catalog.stages = stages
local byStage: { { Item } } = {}
for stage, definition in stages do
	local items: { Item } = {}
	for row = 1, 15 do
		local kind = math.ceil(row / 3)
		local source = definition.kinds[kind]
		for _, x in { -12, 12 } do
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
	if stage == 3 then
		table.insert(
			items,
			table.freeze({
				id = 31,
				kind = 6,
				name = "Golden Reactor",
				weight = 14,
				value = 55,
				size = { 3.4, 3.8, 3.4 },
				x = 0,
				z = 114,
				special = true,
				model = 16,
			})
		)
	end
	byStage[stage] = table.freeze(items)
end
function Catalog.items(stage: number): { Item }
	return assert(byStage[stage], "Invalid stage")
end
return table.freeze(Catalog)
