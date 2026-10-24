--!strict
local Rules = require(game:GetService("ReplicatedStorage").GrabIt.Shared.GameRules)
local View = require(game:GetService("ReplicatedStorage").GrabIt.Shared.Presentation)
local Visuals = require(script.Parent.Visuals)
local Appearance = {}
function Appearance.update(character: Model, p: { coins: number, cargo: { number } }): Model?
	local center = character:FindFirstChild("HumanoidRootPart")
	if not center or not center:IsA("BasePart") then
		return
	end
	local previous = character:FindFirstChild("GrabItCargo")
	if previous then
		previous:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = "GrabItCargo"
	local function piece(name: string, size: Vector3, offset: Vector3, color: Color3)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.CFrame = center.CFrame * CFrame.new(offset)
		part.Parent = model
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = center
		weld.Part1 = part
		weld.Parent = part
	end
	local bottom, rowHeight = -1.4, 0
	for index, id in p.cargo do
		local cargo = Visuals.create(
			Rules.items[id].zone,
			model,
			center.CFrame * CFrame.new(if index % 2 == 1 then 1.5 else 2.65, bottom, 1.5),
			0.4
		)
		local _, size = cargo:GetBoundingBox()
		rowHeight = math.max(rowHeight, size.Y)
		if index % 2 == 0 then
			bottom += rowHeight + 0.08
			rowHeight = 0
		end
		for _, detail in cargo:GetDescendants() do
			if detail:IsA("BasePart") then
				detail.Anchored = false
				detail.Massless = true
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = center
				weld.Part1 = detail
				weld.Parent = detail
			end
		end
	end
	local style = View.style(p.coins)
	if style.tier > 0 then
		local color = Color3.fromRGB(table.unpack(style.color))
		for _, x in { 0.9, 3.25 } do
			piece("Frame", Vector3.new(0.08, 3.8, 0.08), Vector3.new(x, 0.45, 1.5), color)
		end
		for _, y in { -1.45, 2.35 } do
			piece("Frame", Vector3.new(2.35, 0.08, 0.08), Vector3.new(2.075, y, 1.5), color)
		end
	end
	model.Parent = character
	return model
end
return Appearance
