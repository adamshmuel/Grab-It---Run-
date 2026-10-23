--!strict
local templates = game:GetService("ServerStorage"):WaitForChild("GrabItModels", 10)
assert(templates, "Collectible models missing from Rojo mapping")
local names = { "WoodCrate", "ToolCase", "EnergyCanister" }
local Visuals = {}
function Visuals.create(zone: number, parent: Instance, transform: CFrame, scale: number?): Model
	local source = templates:FindFirstChild(names[zone])
	assert(source and source:IsA("Model"), "Unknown collectible family")
	local model = source:Clone()
	model.WorldPivot = CFrame.identity
	model:ScaleTo(scale or 1)
	model:PivotTo(transform)
	model.Parent = parent
	return model
end
return table.freeze(Visuals)
