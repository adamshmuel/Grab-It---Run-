--!strict
local Rules = require(game:GetService("ReplicatedStorage").GrabIt.Shared.GameRules)
local View = require(game:GetService("ReplicatedStorage").GrabIt.Shared.Presentation)
local World = {}
local materials = { Enum.Material.WoodPlanks, Enum.Material.Metal, Enum.Material.SmoothPlastic }
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
	part(root, "Base", Vector3.new(40, 1, 24), Vector3.new(0, 0, -12), Color3.fromRGB(64, 133, 107))
	part(root, "Floor", Vector3.new(48, 1, 120), Vector3.new(0, 0, 60), Color3.fromRGB(74, 87, 100))
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
		Color3.fromRGB(119, 135, 148)
	)
	for _, x in { -24.5, 24.5 } do
		part(
			root,
			"Wall",
			Vector3.new(1, 20, 120),
			Vector3.new(x, 10, 60),
			Color3.fromRGB(158, 176, 187)
		)
	end
	part(
		root,
		"BackWall",
		Vector3.new(48, 20, 1),
		Vector3.new(0, 10, 120.5),
		Color3.fromRGB(153, 171, 183)
	)
	for _, x in { -16.25, 16.25 } do
		part(
			root,
			"FrontWall",
			Vector3.new(16.5, 20, 1),
			Vector3.new(x, 10, 0),
			Color3.fromRGB(153, 171, 183)
		)
	end
	part(
		root,
		"Lintel",
		Vector3.new(16, 8, 1),
		Vector3.new(0, 16, 0),
		Color3.fromRGB(153, 171, 183)
	)
	part(root, "Door", Vector3.new(16, 12, 1), Vector3.new(0, 6, 0), Color3.fromRGB(228, 103, 71))
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
			part(
				root,
				"Shelf",
				Vector3.new(3, 0.6, 24),
				Vector3.new(x, 7, z + 13),
				Color3.fromRGB(52, 70, 83)
			)
			for _, dz in { 2, 24 } do
				part(
					root,
					"ShelfSupport",
					Vector3.new(0.6, 7, 0.6),
					Vector3.new(x, 4, z + dz),
					Color3.fromRGB(46, 61, 73)
				)
			end
		end
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
		local color = View.itemColors[item.zone]
		local crate = part(
			folder,
			tostring(item.id),
			Vector3.new(3, 3, 3),
			Vector3.new(item.x, 2.5, item.z),
			color
		)
		crate.Material = materials[item.zone]
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
