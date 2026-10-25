--!strict
local Cosmetics = {}
Cosmetics.list = {
	{ id = "basic", name = "Basic Harness", price = 0 },
	{ id = "canvas", name = "Canvas Bag", price = 100 },
	{ id = "field", name = "Field Pack", price = 350 },
	{ id = "royal", name = "Royal Case", price = 900 },
}
function Cosmetics.get(id: string)
	for _, style in Cosmetics.list do
		if style.id == id then
			return style
		end
	end
	return nil
end
function Cosmetics.legacy(coins: number)
	local owned = { basic = true }
	local selected = "basic"
	for index, threshold in { 30, 100, 300 } do
		if coins >= threshold then
			selected = Cosmetics.list[index + 1].id
			owned[selected] = true
		end
	end
	return owned, selected
end
function Cosmetics.equip(p, id: string): boolean
	if not Cosmetics.get(id) or not p.owned[id] then
		return false
	end
	if p.selected ~= id then
		p.selected = id
		p.revision += 1
	end
	return true
end
return table.freeze(Cosmetics)
