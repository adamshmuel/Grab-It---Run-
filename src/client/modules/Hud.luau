--!strict
local GuiService = game:GetService("GuiService")
local Catalog = require(script.Parent.Parent.Shared.Catalog)
local Hud = {}
local function box(parent: Instance, name: string, pos: UDim2, size: UDim2): TextLabel
	local v = Instance.new("TextLabel")
	v.Name = name
	v.Position = pos
	v.Size = size
	v.BackgroundColor3 = Color3.fromRGB(20, 33, 45)
	v.BackgroundTransparency = 0.12
	v.TextColor3 = Color3.fromRGB(237, 242, 237)
	v.TextScaled = false
	v.TextSize = 18
	v.Text = ""
	v.Font = Enum.Font.GothamBold
	v.TextWrapped = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = v
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = v
	v.Parent = parent
	return v
end
local function layout(ui)
	local area = ui.Root.AbsoluteSize
	if area.X <= 0 or area.Y <= 0 then
		return
	end
	ui.Metadata.Position = UDim2.fromOffset(area.X / 2 - 160, 0)
	ui.Round.Position = UDim2.fromOffset(area.X / 2 - 66, 22)
	ui.Scores.Position = UDim2.fromOffset(area.X - 138, 2)
	ui.Styles.Position = UDim2.fromOffset(area.X - 66, 2)
	local available = math.max(160, area.X - 318)
	local width = math.min(360, available)
	local x = 178 + (available - width) / 2
	ui.Bag.Position = UDim2.fromOffset(x, area.Y - 48)
	ui.Bag.Size = UDim2.fromOffset(width, 44)
	for _, field in { ui.Message, ui.Tutorial } do
		field.Position = UDim2.fromOffset(x, area.Y - 94)
		field.Size = UDim2.fromOffset(width, 40)
	end
end
function Hud.create()
	local screen = Instance.new("ScreenGui")
	screen.Name = "GrabItHUD"
	screen.ResetOnSpawn = false
	screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	screen.ClipToDeviceSafeArea = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local initialTouchControls = GuiService.TouchControlsEnabled
	local layoutConnection: RBXScriptConnection? = nil
	screen.Destroying:Connect(function()
		if layoutConnection then
			layoutConnection:Disconnect()
		end
		GuiService.TouchControlsEnabled = initialTouchControls
	end)
	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = screen
	local coins = box(root, "Coins", UDim2.fromOffset(8, 0), UDim2.fromOffset(144, 22))
	local save = box(root, "Save", UDim2.fromOffset(8, 24), UDim2.fromOffset(144, 20))
	save.Visible = false
	local metadata = box(root, "Metadata", UDim2.new(), UDim2.fromOffset(320, 20))
	local round = box(root, "Round", UDim2.new(), UDim2.fromOffset(132, 30))
	round.TextSize = 28
	for _, field in { coins, save, metadata, round } do
		field.BackgroundTransparency = 0
	end
	local bag = box(root, "Bag", UDim2.new(0.23, 0, 1, -48), UDim2.new(0.54, 0, 0, 44))
	local message = box(root, "Message", UDim2.fromScale(0.21, 0.33), UDim2.new(0.58, 0, 0, 34))
	message.BackgroundTransparency = 0.2
	message.Visible = false
	local tutorial = box(root, "Tutorial", UDim2.new(0.22, 0, 1, -96), UDim2.new(0.52, 0, 0, 44))
	local button = Instance.new("TextButton")
	button.Name = "Collect"
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(1, -8, 1, -8)
	button.Size = UDim2.fromOffset(120, 56)
	button.BackgroundColor3 = Color3.fromRGB(240, 189, 75)
	button.TextColor3 = Color3.fromRGB(25, 38, 47)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Text = "Collect"
	button.Visible = false
	button.Parent = root
	local touchSize = Instance.new("UISizeConstraint")
	touchSize.MinSize = Vector2.new(48, 48)
	touchSize.Parent = button
	local corner = Instance.new("UICorner")
	corner.Parent = button
	corner.CornerRadius = UDim.new(0, 12)
	local function action(name: string, text: string, pos: UDim2, size: UDim2): TextButton
		local actionButton = Instance.new("TextButton")
		actionButton.Name = name
		actionButton.Text = text
		actionButton.Position = pos
		actionButton.Size = size
		actionButton.TextSize = 20
		actionButton.Font = Enum.Font.GothamBold
		actionButton.TextColor3 = Color3.fromRGB(25, 38, 47)
		actionButton.BackgroundColor3 = Color3.fromRGB(240, 189, 75)
		actionButton.Visible = false
		actionButton.Parent = root
		local actionCorner = Instance.new("UICorner")
		actionCorner.CornerRadius = UDim.new(0, 10)
		actionCorner.Parent = actionButton
		return actionButton
	end
	local scores = action("Scores", "Scores", UDim2.new(), UDim2.fromOffset(66, 48))
	local styles = action("Styles", "Styles", UDim2.new(), UDim2.fromOffset(58, 48))
	scores.TextSize = 18
	styles.TextSize = 18
	local nextButton =
		action("Next", "Next", UDim2.fromScale(0.31, 0.45), UDim2.new(0.38, 0, 0, 48))
	local urgent = Instance.new("UIStroke")
	urgent.Name = "Urgency"
	urgent.Thickness = 3
	urgent.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	urgent.Color = Color3.fromRGB(255, 70, 70)
	urgent.Enabled = false
	urgent.Parent = round
	local ui = {
		InitialTouchControls = initialTouchControls,
		Metadata = metadata,
		Save = save,
		Next = nextButton,
		Styles = styles,
		Scores = scores,
		Urgency = urgent,
		Screen = screen,
		Root = root,
		Coins = coins,
		Round = round,
		Bag = bag,
		Message = message,
		Tutorial = tutorial,
		Collect = button,
	}
	layout(ui)
	layoutConnection = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		layout(ui)
	end)
	return ui
end
function Hud.update(ui, state, touch: boolean)
	GuiService.TouchControlsEnabled = ui.InitialTouchControls
		and state.phase ~= "results"
		and state.phase ~= "summary"
	local save = state.save or ""
	local warning = string.sub(save, 1, 13) == "Not saved yet"
	if ui.lastSave ~= save then
		ui.lastSave = save
		ui.savedUntil = os.clock() + 2
	end
	ui.Coins.Text = "COINS " .. state.coins
	ui.Save.Text = if warning
		then "Not saved yet"
		elseif save == "Studio session only" then "Session only"
		else save
	ui.Save.Visible = save ~= "" and (save ~= "Saved" or os.clock() < ui.savedUntil)
	local seconds = math.max(0, state.remaining)
	local stage = state.stage or 1
	ui.Metadata.Text = (state.stageName or Catalog.stages[stage].name)
		.. " | "
		.. stage
		.. "/"
		.. #Catalog.stages
		.. " "
		.. (
			if state.open
				then (if state.warning then "RETURN TO BASE" else "OPEN")
				else string.upper(state.phase or "Loading")
		)
	ui.Round.Text = string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
	ui.Bag.Text = "Weight "
		.. tostring(state.cargoWeight or 0)
		.. " / "
		.. (state.capacity or 10)
		.. "\nCargo value "
		.. tostring(state.cargoValue or 0)
		.. " | Banked "
		.. (state.bankedCount or 0)
		.. " / "
		.. (state.totalItems or 30)
	ui.Collect.Visible = touch and state.open and state.target ~= nil and state.ready
	ui.Collect.Text = "Collect"
	ui.Styles.Visible = state.ready and (state.inBase or not state.open)
	ui.Scores.Visible = state.ready and state.phase == "active"
	ui.Next.Visible = state.canNext == true
	ui.Next.Text = if stage == #Catalog.stages
		then "Finish match"
		else "Next: " .. (if Catalog.stages[stage + 1]
			then Catalog.stages[stage + 1].name
			else "")
	ui.Tutorial.Visible = (not state.tutorial or not state.ready or warning)
		and not ui.Message.Visible
	ui.Tutorial.Text = if not state.ready
		then state.save
		elseif warning then state.save
		elseif state.warning or state.cargoCount > 0 then "Return before closing"
		else "Collect items. Return here to bank them."
	ui.Urgency.Enabled = state.warning == true
	ui.Urgency.Transparency = if state.warning
		then 0.35 + 0.3 * math.cos(os.clock() * math.pi * 2)
		else 0
end
return Hud
