--!strict
local Catalog = require(game:GetService("ReplicatedStorage").GrabIt.Shared.Catalog)
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
local cameraGeometry = { BluePillar = true, TopBeam = true }
local function decoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3
): Part
	local detail = part(parent, name, size, position, color)
	detail.CanCollide = false
	detail.CanTouch = false
	detail.CanQuery = cameraGeometry[name] == true
	return detail
end
local frameColor = Color3.fromRGB(35, 68, 91)
local function label(parent: BasePart, text: string, color: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "ValueLabel"
	gui.Face = if parent.Name == "Deposit" or parent:GetAttribute("FloorMarker")
		then Enum.NormalId.Top
		else Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 35
	gui.LightInfluence = 0
	gui.AlwaysOnTop = false
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 23
	title.TextScaled = true
	title.TextWrapped = true
	local size = Instance.new("UITextSizeConstraint")
	size.MaxTextSize = if parent:GetAttribute("FloorMarker") then 96 else 32
	size.MinTextSize = 16
	size.Parent = title
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
	local board = part(
		root,
		"LiveResults",
		Vector3.new(12, 8, 0.2),
		Vector3.new(-16, 6.5, 0.7),
		Color3.fromRGB(24, 32, 51)
	)
	board.CanCollide = false
	local folder = Instance.new("Folder")
	folder.Name = "Items"
	folder.Parent = root
	World.setStage(root, 1)
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
function World.setStage(root: Model, stage: number)
	local items = root:FindFirstChild("Items")
	assert(items, "Managed item folder missing")
	items:ClearAllChildren()
	local old = root:FindFirstChild("StageDecor")
	if old then
		old:Destroy()
	end
	local oldStand = root:FindFirstChild("SpecialDisplay")
	if oldStand then
		oldStand:Destroy()
	end
	local decor = Instance.new("Model")
	decor.Name = "StageDecor"
	decor.Parent = root
	local palettes = {
		{
			Color3.fromRGB(37, 160, 203),
			Color3.fromRGB(255, 204, 64),
			Color3.fromRGB(239, 83, 102),
		},
		{
			Color3.fromRGB(30, 186, 177),
			Color3.fromRGB(255, 139, 58),
			Color3.fromRGB(165, 196, 225),
		},
		{
			Color3.fromRGB(136, 78, 199),
			Color3.fromRGB(255, 198, 60),
			Color3.fromRGB(52, 215, 204),
		},
	}
	local palette = palettes[stage]
	for row = 1, 15 do
		local z = 12 + (row - 1) * 6
		for _, x in { -12, 12 } do
			local marker = decoration(
				decor,
				"CargoMarker",
				Vector3.new(4.8, 0.025, 4.8),
				Vector3.new(x, 0.525, z),
				palette[(math.ceil(row / 3) - 1) % 3 + 1]
			)
			if stage == 1 then
				marker.Shape = Enum.PartType.Cylinder
				marker.Size = Vector3.new(0.025, 4.8, 4.8)
				marker.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
			elseif stage == 3 then
				marker.CFrame *= CFrame.Angles(0, math.pi / 4, 0)
			end
		end
	end
	for _, x in { -23.9, 23.9 } do
		for _, z in { 20, 44, 68, 92, 114 } do
			decoration(
				decor,
				"WallRibbon",
				Vector3.new(0.08, 0.4, 18),
				Vector3.new(x, 11, z),
				palette[2]
			)
			for n = 1, 3 do
				local tile = decoration(
					decor,
					if stage == 1 then "ToyCircle" elseif stage == 2 then "Circuit" else "Diamond",
					Vector3.new(0.1, 1.4, 1.4),
					Vector3.new(x, 8, z - 4 + n * 2),
					palette[n]
				)
				if stage == 1 and n == 2 then
					tile:Destroy()
					local star = Instance.new("Model")
					star.Name = "ToyStar"
					star.Parent = decor
					for point = 1, 5 do
						local angle = (point - 1) * 2 * math.pi / 5
						local wedge = Instance.new("WedgePart")
						wedge.Name = "StarPoint"
						wedge.Size = Vector3.new(0.1, 0.8, 0.7)
						wedge.CFrame = CFrame.new(
							x,
							8 + math.cos(angle) * 0.4,
							z - 4 + n * 2 + math.sin(angle) * 0.4
						) * CFrame.Angles(angle, 0, 0)
						wedge.Color = palette[1]
						wedge.Anchored = true
						wedge.CanCollide = false
						wedge.CanQuery = false
						wedge.CanTouch = false
						wedge.Parent = star
					end
				elseif stage == 1 then
					tile.Shape = Enum.PartType.Ball
				elseif stage == 3 then
					tile.CFrame *= CFrame.Angles(math.pi / 4, 0, 0)
				end
				if stage == 2 then
					decoration(
						decor,
						"CircuitTrace",
						Vector3.new(0.12, 0.12, 5),
						Vector3.new(x, 8 + n * 0.7, z),
						palette[n]
					)
				end
			end
		end
	end
	if stage == 3 then
		local stand = Instance.new("Model")
		stand.Name = "SpecialDisplay"
		stand.Parent = root
		part(
			stand,
			"Base",
			Vector3.new(4.8, 0.6, 4.8),
			Vector3.new(0, 0.8, 114),
			Color3.fromRGB(66, 37, 105)
		)
		part(
			stand,
			"LowerGoldFrame",
			Vector3.new(4.6, 0.15, 4.6),
			Vector3.new(0, 1.15, 114),
			palette[2]
		)
		part(
			stand,
			"UpperPlatform",
			Vector3.new(4.3, 0.35, 4.3),
			Vector3.new(0, 1.4, 114),
			Color3.fromRGB(66, 37, 105)
		)
		part(
			stand,
			"UpperGoldFrame",
			Vector3.new(4.5, 0.1, 4.5),
			Vector3.new(0, 1.625, 114),
			palette[2]
		)
		for _, x in { -2.25, 2.25 } do
			decoration(
				stand,
				"TurquoiseTrim",
				Vector3.new(0.08, 0.15, 4.5),
				Vector3.new(x, 1.3, 114),
				palette[3]
			)
		end
	end
	for _, item in Catalog.items(stage) do
		local anchor = part(
			items,
			tostring(item.id),
			Vector3.new(1, 1, 1),
			Vector3.new(item.x, 2.5, item.z),
			Color3.new(1, 1, 1)
		)
		anchor.Transparency = 1
		anchor.CanCollide = false
		anchor.CanQuery = false
		anchor.CanTouch = false
		anchor:SetAttribute("ItemId", item.id)
		Visuals.createItem(
			item,
			anchor,
			CFrame.new(item.x, if item.special then 1.7 else 0.5, item.z)
		)
	end
	root:SetAttribute("Stage", stage)
	root.Floor.Color = Color3.fromRGB(67, 80, 99)
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
