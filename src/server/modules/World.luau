--!strict
local Rules = require(game:GetService("ReplicatedStorage").GrabIt.Shared.GameRules)
local Visuals = require(script.Parent.Visuals)
local World = {}
local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Color = color
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local cameraGeometry = {
	WallPanel = true,
	WallPost = true,
	Shelf = true,
	ShelfSupport = true,
	ShelfLip = true,
	RoofBeam = true,
	BluePillar = true,
	TopBeam = true,
}
local function decoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3
): Part
	local detail = part(parent, name, size, position, color)
	detail.CanCollide = name == "Shelf" or name == "ShelfSupport"
	detail.CanTouch = false
	detail.CanQuery = cameraGeometry[name] == true
	return detail
end
local accents =
	{ Color3.fromRGB(237, 159, 69), Color3.fromRGB(34, 184, 187), Color3.fromRGB(139, 110, 224) }
local frameColor = Color3.fromRGB(35, 68, 91)
local function label(parent: BasePart, text: string, color: Color3)
	local isItem = parent:GetAttribute("ItemId") ~= nil
	local gui = if isItem then Instance.new("BillboardGui") else Instance.new("SurfaceGui")
	gui.Name = "ValueLabel"
	if gui:IsA("BillboardGui") then
		gui.Size = UDim2.fromOffset(70, 44)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.MaxDistance = 32
	else
		gui.Face = if parent.Name == "Deposit" or parent:GetAttribute("FloorMarker")
			then Enum.NormalId.Top
			else Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 35
		gui.LightInfluence = 0
	end
	gui.AlwaysOnTop = false
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 23
	title.TextScaled = true
	title.TextWrapped = true
	if not isItem then
		local size = Instance.new("UITextSizeConstraint")
		size.MaxTextSize = if parent:GetAttribute("FloorMarker") then 96 else 32
		size.MinTextSize = 16
		size.Parent = title
	end
	title.TextColor3 = color
	title.TextStrokeTransparency = 0.4
	title.Text = text
	title.Parent = gui
	gui.Parent = parent
end
local function homeSymbol(parent: Instance, x: number, z: number, scale: number)
	local symbol = Instance.new("Model")
	symbol.Name = "HomeSymbol"
	for _, line in
		{
			{ -1, 0, 0, 0.16, 2 },
			{ 1, 0, 0, 0.16, 2 },
			{ 0, 1, 0, 2, 0.16 },
			{ -0.5, -1.5, -math.pi / 4, 0.16, 1.6 },
			{ 0.5, -1.5, math.pi / 4, 0.16, 1.6 },
		}
	do
		local stroke = part(
			symbol,
			"Outline",
			Vector3.new(line[4] * scale, 0.04, line[5] * scale),
			Vector3.new(x + line[1] * scale, 0.64, z + line[2] * scale),
			Color3.fromRGB(235, 255, 237)
		)
		stroke.CFrame *= CFrame.Angles(0, line[3], 0)
		stroke.CanCollide = false
		stroke.CanQuery = false
	end
	symbol.Parent = parent
end
function World.build(name: string?): Model
	local root = Instance.new("Model")
	root.Name = name or "GrabItWorld"
	part(root, "Base", Vector3.new(40, 1, 24), Vector3.new(0, 0, -12), Color3.fromRGB(70, 156, 123))
	part(
		root,
		"Floor",
		Vector3.new(48, 1, 120),
		Vector3.new(0, 0, 60),
		Color3.fromRGB(91, 108, 122)
	)
	local bank = part(
		root,
		"Deposit",
		Vector3.new(16, 0.1, 8),
		Vector3.new(0, 0.55, -8),
		Color3.fromRGB(130, 240, 151)
	)
	bank.CanCollide = false
	label(bank, "HOME  /  BANK", Color3.fromRGB(24, 60, 42))
	bank.ValueLabel.TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	bank.ValueLabel.TextLabel.Position = UDim2.fromScale(0.5, 0.65)
	bank.ValueLabel.TextLabel.Size = UDim2.fromScale(1, 0.5)
	bank.ValueLabel.TextLabel.Rotation = -90
	homeSymbol(root, -5, -8, 1)
	part(
		root,
		"Roof",
		Vector3.new(48, 1, 120),
		Vector3.new(0, 20.5, 60),
		Color3.fromRGB(207, 218, 220)
	)
	for _, x in { -24.5, 24.5 } do
		part(
			root,
			"Wall",
			Vector3.new(1, 20, 120),
			Vector3.new(x, 10, 60),
			Color3.fromRGB(207, 226, 229)
		)
	end
	part(
		root,
		"BackWall",
		Vector3.new(48, 20, 1),
		Vector3.new(0, 10, 120.5),
		Color3.fromRGB(201, 220, 225)
	)
	for _, x in { -16.25, 16.25 } do
		part(
			root,
			"FrontWall",
			Vector3.new(16.5, 20, 1),
			Vector3.new(x, 10, 0),
			Color3.fromRGB(201, 220, 225)
		)
	end
	part(
		root,
		"Lintel",
		Vector3.new(16, 8, 1),
		Vector3.new(0, 16, 0),
		Color3.fromRGB(201, 220, 225)
	)
	part(root, "Door", Vector3.new(16, 12, 1), Vector3.new(0, 6, 0), Color3.fromRGB(228, 103, 71))
	local entrance = Instance.new("Model")
	entrance.Name = "EntranceFrame"
	entrance.Parent = root
	for _, x in { -8.65, 8.65 } do
		decoration(
			entrance,
			"BluePillar",
			Vector3.new(0.9, 12.6, 0.8),
			Vector3.new(x, 6.3, -0.7),
			frameColor
		)
		decoration(
			entrance,
			"YellowEdge",
			Vector3.new(0.16, 11.8, 0.12),
			Vector3.new(x, 6.1, -1.15),
			Color3.fromRGB(255, 206, 76)
		)
	end
	decoration(
		entrance,
		"TopBeam",
		Vector3.new(18.2, 0.7, 0.8),
		Vector3.new(0, 12.3, -0.7),
		frameColor
	)
	for x = -7, 7, 2 do
		local stripe = decoration(
			entrance,
			"ClosureStripe",
			Vector3.new(0.65, 0.04, 0.8),
			Vector3.new(x, 0.55, -0.7),
			Color3.fromRGB(255, 207, 77)
		)
		stripe.CFrame *= CFrame.Angles(0, math.rad(25), 0)
	end
	for _, x in { -8.15, 8.15 } do
		decoration(
			root,
			"BankBorder",
			Vector3.new(0.22, 0.05, 8.3),
			Vector3.new(x, 0.59, -8),
			Color3.fromRGB(225, 255, 231)
		)
	end
	for _, z in { -12.15, -3.85 } do
		decoration(
			root,
			"BankBorder",
			Vector3.new(16.5, 0.05, 0.22),
			Vector3.new(0, 0.59, z),
			Color3.fromRGB(225, 255, 231)
		)
	end
	local entrySign = part(
		root,
		"EntrySign",
		Vector3.new(14, 2, 0.3),
		Vector3.new(0, 13.2, -0.7),
		Color3.fromRGB(47, 62, 76)
	)
	entrySign.CanCollide = false
	label(entrySign, "WAREHOUSE OPEN", Color3.fromRGB(255, 247, 216))
	part(
		root,
		"ReturnLine",
		Vector3.new(0.3, 0.05, 118),
		Vector3.new(0, 0.54, 60),
		Color3.fromRGB(226, 237, 232)
	).CanCollide =
		false
	for _, z in { 18, 54, 90 } do
		homeSymbol(root, 3, z, 0.45)
		for _, x in { -1, 1 } do
			local arrow = part(
				root,
				"HomeArrow",
				Vector3.new(0.3, 0.06, 2.5),
				Vector3.new(x * 0.7, 0.56, z),
				Color3.fromRGB(213, 239, 224)
			)
			arrow.CFrame *= CFrame.Angles(0, math.rad(x * 35), 0)
			arrow.CanCollide = false
		end
	end
	for zone = 1, 3 do
		local z = (zone - 1) * 36 + 6
		local accent = Instance.new("Model")
		accent.Name = "ZoneAccent" .. zone
		accent.Parent = root
		for _, side in { -1, 1 } do
			decoration(
				accent,
				"FloorBand",
				Vector3.new(7.5, 0.03, 33),
				Vector3.new(side * 12, 0.52, z + 15),
				accents[zone]
			)
			decoration(
				accent,
				"WallPanel",
				Vector3.new(0.12, 7, 32),
				Vector3.new(side * 23.95, 8, z + 15),
				Color3.fromRGB(228, 237, 234)
			)
			decoration(
				accent,
				"WallStripe",
				Vector3.new(0.16, 0.55, 32),
				Vector3.new(side * 23.85, 11.7, z + 15),
				accents[zone]
			)
			for _, dz in { 0, 33 } do
				decoration(
					accent,
					"WallPost",
					Vector3.new(0.35, 18, 0.65),
					Vector3.new(side * 23.7, 9.5, z + dz),
					frameColor
				)
			end
		end
		local marker = part(
			root,
			"ZoneMarker" .. zone,
			Vector3.new(4, 0.03, 4),
			Vector3.new(5.5, 0.58, z),
			Color3.fromRGB(52, 70, 83)
		)
		marker.CanCollide = false
		marker.CanQuery = false
		marker:SetAttribute("FloorMarker", true)
		label(marker, tostring(zone), Color3.fromRGB(255, 235, 173))
		local sign = part(
			root,
			"ZoneSign",
			Vector3.new(8, 3, 0.3),
			Vector3.new(-19, 7, z),
			Color3.fromRGB(47, 62, 76)
		)
		sign.CanCollide = false
		label(
			sign,
			"ZONE " .. zone .. "  /  " .. ({ 1, 3, 6 })[zone] .. " COINS",
			Color3.fromRGB(255, 235, 173)
		)
		for _, x in { -21, 21 } do
			local blocker = part(
				root,
				"ShelfBlocker",
				Vector3.new(4.2, 8, 24.2),
				Vector3.new(x, 4.5, z + 13),
				frameColor
			)
			blocker.Transparency = 1
			blocker.CanTouch = false
			for _, y in { 2.2, 5, 7.8 } do
				decoration(
					root,
					"Shelf",
					Vector3.new(3.8, 0.25, 24),
					Vector3.new(x, y, z + 13),
					frameColor
				)
				decoration(
					root,
					"ShelfLip",
					Vector3.new(0.12, 0.25, 24),
					Vector3.new(x - math.sign(x) * 1.9, y, z + 13),
					accents[zone]
				)
			end
			for _, dx in { -1.5, 1.5 } do
				for _, dz in { 2, 24 } do
					decoration(
						root,
						"ShelfSupport",
						Vector3.new(0.2, 8, 0.3),
						Vector3.new(x + dx, 4.5, z + dz),
						frameColor
					)
				end
			end
		end
		decoration(
			root,
			"RoofBeam",
			Vector3.new(47, 0.45, 0.6),
			Vector3.new(0, 19.5, z + 1),
			frameColor
		)

		local light = part(
			root,
			"CeilingStrip",
			Vector3.new(16, 0.2, 1),
			Vector3.new(0, 19.7, z + 12),
			Color3.fromRGB(255, 249, 224)
		)
		light.Material = Enum.Material.Neon
	end
	local folder = Instance.new("Folder")
	folder.Name = "Items"
	folder.Parent = root
	for _, item in Rules.items do
		local color = Color3.fromRGB(255, 255, 255)
		local crate = part(
			folder,
			tostring(item.id),
			Vector3.new(3, 3, 3),
			Vector3.new(item.x, 2.5, item.z),
			color
		)
		crate.Transparency = 1
		crate.CanQuery = false
		Visuals.create(item.zone, crate, CFrame.new(item.x, 0.5, item.z))
		crate.CanCollide = false
		crate:SetAttribute("ItemId", item.id)
		label(crate, tostring(item.value), Color3.fromRGB(255, 244, 202))
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Size = Vector3.new(6, 1, 4)
	spawn.Position = Vector3.new(0, 1, -18)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = root
	root.Parent = workspace
	World.setOpen(root, true)
	return root
end
function World.setOpen(root: Model, open: boolean)
	local door = root:FindFirstChild("Door") :: Part
	door.CanCollide = not open
	door.Transparency = if open then 1 else 0
	local labelGui = root.EntrySign:FindFirstChild("ValueLabel") :: SurfaceGui
	(labelGui:FindFirstChildOfClass("TextLabel") :: TextLabel).Text = if open
		then "WAREHOUSE OPEN"
		else "WAREHOUSE CLOSED"
end
return World
