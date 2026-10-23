--!strict
local ItemVisibility = {}
function ItemVisibility.set(item: BasePart, hidden: boolean)
	item.LocalTransparencyModifier = if hidden then 1 else 0
	for _, child in item:GetDescendants() do
		if child:IsA("BasePart") then
			child.LocalTransparencyModifier = if hidden then 1 else 0
		end
	end
	local label = item:FindFirstChild("ValueLabel")
	if label and label:IsA("BillboardGui") then
		label.Enabled = not hidden
	end
end
return table.freeze(ItemVisibility)
