--!strict
local Visuals = {}
local colors = {
	yellow = Color3.fromRGB(255, 205, 54),
	yellowLight = Color3.fromRGB(255, 218, 83),
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
		local p = Instance.new(
			if shape == "wedge"
				then "WedgePart"
				elseif shape == "corner" then "CornerWedgePart"
				else "Part"
		)
		if shape == "ball" then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = p
		elseif shape == "cylinder" then
			p.Shape = Enum.PartType.Cylinder
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
	local front = CFrame.Angles(0, math.pi / 2, 0)
	local function ring(name, radius, y, thickness, height, color)
		for i = 0, 7 do
			local angle = i * math.pi / 4
			b(
				name,
				2 * radius * math.tan(math.pi / 8) + 0.02,
				height,
				thickness,
				math.sin(angle) * radius,
				y,
				math.cos(angle) * radius,
				color,
				nil,
				CFrame.Angles(0, angle, 0)
			)
		end
	end
	local function point(name, width, height, depth, center: Vector3, color, rotation: CFrame?)
		local frame = CFrame.new(center) * (rotation or CFrame.identity)
		for _, sign in { -1, 1 } do
			local cf = frame
				* CFrame.new(sign * width / 4, 0, 0)
				* CFrame.Angles(0, -sign * math.pi / 2, 0)
			piece(
				name,
				Vector3.new(depth, height, width / 2),
				cf.Position,
				color,
				"wedge",
				cf.Rotation
			)
		end
	end
	if index == 1 then
		b("Body", 0.85, 0.65, 1, 0, 0.34, 0, "yellow", "ball")
		b("Head", 0.57, 0.57, 0.57, 0, 0.79, -0.27, "yellow", "ball")
		b("Beak", 0.43, 0.13, 0.36, 0, 0.72, -0.62, "orange", "ball")
		b("BillSeam", 0.3, 0.025, 0.22, 0, 0.69, -0.68, "wood")
		b("Tail", 0.3, 0.28, 0.35, 0, 0.45, 0.45, "yellow", "wedge")
		for _, x in { -0.27, 0.27 } do
			b("Eye", 0.075, 0.1, 0.1, x, 0.86, -0.4, "dark", "ball")
			b("EyeGlint", 0.025, 0.03, 0.025, x, 0.88, -0.445, "white", "ball")
			b("Wing", 0.14, 0.3, 0.5, x * 1.5, 0.43, 0.05, "yellowLight", "ball")
		end
	elseif index == 2 then
		b("Body", 0.65, 0.55, 0.5, 0, 0.55, 0, "teal")
		b("Neck", 0.22, 0.16, 0.22, 0, 0.85, 0, "dark")
		b("Head", 0.85, 0.38, 0.65, 0, 1.04, 0, "silver")
		b("Visor", 0.69, 0.24, 0.035, 0, 1.07, -0.345, "dark")
		b("Mouth", 0.22, 0.035, 0.045, 0, 0.95, -0.35, "dark")
		for _, x in { -0.47, 0.47 } do
			b("Shoulder", 0.25, 0.25, 0.25, x * 0.78, 0.72, 0, "dark", "ball")
			b("Arm", 0.2, 0.51, 0.24, x, 0.47, 0, "orange")
			b("Hand", 0.25, 0.23, 0.28, x, 0.2, -0.03, "silver")
			b("Leg", 0.15, 0.25, 0.2, x * 0.45, 0.25, 0, "orange")
			b("Boot", 0.29, 0.22, 0.5, x * 0.45, 0.11, -0.04, "dark")
			b("Eye", 0.14, 0.12, 0.05, x * 0.4, 1.08, -0.38, "white")
		end
		b("Antenna", 0.07, 0.17, 0.07, 0, 1.29, 0, "dark")
		b("AntennaTip", 0.15, 0.15, 0.15, 0, 1.4, 0, "red", "ball")
		b("Control", 0.27, 0.2, 0.06, 0, 0.6, -0.28, "dark")
		for _, x in { -0.07, 0.07 } do
			b("Button", 0.06, 0.06, 0.04, x, 0.6, -0.33, "red", "ball")
		end
	elseif index == 3 then
		b("Drum", 0.8, 0.85, 0.85, 0, 0.45, 0, "red", "cylinder", vertical)
		for _, y in { 0.05, 0.88 } do
			b("Rim", 0.09, 1, 1, 0, y, 0, "silver", "cylinder", vertical)
		end
		b("DrumSkin", 0.08, 0.87, 0.87, 0, 0.94, 0, "white", "cylinder", vertical)
		for i = 0, 5 do
			local angle = i * math.pi / 3
			b(
				"TensionRod",
				0.055,
				0.64,
				0.055,
				math.sin(angle) * 0.43,
				0.46,
				math.cos(angle) * 0.43,
				"yellow"
			)
		end
		for _, angle in { -0.45, 0.45 } do
			b(
				"Drumstick",
				0.08,
				0.08,
				0.75,
				angle * 0.25,
				1.0,
				0,
				"wood",
				nil,
				CFrame.Angles(0, angle, 0)
			)
		end
	elseif index == 4 then
		b("Body", 1.25, 0.3, 0.7, 0, 0.4, 0, "blue")
		b("Hood", 0.4, 0.25, 0.68, -0.48, 0.45, 0, "blue", "ball")
		b("Cabin", 0.65, 0.3, 0.6, 0, 0.69, 0, "white")
		b("Window", 0.4, 0.18, 0.62, 0, 0.71, 0, "teal")
		b("WindowPillar", 0.055, 0.23, 0.65, 0, 0.71, 0, "white")
		for _, x in { -0.4, 0.4 } do
			for _, z in { -0.38, 0.38 } do
				b("Wheel", 0.17, 0.35, 0.35, x, 0.23, z, "dark", "cylinder", front)
				b("Hubcap", 0.035, 0.2, 0.2, x, 0.23, z * 1.25, "silver", "cylinder", front)
			end
		end
		b("Bumper", 0.1, 0.14, 0.65, -0.69, 0.35, 0, "silver")
		for _, z in { -0.23, 0.23 } do
			b("Headlight", 0.04, 0.12, 0.13, -0.71, 0.48, z, "yellow")
			b("TailLight", 0.04, 0.1, 0.14, 0.64, 0.43, z, "red")
		end
	elseif index == 5 or index == 15 then
		local treasure = index == 15
		local main = if treasure then "wood" else "teal"
		local trim = if treasure then "gold" else "orange"
		local body = b("Body", 1.1, 0.65, 0.8, 0, 0.35, 0, main)
		local lid = b(
			"Lid",
			1.12,
			if treasure then 0.57 else 0.2,
			0.83,
			0,
			if treasure then 0.72 else 0.76,
			0,
			if treasure then "wood" else "blue",
			if treasure then "cylinder" else nil
		)
		if treasure then
			body.Material = Enum.Material.Wood
			lid.Material = Enum.Material.Wood
		end
		for _, x in { -0.4, 0.4 } do
			b("Band", 0.1, 0.66, 0.84, x, 0.36, 0, trim)
			if treasure then
				for i = 0, 5 do
					local angle = i * math.pi / 5
					b(
						"LidBand",
						0.1,
						0.08,
						0.24,
						x,
						0.72 + math.sin(angle) * 0.29,
						math.cos(angle) * 0.42,
						trim,
						nil,
						CFrame.Angles(-angle, 0, 0)
					)
				end
			else
				b("LidBand", 0.1, 0.12, 0.85, x, 0.8, 0, trim)
			end
			b("Handle", 0.1, 0.11, 0.3, x * 1.5, 0.43, 0, "silver")
			for _, z in { -0.12, 0.12 } do
				b("HandleMount", 0.1, 0.14, 0.07, x * 1.4, 0.5, z, "silver")
			end
			b("Hinge", 0.2, 0.2, 0.07, x, 0.67, 0.45, "silver")
		end
		b("Clasp", 0.25, 0.32, 0.1, 0, 0.55, -0.46, trim)
		b("Keyhole", 0.065, 0.1, 0.025, 0, 0.56, -0.525, "dark")
		for _, x in { -0.45, 0.45 } do
			for _, y in { 0.14, 0.54 } do
				b("Rivet", 0.045, 0.045, 0.03, x, y, -0.44, "silver", "ball")
			end
		end
	elseif index == 6 then
		for i = 0, 6 do
			local angle = i * math.pi / 6
			b(
				"TopArc",
				0.26,
				0.12,
				0.28,
				math.cos(angle) * 0.48,
				0.55 + math.sin(angle) * 0.48,
				0,
				"silver",
				nil,
				CFrame.Angles(0, 0, angle + math.pi / 2)
			)
		end
		for _, x in { -0.48, 0.48 } do
			b("EarCup", 0.26, 0.5, 0.44, x, 0.31, 0, "blue", "cylinder")
			b("Cushion", 0.12, 0.4, 0.34, x * 0.64, 0.31, 0, "dark", "ball")
			b("EarPlate", 0.04, 0.31, 0.27, x * 1.31, 0.31, 0, "teal", "cylinder")
		end
	elseif index == 7 then
		b("Body", 1, 0.65, 0.4, 0, 0.37, 0, "dark")
		b("Lens", 0.35, 0.5, 0.5, 0, 0.37, -0.38, "silver", "cylinder", front)
		b("FocusRing", 0.1, 0.55, 0.55, 0, 0.37, -0.5, "dark", "cylinder", front)
		b("Glass", 0.04, 0.38, 0.38, 0, 0.37, -0.58, "teal", "cylinder", front)
		b("LensGlint", 0.035, 0.08, 0.1, -0.07, 0.46, -0.61, "white", "cylinder", front)
		b("Viewfinder", 0.3, 0.18, 0.28, 0, 0.72, 0, "silver")
		b("Flash", 0.2, 0.12, 0.04, -0.3, 0.61, -0.23, "white")
		b("ShutterMount", 0.21, 0.1, 0.21, 0.3, 0.7, 0, "dark")
		b("Shutter", 0.17, 0.1, 0.17, 0.3, 0.79, 0, "red")
		b("Grip", 0.22, 0.62, 0.48, 0.49, 0.36, -0.02, "orange")
	elseif index == 8 then
		b("Housing", 0.65, 1.2, 0.5, 0, 0.62, 0, "dark")
		b("SidePanel", 0.035, 1.1, 0.46, -0.34, 0.62, 0, "blue")
		for _, y in { 0.35, 0.88 } do
			local diameter = if y < 0.5 then 0.49 else 0.35
			b("Ring", 0.07, diameter, diameter, 0, y, -0.29, "orange", "cylinder", front)
			b(
				"Cone",
				0.09,
				diameter * 0.8,
				diameter * 0.8,
				0,
				y,
				-0.35,
				"silver",
				"cylinder",
				front
			)
			b(
				"DustCap",
				0.05,
				diameter * 0.4,
				diameter * 0.4,
				0,
				y,
				-0.42,
				"dark",
				"cylinder",
				front
			)
		end
		b("Light", 0.2, 0.045, 0.035, 0, 1.17, -0.28, "teal")
		for _, x in { -0.2, 0.2 } do
			b("Foot", 0.16, 0.08, 0.35, x, 0.03, 0, "dark")
		end
	elseif index == 9 then
		b("Hub", 0.68, 0.3, 0.58, 0, 0.5, 0, "white", "ball")
		b("Battery", 0.34, 0.08, 0.4, 0, 0.64, 0.03, "teal")
		for _, x in { -0.5, 0.5 } do
			for _, z in { -0.5, 0.5 } do
				b(
					"Arm",
					math.sqrt(x * x + z * z),
					0.11,
					0.14,
					x / 2,
					0.49,
					z / 2,
					"silver",
					nil,
					CFrame.Angles(0, -math.atan2(z, x), 0)
				)
				b("Motor", 0.16, 0.2, 0.2, x, 0.61, z, "dark", "cylinder", vertical)
				for _, angle in { math.pi / 4, -math.pi / 4 } do
					b(
						"Rotor",
						0.64,
						0.035,
						0.1,
						x,
						0.72,
						z,
						"dark",
						nil,
						CFrame.Angles(0, angle, 0)
					)
				end
				b("RotorCap", 0.065, 0.11, 0.11, x, 0.75, z, "orange", "cylinder", vertical)
			end
		end
		for _, x in { -0.28, 0.28 } do
			b("Skid", 0.09, 0.07, 0.75, x, 0.06, 0, "dark")
			for _, z in { -0.25, 0.25 } do
				b("Leg", 0.07, 0.27, 0.07, x, 0.22, z, "silver")
			end
		end
		b("Camera", 0.22, 0.22, 0.22, 0, 0.3, -0.26, "silver", "ball")
		b("CameraLens", 0.08, 0.14, 0.14, 0, 0.3, -0.4, "blue", "cylinder", front)
	elseif index == 10 then
		for _, x in { -0.56, 0.56 } do
			for _, z in { -0.4, 0.4 } do
				b("Frame", 0.09, 1.1, 0.09, x, 0.62, z, "dark")
			end
			b("Skid", 0.13, 0.1, 1, x, 0.07, 0, "dark")
			b("TopRail", 0.09, 0.09, 0.89, x, 1.15, 0, "dark")
		end
		for _, z in { -0.4, 0.4 } do
			b("Crossbar", 1.2, 0.09, 0.09, 0, 0.1, z, "dark")
		end
		b("Engine", 0.78, 0.55, 0.6, 0, 0.46, 0, "silver")
		b("Tank", 0.97, 0.25, 0.62, 0, 0.91, 0, "orange")
		b("FuelCap", 0.07, 0.17, 0.17, 0.2, 1.07, 0, "dark", "cylinder", vertical)
		b("Controls", 0.9, 0.37, 0.08, 0, 0.54, -0.36, "blue")
		b("VoltageGauge", 0.04, 0.2, 0.2, -0.25, 0.6, -0.43, "white", "cylinder", front)
		b(
			"GaugeNeedle",
			0.025,
			0.07,
			0.025,
			-0.25,
			0.61,
			-0.46,
			"red",
			nil,
			CFrame.Angles(0, 0, -0.45)
		)
		for _, x in { 0.07, 0.28 } do
			b("SocketRim", 0.04, 0.15, 0.15, x, 0.52, -0.43, "silver", "cylinder", front)
			b("Socket", 0.05, 0.09, 0.09, x, 0.52, -0.46, "dark", "cylinder", front)
		end
		b("FanHousing", 0.12, 0.46, 0.46, 0.44, 0.49, 0, "dark", "cylinder")
		b("FanCover", 0.04, 0.32, 0.32, 0.52, 0.49, 0, "silver", "cylinder")
		b("Pipe", 0.12, 0.43, 0.12, -0.3, 0.89, 0.27, "silver")
		for x = -0.3, 0.3, 0.15 do
			b("Grille", 0.045, 0.22, 0.04, x, 0.42, 0.33, "dark")
		end
		b("Handle", 0.55, 0.12, 0.15, 0, 1.32, 0, "teal")
		for _, x in { -0.25, 0.25 } do
			b("HandleMount", 0.1, 0.2, 0.15, x, 1.21, 0, "dark")
		end
	elseif index == 11 then
		b("Base", 1, 0.15, 0.8, 0, 0.1, 0, "dark")
		for i, x in { -0.3, 0, 0.3 } do
			local height = if i == 2 then 0.72 else 0.5
			local color = if i == 2 then "purple" else "teal"
			b("Crystal", 0.3, height, 0.34, x, 0.2 + height / 2, 0, color)
			point("CrystalTip", 0.3, 0.3, 0.34, Vector3.new(x, 0.2 + height + 0.15, 0), color)
			b(
				"CrystalFacet",
				0.05,
				height * 0.7,
				0.025,
				x - 0.08,
				0.2 + height / 2,
				-0.18,
				"silver"
			)
		end
	elseif index == 12 then
		b("Foot", 0.1, 0.8, 0.8, 0, 0.06, 0, "gold", "cylinder", vertical)
		b("Stem", 0.7, 0.13, 0.13, 0, 0.44, 0, "gold", "cylinder", vertical)
		b("CupBase", 0.12, 0.5, 0.5, 0, 0.8, 0, "gold", "cylinder", vertical)
		b("BowlInterior", 0.035, 0.45, 0.45, 0, 0.88, 0, "dark", "cylinder", vertical)
		ring("Cup", 0.3, 1.02, 0.09, 0.4, "gold")
		ring("Rim", 0.35, 1.24, 0.085, 0.07, "gold")
		for _, x in { -0.48, 0.48 } do
			b("Handle", 0.09, 0.32, 0.1, x, 1.0, 0, "gold")
			for _, y in { 0.86, 1.14 } do
				b("HandleMount", 0.23, 0.07, 0.1, x * 0.84, y, 0, "gold")
			end
		end
		b("Gem", 0.13, 0.18, 0.06, 0, 1.02, -0.36, "teal", "wedge")
	elseif index == 13 then
		ring("Band", 0.45, 0.2, 0.12, 0.25, "gold")
		ring("Lining", 0.37, 0.19, 0.08, 0.18, "purple")
		for i = 0, 7 do
			local angle = i * math.pi / 4
			point(
				"Point",
				0.32,
				if i % 2 == 0 then 0.44 else 0.3,
				0.1,
				Vector3.new(math.sin(angle) * 0.45, 0.49, math.cos(angle) * 0.45),
				"gold",
				CFrame.Angles(0, angle, 0)
			)
			b(
				"Gem",
				0.14,
				0.15,
				0.07,
				math.sin(angle) * 0.53,
				0.23,
				math.cos(angle) * 0.53,
				if i % 2 == 0 then "red" else "teal",
				"ball",
				CFrame.Angles(0, angle, 0)
			)
		end
	elseif index == 14 then
		b("Plinth", 1, 0.18, 0.8, 0, 0.09, 0, "dark")
		b("Step", 0.8, 0.15, 0.65, 0, 0.25, 0, "gold")
		b("Body", 0.5, 0.7, 0.4, 0, 0.68, 0, "white")
		b("Head", 0.4, 0.43, 0.4, 0, 1.25, 0, "gold", "ball")
		b("Headdress", 0.56, 0.18, 0.38, 0, 1.47, 0.02, "gold")
		b("Nose", 0.065, 0.12, 0.1, 0, 1.24, -0.23, "gold")
		for _, x in { -0.4, 0.4 } do
			b("Shoulder", 0.24, 0.24, 0.32, x * 0.8, 1.0, 0, "gold", "ball")
			b("Arm", 0.19, 0.57, 0.22, x, 0.74, 0, "gold")
			b("Boot", 0.2, 0.19, 0.35, x * 0.38, 0.39, -0.08, "gold")
			b("Eye", 0.08, 0.045, 0.04, x * 0.2, 1.31, -0.21, "dark")
			b("HeaddressSide", 0.12, 0.4, 0.35, x * 0.63, 1.25, 0.03, "gold")
		end
		b("Collar", 0.55, 0.12, 0.08, 0, 1.0, -0.25, "teal")
		b("Gem", 0.14, 0.2, 0.06, 0, 0.78, -0.25, "teal", "wedge")
	elseif index == 16 then
		local core = b("Core", 1.05, 0.65, 0.65, 0, 0.8, 0, "teal", "cylinder", vertical)
		core.Material = Enum.Material.Neon
		for _, y in { 0.25, 0.8, 1.4 } do
			ring("Ring", 0.5, y, 0.11, 0.12, "gold")
		end
		for _, x in { -0.42, 0.42 } do
			for _, z in { -0.42, 0.42 } do
				b("Foot", 0.2, 0.2, 0.2, x, 0.1, z, "dark")
				b("Connector", 0.1, 1.15, 0.1, x, 0.82, z, "silver")
			end
		end
		for _, y in { 0.22, 1.43 } do
			b("EndCap", 0.12, 1, 1, 0, y, 0, "dark", "cylinder", vertical)
		end
		b("StatusPanel", 0.3, 0.2, 0.07, 0, 0.8, -0.55, "dark")
		for _, x in { -0.08, 0.08 } do
			b("Indicator", 0.06, 0.08, 0.03, x, 0.8, -0.6, "orange")
		end
	elseif index == 17 then
		b("Base", 0.95, 0.18, 0.95, 0, 0.09, 0, "dark")
		b("Light", 0.62, 1.1, 0.62, 0, 0.72, 0, "yellowLight", "ball")
		b("Cap", 0.95, 0.16, 0.95, 0, 1.34, 0, "green")
		for _, x in { -0.38, 0.38 } do
			b("Guard", 0.12, 1.15, 0.12, x, 0.72, 0, "silver")
			b("HandleSide", 0.12, 0.5, 0.12, x, 1.62, 0, "dark")
		end
		b("Handle", 0.86, 0.12, 0.12, 0, 1.87, 0, "dark")
		b("Switch", 0.18, 0.14, 0.12, 0, 0.17, -0.5, "orange")
	elseif index == 18 then
		b("Bridge", 0.6, 0.3, 0.35, 0, 0.6, 0, "green")
		for _, x in { -0.43, 0.43 } do
			b("Barrel", 1, 0.52, 0.52, x, 0.55, 0, "green", "cylinder", front)
			b("LensRim", 0.14, 0.64, 0.64, x, 0.55, -0.52, "dark", "cylinder", front)
			b("Lens", 0.12, 0.48, 0.48, x, 0.55, -0.6, "blue", "cylinder", front)
			b("Eyepiece", 0.25, 0.32, 0.32, x, 0.55, 0.58, "dark", "cylinder", front)
		end
		b("FocusDial", 0.3, 0.22, 0.22, 0, 0.77, 0.12, "silver", "cylinder", vertical)
	elseif index == 19 then
		for _, x in { -0.42, 0.42 } do
			b("Sole", 0.68, 0.18, 1.25, x, 0.09, -0.1, "dark")
			b("Toe", 0.66, 0.44, 0.68, x, 0.35, -0.38, "wood", "ball")
			b("Ankle", 0.6, 0.83, 0.65, x, 0.58, 0.2, "wood")
			b("Cuff", 0.64, 0.16, 0.69, x, 1.02, 0.2, "orange")
			b("Opening", 0.4, 0.12, 0.45, x, 1.11, 0.2, "dark")
			for _, y in { 0.48, 0.64, 0.8 } do
				b("Laces", 0.38, 0.12, 0.12, x, y, -0.17, "yellowLight")
			end
		end
	elseif index == 20 then
		b("Coil", 0.12, 1.15, 1.15, 0, 0.12, -0.4, "dark", "cylinder", vertical)
		b("CoilInset", 0.14, 0.72, 0.72, 0, 0.13, -0.4, "green", "cylinder", vertical)
		b("Shaft", 0.14, 1.8, 0.14, 0, 1.03, 0.05, "silver", nil, CFrame.Angles(-0.22, 0, 0))
		b("ControlBox", 0.66, 0.4, 0.25, 0, 1.55, -0.12, "green", nil, CFrame.Angles(-0.3, 0, 0))
		b("Screen", 0.4, 0.18, 0.12, 0, 1.58, -0.29, "teal")
		b("Grip", 0.18, 0.55, 0.18, 0, 2.02, 0.3, "dark", nil, CFrame.Angles(-0.7, 0, 0))
		b("ArmRest", 0.65, 0.16, 0.48, 0, 2.24, 0.55, "orange")
	elseif index == 21 then
		b("Groundsheet", 2.2, 0.14, 2.4, 0, 0.07, 0, "dark")
		point("Canvas", 2.2, 1.65, 2.3, Vector3.new(0, 0.965, 0), "green")
		point("Entrance", 1.3, 1.15, 0.14, Vector3.new(0, 0.72, -1.22), "dark")
		for _, sign in { -1, 1 } do
			b(
				"DoorSeam",
				0.12,
				1.9,
				0.12,
				sign * 0.56,
				0.98,
				-1.31,
				"orange",
				nil,
				CFrame.Angles(0, 0, sign * 0.59)
			)
			b("Stake", 0.18, 0.15, 0.3, sign * 1.12, 0.13, -1.2, "silver")
		end
		b("Ridge", 0.14, 0.14, 2.55, 0, 1.85, 0, "yellowLight")
	elseif index == 22 then
		b("TripodHub", 0.4, 0.3, 0.4, 0, 0.95, 0, "dark")
		for i = 0, 2 do
			local angle = i * 2 * math.pi / 3
			b(
				"TripodLeg",
				0.14,
				1.05,
				0.14,
				math.sin(angle) * 0.35,
				0.48,
				math.cos(angle) * 0.35,
				"silver",
				nil,
				CFrame.Angles(0, angle, 0) * CFrame.Angles(-0.65, 0, 0)
			)
		end
		b("Tube", 1.65, 0.55, 0.55, 0, 1.45, 0, "blue", "cylinder", front)
		b("ObjectiveRim", 0.2, 0.72, 0.72, 0, 1.45, -0.88, "dark", "cylinder", front)
		b("ObjectiveLens", 0.12, 0.56, 0.56, 0, 1.45, -1, "teal", "cylinder", front)
		b("Eyepiece", 0.4, 0.23, 0.23, 0, 1.45, 0.98, "dark", "cylinder", front)
		b("Finder", 0.7, 0.16, 0.16, 0.3, 1.83, 0, "yellowLight", "cylinder", front)
		b("FinderMount", 0.14, 0.3, 0.14, 0.3, 1.66, 0, "silver")
		b("FocusWheel", 0.15, 0.28, 0.28, 0.35, 1.43, 0.6, "silver", "cylinder")
	elseif index == 23 then
		b("Collar", 0.2, 1, 1, 0, 0.15, 0, "silver", "cylinder", vertical)
		b("Shell", 1.5, 1.5, 1.35, 0, 0.94, 0, "white", "ball")
		b("VisorSeal", 1.22, 0.93, 0.42, 0, 0.99, -0.55, "dark", "ball")
		b("Visor", 1.04, 0.74, 0.32, 0, 1.01, -0.73, "gold", "ball")
		for _, x in { -0.77, 0.77 } do
			b("Comms", 0.18, 0.45, 0.45, x, 0.98, 0, "silver", "cylinder")
		end
		b("Reflection", 0.15, 0.33, 0.12, -0.3, 1.15, -0.88, "yellowLight")
	elseif index == 24 then
		b("Chassis", 1.25, 0.22, 1.9, 0, 0.55, 0, "silver")
		b("Cabin", 0.95, 0.55, 0.85, 0, 0.88, -0.3, "white")
		b("Windshield", 0.8, 0.28, 0.12, 0, 0.98, -0.78, "blue")
		for _, x in { -0.78, 0.78 } do
			for _, z in { -0.65, 0, 0.65 } do
				b("Wheel", 0.26, 0.55, 0.55, x, 0.3, z, "dark", "cylinder")
				b("Hub", 0.28, 0.25, 0.25, x, 0.3, z, "silver", "cylinder")
			end
		end
		b("SolarPanel", 1.25, 0.14, 0.8, 0, 0.94, 0.62, "blue")
		b("Mast", 0.12, 0.8, 0.12, 0.3, 1.4, 0.15, "silver")
		b("Camera", 0.36, 0.22, 0.3, 0.3, 1.82, 0.06, "gold")
	elseif index == 25 then
		b("Core", 0.68, 0.8, 0.68, 0, 0.7, 0, "gold")
		b("Spar", 2.5, 0.15, 0.15, 0, 0.7, 0, "silver")
		for _, x in { -1, 1 } do
			b("SolarPanel", 0.8, 0.14, 1.55, x, 0.7, 0, "blue")
			for _, z in { -0.5, 0, 0.5 } do
				b("PanelGrid", 0.82, 0.15, 0.12, x, 0.7, z, "silver")
			end
		end
		b("Dish", 0.16, 0.85, 0.85, 0, 1.22, 0, "white", "cylinder", vertical)
		b("Antenna", 0.12, 0.62, 0.12, 0, 1.6, 0, "silver")
		b("AntennaTip", 0.2, 0.2, 0.2, 0, 1.94, 0, "teal", "ball")
	elseif index == 26 then
		b("Body", 0.7, 1.4, 0.7, 0, 1.15, 0, "white")
		for i = 0, 3 do
			local cf = CFrame.Angles(0, i * math.pi / 2, 0)
				* CFrame.new(0.175, 2.15, 0.175)
				* CFrame.Angles(0, math.pi / 2, 0)
			piece("Nose", Vector3.new(0.35, 0.6, 0.35), cf.Position, "red", "corner", cf.Rotation)
		end
		b("WindowRim", 0.16, 0.42, 0.42, 0, 1.5, -0.4, "dark", "cylinder", front)
		b("Window", 0.12, 0.3, 0.3, 0, 1.5, -0.5, "blue", "cylinder", front)
		for i = 0, 3 do
			local cf = CFrame.Angles(0, i * math.pi / 2, 0) * CFrame.new(0.52, 0.45, 0)
			piece("Fin", Vector3.new(0.14, 0.7, 0.65), cf.Position, "red", "wedge", cf.Rotation)
		end
		b("Engine", 0.3, 0.5, 0.5, 0, 0.3, 0, "dark", "cylinder", vertical)
		b("Flame", 0.4, 0.55, 0.4, 0, -0.1, 0, "orange", "ball")
	elseif index == 27 then
		b("Cabin", 1.1, 0.85, 1.1, 0, 1.25, 0, "gold")
		b("Window", 0.6, 0.35, 0.12, 0, 1.37, -0.62, "blue")
		b("Deck", 1.5, 0.2, 1.5, 0, 0.73, 0, "silver")
		for _, x in { -0.85, 0.85 } do
			for _, z in { -0.85, 0.85 } do
				b("Leg", 0.14, 0.7, 0.14, x, 0.42, z, "silver")
				b("Foot", 0.15, 0.5, 0.5, x, 0.1, z, "dark", "cylinder", vertical)
			end
		end
		b("Engine", 0.3, 0.5, 0.5, 0, 0.4, 0, "dark", "cylinder", vertical)
		b("Antenna", 0.12, 0.6, 0.12, 0.4, 1.98, 0, "silver")
		b("Beacon", 0.22, 0.22, 0.22, 0.4, 2.3, 0, "teal", "ball")
		for _, y in { 0.35, 0.57, 0.79 } do
			b("LadderRung", 0.5, 0.12, 0.14, 0, y, -0.94, "white")
		end
	elseif index == 28 then
		b("Rim", 0.18, 2.5, 2.5, 0, 0.6, 0, "silver", "cylinder", vertical)
		b("Hull", 2.2, 0.65, 2.2, 0, 0.6, 0, "silver", "ball")
		b("Dome", 1.15, 1.1, 1.15, 0, 1.05, 0, "teal", "ball")
		b("DomeBase", 0.16, 1.3, 1.3, 0, 0.85, 0, "dark", "cylinder", vertical)
		for i = 0, 7 do
			local angle = i * math.pi / 4
			b(
				"RunningLight",
				0.22,
				0.18,
				0.22,
				math.sin(angle) * 1.08,
				0.73,
				math.cos(angle) * 1.08,
				"yellowLight",
				"ball"
			)
		end
		for i = 0, 2 do
			local angle = i * 2 * math.pi / 3
			b(
				"LandingLeg",
				0.15,
				0.45,
				0.15,
				math.sin(angle) * 0.65,
				0.25,
				math.cos(angle) * 0.65,
				"dark"
			)
		end
	else
		error("Unknown model")
	end
	m.WorldPivot = CFrame.identity
	return m
end
local fittedSizes: { [number]: Vector3 } = {}
local function fit(item, size: Vector3): number
	return math.min(item.size[1] / size.X, item.size[2] / size.Y, item.size[3] / size.Z)
end
function Visuals.carryScale(item): number
	local size = fittedSizes[item.model]
	if not size then
		local template = build(item.model)
		local _, nativeSize = template:GetBoundingBox()
		size = nativeSize * fit(item, nativeSize)
		fittedSizes[item.model] = size
		template:Destroy()
	end
	return math.max(0.45, 1.2 / math.max(size.X, size.Y, size.Z))
end
function Visuals.createItem(item, parent: Instance, transform: CFrame, scale: number?): Model
	local model = build(item.model)
	local bounds, size = model:GetBoundingBox()
	local factor = fit(item, size) * (scale or 1)
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			local cf = part.CFrame
			part.Size *= factor
			part.CFrame = transform
				* CFrame.new(
					(cf.Position - bounds.Position) * factor
						+ Vector3.new(0, size.Y * factor / 2, 0)
				)
				* cf.Rotation
		end
	end
	model.Name = item.name
	model.WorldPivot = transform
	model.Parent = parent
	return model
end
return table.freeze(Visuals)
