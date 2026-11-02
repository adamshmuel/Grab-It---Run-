--!strict
local Gear = {}
function Gear.create(id: string): Model
	local model = Instance.new("Model")
	model.Name = "CarryingEquipment"
	local dark = Color3.fromRGB(28, 39, 55)
	local gold = Color3.fromRGB(236, 180, 62)
	local cream = Color3.fromRGB(229, 220, 190)
	local function part(name, size, position, color, parent, shape, rotation, material): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = CFrame.new(position) * (rotation or CFrame.identity)
		p.Color = color
		p.Shape = shape or Enum.PartType.Block
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = parent or model
		return p
	end
	-- A rounded rectangular profile, rather than an ellipsoid pretending to be a bag.
	local function rounded(name, size, center, radius, color, parent)
		local body =
			part(name, Vector3.new(size.X - radius * 2, size.Y, size.Z), center, color, parent)
		part(
			name .. "Fill",
			Vector3.new(size.X, size.Y - radius * 2, size.Z),
			center,
			color,
			parent
		)
		for _, x in { -1, 1 } do
			for _, y in { -1, 1 } do
				part(
					name .. "Corner",
					Vector3.new(size.Z, radius * 2, radius * 2),
					center + Vector3.new(x * (size.X / 2 - radius), y * (size.Y / 2 - radius), 0),
					color,
					parent,
					Enum.PartType.Cylinder,
					CFrame.Angles(0, math.pi / 2, 0)
				)
			end
		end
		return body
	end
	local function ribbon(name, a, b, width, color)
		local p = part(name, Vector3.new(width, (b - a).Magnitude, 0.09), (a + b) / 2, color)
		p.CFrame = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(math.pi / 2, 0, 0)
		return p
	end
	local function shoulderStraps(top, bottom, width)
		for _, x in { -width, width } do
			local points = {
				Vector3.new(x, top, 0.36),
				Vector3.new(x, top - 0.3, 0.48),
				Vector3.new(x, bottom + 0.25, 0.48),
				Vector3.new(x, bottom, 0.36),
			}
			for i = 1, #points - 1 do
				ribbon("ShoulderStrap", points[i], points[i + 1], 0.17, dark)
			end
		end
	end
	local function handle(y, width, color)
		part("Handle", Vector3.new(width, 0.12, 0.16), Vector3.new(0, y, 0.03), color)
		for _, x in { -width / 2 + 0.06, width / 2 - 0.06 } do
			part(
				"HandleMount",
				Vector3.new(0.12, 0.25, 0.16),
				Vector3.new(x, y - 0.13, 0.03),
				color
			)
		end
	end
	if id == "basic" then
		shoulderStraps(0.8, -0.8, 0.62)
		part("Support", Vector3.new(1.8, 0.18, 0.8), Vector3.new(0, -0.9, 0.12), dark)
		ribbon(
			"CrossBrace",
			Vector3.new(-0.62, 0.55, 0.32),
			Vector3.new(0.62, -0.65, 0.32),
			0.12,
			cream
		)
		ribbon(
			"CrossBrace",
			Vector3.new(0.62, 0.55, 0.32),
			Vector3.new(-0.62, -0.65, 0.32),
			0.12,
			cream
		)
		part("HarnessBuckle", Vector3.new(0.3, 0.24, 0.1), Vector3.new(0, -0.05, 0.24), gold)
	elseif id == "canvas" then
		local blue = Color3.fromRGB(46, 113, 181)
		rounded("SoftBag", Vector3.new(1.95, 2.2, 0.72), Vector3.new(0, -0.05, 0), 0.24, blue)
		shoulderStraps(0.85, -0.95, 0.6)
		handle(1.25, 0.64, dark)
		local pocket = Instance.new("Model")
		pocket.Name = "FrontPocket"
		pocket.Parent = model
		rounded(
			"PocketBody",
			Vector3.new(1.55, 0.88, 0.25),
			Vector3.new(0, -0.58, -0.43),
			0.13,
			Color3.fromRGB(63, 139, 204),
			pocket
		)
		part("PocketZipper", Vector3.new(1.23, 0.045, 0.035), Vector3.new(0, -0.19, -0.575), cream)
		part("ZipperPull", Vector3.new(0.07, 0.16, 0.035), Vector3.new(0.42, -0.26, -0.59), gold)
		part(
			"Buckle",
			Vector3.new(0.26, 0.19, 0.055),
			Vector3.new(0, -0.55, -0.59),
			Color3.fromRGB(220, 139, 65)
		)
		for _, x in { -0.72, 0.72 } do
			part(
				"CanvasTrim",
				Vector3.new(0.025, 0.64, 0.025),
				Vector3.new(x * 0.93, -0.58, -0.575),
				cream
			)
		end
		part("Opening", Vector3.new(1.35, 0.045, 0.035), Vector3.new(0, 0.83, -0.38), dark)
		part("UpperZipperPull", Vector3.new(0.07, 0.14, 0.04), Vector3.new(0.5, 0.76, -0.4), gold)
	elseif id == "field" then
		local green = Color3.fromRGB(67, 106, 73)
		rounded("TallPack", Vector3.new(1.65, 2.3, 0.72), Vector3.new(0, -0.12, 0), 0.18, green)
		shoulderStraps(0.8, -1.0, 0.52)
		part(
			"RolledLid",
			Vector3.new(1.75, 0.4, 0.4),
			Vector3.new(0, 1.06, 0),
			cream,
			nil,
			Enum.PartType.Cylinder
		)
		handle(1.3, 0.58, dark)
		for _, x in { -0.98, 0.98 } do
			rounded(
				"Pocket",
				Vector3.new(0.48, 0.78, 0.62),
				Vector3.new(x, -0.65, 0),
				0.11,
				Color3.fromRGB(43, 77, 53)
			)
			part("PocketFlap", Vector3.new(0.5, 0.16, 0.65), Vector3.new(x, -0.34, -0.025), green)
			part(
				"PocketFastener",
				Vector3.new(0.1, 0.25, 0.05),
				Vector3.new(x, -0.43, -0.36),
				cream
			)
		end
		for _, x in { -0.42, 0.42 } do
			part("YellowStrap", Vector3.new(0.13, 1.75, 0.07), Vector3.new(x, -0.13, -0.41), gold)
			part("StrapBuckle", Vector3.new(0.23, 0.2, 0.085), Vector3.new(x, 0.32, -0.46), dark)
			part("BuckleOpening", Vector3.new(0.11, 0.07, 0.02), Vector3.new(x, 0.32, -0.51), gold)
		end
	elseif id == "royal" then
		local purple = Color3.fromRGB(98, 57, 142)
		rounded("HardCase", Vector3.new(2.45, 1.55, 0.76), Vector3.new(0, -0.25, 0), 0.13, purple)
		shoulderStraps(0.35, -0.8, 0.72)
		handle(0.86, 0.9, dark)
		part("LidSeam", Vector3.new(2.18, 0.035, 0.035), Vector3.new(0, 0.12, -0.4), dark)
		for _, x in { -1.12, 1.12 } do
			for _, y in { -0.88, 0.38 } do
				part(
					"Corner",
					Vector3.new(0.2, 0.25, 0.83),
					Vector3.new(x, y, 0),
					gold,
					nil,
					nil,
					nil,
					Enum.Material.Metal
				)
			end
		end
		for _, x in { -0.73, 0.73 } do
			part(
				"Clasp",
				Vector3.new(0.23, 0.34, 0.09),
				Vector3.new(x, 0.08, -0.44),
				gold,
				nil,
				nil,
				nil,
				Enum.Material.Metal
			)
			part("Hinge", Vector3.new(0.3, 0.15, 0.06), Vector3.new(x, 0.13, 0.42), gold)
		end
		local gem = part(
			"DiamondClasp",
			Vector3.new(0.24, 0.24, 0.07),
			Vector3.new(0, -0.38, -0.43),
			Color3.fromRGB(63, 207, 193),
			nil,
			nil,
			CFrame.Angles(0, 0, math.pi / 4),
			Enum.Material.Glass
		)
		gem.Reflectance = 0.1
	else
		model:Destroy()
		error("Unknown equipment")
	end
	model.WorldPivot = CFrame.identity
	return model
end
return table.freeze(Gear)
