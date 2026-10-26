--!strict
local Visuals = {}
function Visuals.carryScale(item): number
	return math.max(0.45, 1.2 / math.max(table.unpack(item.size)))
end
local colors = {
	yellow = Color3.fromRGB(255, 205, 54),
	orange = Color3.fromRGB(255, 124, 46),
	red = Color3.fromRGB(234, 63, 76),
	blue = Color3.fromRGB(45, 134, 244),
	teal = Color3.fromRGB(35, 221, 202),
	white = Color3.fromRGB(245, 246, 230),
	dark = Color3.fromRGB(32, 43, 66),
	silver = Color3.fromRGB(183, 210, 224),
	green = Color3.fromRGB(63, 153, 93),
	purple = Color3.fromRGB(119, 65, 196),
	gold = Color3.fromRGB(255, 197, 62),
	wood = Color3.fromRGB(99, 51, 60),
}
local function build(index: number): Model
	local m = Instance.new("Model")
	m.Name = "Collectible"
	local function piece(
		name: string,
		size: Vector3,
		pos: Vector3,
		color: string,
		shape: string?,
		rotation: CFrame?
	): BasePart
		local p = Instance.new(if shape == "wedge" then "WedgePart" else "Part")
		if shape == "ball" or shape == "cylinder" then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = if shape == "ball" then Enum.MeshType.Sphere else Enum.MeshType.Cylinder
			mesh.Parent = p
		end
		p.Name = name
		p.Size = size
		p.Color = assert(colors[color], "Unknown model color")
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Material = if color == "gold" or color == "silver"
			then Enum.Material.Metal
			else Enum.Material.SmoothPlastic
		p.CFrame = CFrame.new(pos) * (rotation or CFrame.identity)
		p.Parent = m
		return p
	end
	local function b(name, x, y, z, px, py, pz, c, shape, rot)
		return piece(name, Vector3.new(x, y, z), Vector3.new(px, py, pz), c, shape, rot)
	end
	local vertical = CFrame.Angles(0, 0, math.pi / 2)
	if index == 1 then
		b("Body", 0.85, 0.65, 1, 0, 0.34, 0, "yellow", "ball")
		b("Head", 0.55, 0.55, 0.55, 0, 0.78, -0.27, "yellow", "ball")
		b("Beak", 0.4, 0.15, 0.35, 0, 0.71, -0.62, "orange")
		for _, x in { -0.27, 0.27 } do
			b("Eye", 0.075, 0.1, 0.1, x, 0.86, -0.4, "dark", "ball")
			b("Wing", 0.16, 0.36, 0.55, x * 1.5, 0.42, 0.05, "white", "ball")
		end
	elseif index == 2 then
		b("Body", 0.65, 0.55, 0.5, 0, 0.55, 0, "teal")
		b("Head", 0.85, 0.35, 0.65, 0, 1.02, 0, "silver")
		for _, x in { -0.47, 0.47 } do
			b("Arm", 0.2, 0.6, 0.24, x, 0.5, 0, "orange")
			b("Boot", 0.29, 0.22, 0.5, x * 0.45, 0.11, -0.04, "dark")
			b("Eye", 0.14, 0.12, 0.05, x * 0.4, 1.04, -0.35, "white")
		end
		b("Control", 0.2, 0.2, 0.06, 0, 0.6, -0.28, "red")
	elseif index == 3 then
		b("Drum", 0.8, 0.85, 0.85, 0, 0.45, 0, "red", "cylinder", vertical)
		for _, y in { 0.05, 0.9 } do
			b("Rim", 0.1, 1, 1, 0, y, 0, "white", "cylinder", vertical)
		end
		for _, x in { -0.35, 0.35 } do
			b("Strap", 0.09, 0.85, 0.08, x, 0.46, -0.38, "yellow")
		end
	elseif index == 4 then
		b("Body", 1.25, 0.3, 0.7, 0, 0.4, 0, "blue")
		b("Cabin", 0.65, 0.3, 0.6, 0, 0.69, 0, "white")
		b("Window", 0.4, 0.18, 0.62, 0, 0.71, 0, "teal")
		for _, x in { -0.4, 0.4 } do
			for _, z in { -0.38, 0.38 } do
				b(
					"Wheel",
					0.17,
					0.33,
					0.33,
					x,
					0.23,
					z,
					"dark",
					"cylinder",
					CFrame.Angles(0, math.pi / 2, 0)
				)
			end
		end
		b("Bumper", 0.1, 0.14, 0.65, -0.68, 0.35, 0, "orange")
	elseif index == 5 or index == 15 then
		local c = if index == 5 then "teal" else "wood"
		b("Body", 1.1, 0.65, 0.8, 0, 0.35, 0, c)
		b(
			"Lid",
			1.12,
			0.35,
			0.83,
			0,
			0.84,
			0,
			if index == 5 then "blue" else "wood",
			if index == 15 then "cylinder" else nil
		)
		for _, x in { -0.4, 0.4 } do
			b("Band", 0.12, 0.9, 0.86, x, 0.48, 0, if index == 5 then "orange" else "gold")
			b("Handle", 0.15, 0.25, 0.35, x * 1.55, 0.4, 0, "silver")
		end
		b("Clasp", 0.25, 0.3, 0.12, 0, 0.56, -0.47, "yellow")
		b(
			"Emblem",
			0.11,
			0.14,
			0.06,
			0,
			0.58,
			-0.55,
			if index == 5 then "white" else "teal",
			"wedge"
		)
	elseif index == 6 then
		b("TopArc", 0.85, 0.15, 0.3, 0, 1, 0, "silver")
		for _, x in { -0.47, 0.47 } do
			b("ArchSide", 0.15, 0.7, 0.3, x, 0.68, 0, "dark")
			b("EarCup", 0.32, 0.52, 0.45, x, 0.33, 0, "blue", "ball")
			b("Cushion", 0.12, 0.4, 0.35, x * 0.62, 0.33, 0, "teal", "ball")
		end
	elseif index == 7 then
		b("Body", 1, 0.65, 0.4, 0, 0.37, 0, "dark")
		b(
			"Lens",
			0.35,
			0.5,
			0.5,
			0,
			0.37,
			-0.38,
			"silver",
			"cylinder",
			CFrame.Angles(0, math.pi / 2, 0)
		)
		b(
			"Glass",
			0.04,
			0.38,
			0.38,
			0,
			0.37,
			-0.58,
			"teal",
			"cylinder",
			CFrame.Angles(0, math.pi / 2, 0)
		)
		b("Shutter", 0.2, 0.12, 0.2, 0.3, 0.76, 0, "red")
		b("Grip", 0.2, 0.6, 0.5, 0.55, 0.34, 0, "orange")
	elseif index == 8 then
		b("Housing", 0.65, 1.2, 0.5, 0, 0.62, 0, "dark")
		for _, y in { 0.32, 0.85 } do
			b(
				"Ring",
				0.12,
				0.48,
				0.48,
				0,
				y,
				-0.29,
				"orange",
				"cylinder",
				CFrame.Angles(0, math.pi / 2, 0)
			)
			b(
				"Cone",
				0.14,
				0.3,
				0.3,
				0,
				y,
				-0.36,
				"silver",
				"cylinder",
				CFrame.Angles(0, math.pi / 2, 0)
			)
		end
		b("Light", 0.2, 0.07, 0.05, 0, 1.17, -0.28, "teal")
	elseif index == 9 then
		b("Hub", 0.55, 0.25, 0.55, 0, 0.5, 0, "teal")
		for _, x in { -0.5, 0.5 } do
			for _, z in { -0.5, 0.5 } do
				b("Arm", 0.65, 0.12, 0.12, x / 2, 0.46, z, "silver")
				b("Rotor", 0.5, 0.06, 0.12, x, 0.64, z, "dark")
				b("Leg", 0.08, 0.35, 0.08, x, 0.23, z, "orange")
			end
		end
		b("Camera", 0.2, 0.18, 0.2, 0, 0.3, -0.3, "blue", "ball")
	elseif index == 10 then
		b("Tank", 0.8, 0.65, 0.65, 0, 0.55, 0, "orange", "cylinder")
		for _, x in { -0.56, 0.56 } do
			for _, z in { -0.4, 0.4 } do
				b("Frame", 0.08, 1.1, 0.08, x, 0.56, z, "dark")
			end
		end
		for _, y in { 0.05, 1.1 } do
			b("Crossbar", 1.2, 0.1, 0.9, 0, y, 0, "silver")
		end
		b("Handle", 0.55, 0.12, 0.12, 0, 1.3, 0, "teal")
		b("Pipe", 0.12, 0.5, 0.12, 0.25, 0.9, -0.3, "silver")
		for x = -0.3, 0.3, 0.15 do
			b("Grille", 0.06, 0.4, 0.05, x, 0.55, -0.43, "white")
		end
	elseif index == 11 then
		b("Base", 1, 0.15, 0.8, 0, 0.1, 0, "dark")
		for i, x in { -0.3, 0, 0.3 } do
			b(
				"Crystal",
				0.32,
				0.5 + i * 0.18,
				0.4,
				x,
				0.35 + i * 0.09,
				0,
				if i == 2 then "purple" else "teal",
				"wedge"
			)
		end
		b("Band", 0.7, 0.06, 0.45, 0, 0.22, 0, "gold")
	elseif index == 12 then
		b("Foot", 0.1, 0.8, 0.8, 0, 0.06, 0, "gold", "cylinder", vertical)
		b("Stem", 0.13, 0.9, 0.13, 0, 0.5, 0, "silver")
		b("Cup", 0.4, 0.7, 0.7, 0, 1.06, 0, "gold", "cylinder", vertical)
		for _, x in { -0.47, 0.47 } do
			b("Handle", 0.14, 0.45, 0.3, x, 0.95, 0, "gold", "ball")
		end
		b("Gem", 0.12, 0.15, 0.09, 0, 1.04, -0.38, "teal", "wedge")
	elseif index == 13 then
		b("Band", 0.25, 1, 1, 0, 0.18, 0, "gold", "cylinder", vertical)
		for _, x in { -0.4, 0, 0.4 } do
			b("Point", 0.22, 0.5, 0.22, x, 0.48, -0.35, "gold", "wedge")
			b("Gem", 0.12, 0.15, 0.08, x, 0.23, -0.5, if x == 0 then "red" else "teal", "ball")
		end
		b("Lining", 0.1, 0.72, 0.72, 0, 0.35, 0, "purple", "cylinder", vertical)
	elseif index == 14 then
		b("Plinth", 1, 0.18, 0.8, 0, 0.09, 0, "dark")
		b("Step", 0.8, 0.15, 0.65, 0, 0.25, 0, "gold")
		b("Body", 0.5, 0.7, 0.4, 0, 0.68, 0, "white")
		b("Head", 0.4, 0.4, 0.4, 0, 1.25, 0, "gold", "ball")
		for _, x in { -0.4, 0.4 } do
			b("Arm", 0.22, 0.6, 0.22, x, 0.74, 0, "gold")
		end
		b("Gem", 0.14, 0.2, 0.06, 0, 0.78, -0.25, "teal", "wedge")
	elseif index == 16 then
		b("Core", 1.25, 0.8, 0.8, 0, 0.8, 0, "teal", "cylinder", vertical)
		for _, y in { 0.25, 0.8, 1.4 } do
			b("Ring", 0.12, 1.1, 1.1, 0, y, 0, "gold", "cylinder", vertical)
		end
		for _, x in { -0.42, 0.42 } do
			for _, z in { -0.42, 0.42 } do
				b("Foot", 0.2, 0.3, 0.2, x, 0.1, z, "dark")
				b("Connector", 0.12, 0.75, 0.12, x, 0.67, z, "silver")
			end
		end
	else
		error("Unknown model")
	end
	m.WorldPivot = CFrame.identity
	return m
end
function Visuals.createItem(item, parent: Instance, transform: CFrame, scale: number?): Model
	local model = build(item.model)
	model.Name = item.name
	local target = Vector3.new(table.unpack(item.size))
	local low = Vector3.new(math.huge, math.huge, math.huge)
	local high = -low
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			local cf = part.CFrame
			local right, up, look = cf.RightVector, cf.UpVector, cf.LookVector
			local half = Vector3.new(
				math.abs(right.X) * part.Size.X
					+ math.abs(up.X) * part.Size.Y
					+ math.abs(look.X) * part.Size.Z,
				math.abs(right.Y) * part.Size.X
					+ math.abs(up.Y) * part.Size.Y
					+ math.abs(look.Y) * part.Size.Z,
				math.abs(right.Z) * part.Size.X
					+ math.abs(up.Z) * part.Size.Y
					+ math.abs(look.Z) * part.Size.Z
			) / 2
			low = low:Min(cf.Position - half)
			high = high:Max(cf.Position + half)
		end
	end
	local bounds = CFrame.new((low + high) / 2)
	local size = high - low
	local factor = target / size * (scale or 1)
	local finished = Instance.new("Model")
	finished.Name = item.name
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			local cf = part.CFrame
			local copy = part:Clone()
			copy.Size = part.Size
				* Vector3.new(
					(cf.RightVector * factor).Magnitude,
					(cf.UpVector * factor).Magnitude,
					(cf.LookVector * factor).Magnitude
				)
			copy.CFrame = transform
				* CFrame.new(
					(cf.Position - bounds.Position) * factor
						+ Vector3.new(0, target.Y * (scale or 1) / 2, 0)
				)
				* cf.Rotation
			copy.Parent = finished
		end
	end
	model:Destroy()
	model = finished
	model.WorldPivot = transform
	model.Parent = parent
	return model
end
return table.freeze(Visuals)
