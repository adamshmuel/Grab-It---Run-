--!strict
local Rules = require(game:GetService("ReplicatedStorage").GrabIt.Shared.GameRules)
local View = require(game:GetService("ReplicatedStorage").GrabIt.Shared.Presentation)
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
	model.Parent = character
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
	for i, id in p.cargo do
		piece(
			"Cargo",
			Vector3.new(0.75, 0.6, 0.75),
			Vector3.new(1.15, -1.2 + i * 0.62, 1.5),
			View.itemColors[Rules.items[id].zone]
		)
	end
	local style = View.style(p.coins)
	if style.tier > 0 then
		local color = Color3.fromRGB(table.unpack(style.color))
		for _, x in { 0.6, 1.7 } do
			piece("Frame", Vector3.new(0.08, 3.3, 0.08), Vector3.new(x, 0.65, 1.5), color)
		end
		for _, y in { -1, 2.3 } do
			piece("Frame", Vector3.new(1.1, 0.08, 0.08), Vector3.new(1.15, y, 1.5), color)
		end
	end
	return model
end
return Appearance
