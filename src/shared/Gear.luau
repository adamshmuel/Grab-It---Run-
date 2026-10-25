--!strict
local Gear = {}
function Gear.create(id: string): Model
	local m = Instance.new("Model")
	m.Name = "CarryingEquipment"
	local function part(
		name: string,
		size: Vector3,
		pos: Vector3,
		color: Color3,
		round: boolean?
	): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Position = pos
		p.Color = color
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.Material = Enum.Material.SmoothPlastic
		if round then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = p
		end
		p.Parent = m
		return p
	end
	local dark = Color3.fromRGB(34, 42, 64)
	local gold = Color3.fromRGB(255, 199, 57)
	local white = Color3.fromRGB(234, 239, 219)
	for _, x in { -0.65, 0.65 } do
		part("ShoulderStrap", Vector3.new(0.15, 1.9, 0.16), Vector3.new(x, 0, -0.4), dark)
	end
	if id == "basic" then
		part("Support", Vector3.new(1.8, 0.18, 0.8), Vector3.new(0, -0.9, 0), dark)
	elseif id == "canvas" then
		part(
			"SoftBag",
			Vector3.new(1.9, 2, 0.95),
			Vector3.new(0, 0, 0),
			Color3.fromRGB(52, 137, 226),
			true
		)
		part("Opening", Vector3.new(1.5, 0.12, 0.7), Vector3.new(0, 0.84, 0), dark)
		part(
			"Buckle",
			Vector3.new(0.45, 0.35, 0.15),
			Vector3.new(0, 0.2, -0.52),
			Color3.fromRGB(255, 137, 49)
		)
		for _, x in { -0.6, 0.6 } do
			part("CanvasTrim", Vector3.new(0.1, 1.6, 0.1), Vector3.new(x, -0.1, -0.48), white)
		end
	elseif id == "field" then
		part(
			"TallPack",
			Vector3.new(1.7, 2.5, 0.9),
			Vector3.new(0, -0.05, 0),
			Color3.fromRGB(55, 139, 85)
		)
		part("RolledLid", Vector3.new(1.8, 0.45, 1), Vector3.new(0, 1.1, 0), white, true)
		for _, x in { -0.95, 0.95 } do
			part(
				"Pocket",
				Vector3.new(0.65, 0.85, 0.85),
				Vector3.new(x, -0.5, 0),
				Color3.fromRGB(38, 98, 66),
				true
			)
		end
		for _, x in { -0.4, 0.4 } do
			part("YellowStrap", Vector3.new(0.13, 2.1, 0.1), Vector3.new(x, -0.1, -0.5), gold)
		end
	elseif id == "royal" then
		part(
			"HardCase",
			Vector3.new(2.5, 1.55, 0.95),
			Vector3.new(0, -0.3, 0),
			Color3.fromRGB(116, 62, 172)
		)
		for _, x in { -1.17, 1.17 } do
			for _, y in { -0.98, 0.38 } do
				part("Corner", Vector3.new(0.2, 0.2, 1.05), Vector3.new(x, y, 0), gold)
			end
		end
		part("Handle", Vector3.new(0.8, 0.16, 0.25), Vector3.new(0, 0.7, 0), dark)
		for _, x in { -0.35, 0.35 } do
			part("HandleMount", Vector3.new(0.1, 0.35, 0.2), Vector3.new(x, 0.55, 0), gold)
		end
		local clasp = part(
			"DiamondClasp",
			Vector3.new(0.32, 0.32, 0.12),
			Vector3.new(0, -0.2, -0.54),
			Color3.fromRGB(52, 224, 205)
		)
		clasp.CFrame *= CFrame.Angles(0, 0, math.pi / 4)
	else
		m:Destroy()
		error("Unknown equipment")
	end
	m.WorldPivot = CFrame.identity
	return m
end
return table.freeze(Gear)
