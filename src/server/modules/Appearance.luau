--!strict
local shared = game:GetService("ReplicatedStorage").GrabIt.Shared
local Catalog = require(shared.Catalog)
local Gear = require(shared.Gear)
local Visuals = require(script.Parent.Visuals)
local Appearance = {}
function Appearance.update(character: Model, p): Model?
	local center = character:FindFirstChild("HumanoidRootPart")
	if not center or not center:IsA("BasePart") then
		return nil
	end
	local old = character:FindFirstChild("GrabItCargo")
	if old then
		old:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = "GrabItCargo"
	local equipment = Gear.create(p.selected)
	equipment:PivotTo(center.CFrame * CFrame.new(0, 0, 1))
	equipment.Parent = model
	local shown = {}
	local special = nil
	local items = Catalog.items(p.stage)
	for _, id in p.cargo do
		if items[id].special then
			special = id
		end
	end
	if special then
		table.insert(shown, special)
	end
	for i = #p.cargo, 1, -1 do
		if #shown >= 3 then
			break
		end
		if p.cargo[i] ~= special then
			table.insert(shown, p.cargo[i])
		end
	end
	for index, id in shown do
		local item = items[id]
		local scale = Visuals.carryScale(item)
		local offset = if index == 3
			then Vector3.new(0, math.min(0.25, 0.9 - item.size[2] * scale), 1.65)
			else Vector3.new(if index == 1 then -0.9 else 0.9, -1.3, 1.7)
		Visuals.createItem(
			item,
			model,
			center.CFrame * CFrame.new(offset) * CFrame.Angles(0, math.pi, 0),
			scale
		)
	end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = center
			weld.Part1 = part
			weld.Parent = part
		end
	end
	if #p.cargo > #shown then
		local count = Instance.new("BillboardGui")
		count.Name = "ExtraCargo"
		count.Adornee = center
		count.Size = UDim2.fromOffset(70, 32)
		count.StudsOffset = Vector3.new(1.8, 0.3, 0)
		count.MaxDistance = 40
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.2
		label.BackgroundColor3 = Color3.fromRGB(24, 32, 51)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 22
		label.Text = "+" .. (#p.cargo - #shown)
		label.Parent = count
		count.Parent = model
	end
	model.Parent = character
	return model
end
return table.freeze(Appearance)
