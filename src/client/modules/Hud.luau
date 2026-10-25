--!strict
local Hud = {}
local function box(parent: Instance, name: string, pos: UDim2, size: UDim2): TextLabel
	local v = Instance.new("TextLabel")
	v.Name = name
	v.Position = pos
	v.Size = size
	v.BackgroundColor3 = Color3.fromRGB(20, 33, 45)
	v.BackgroundTransparency = 0.12
	v.TextColor3 = Color3.fromRGB(237, 242, 237)
	v.TextScaled = true
	v.Font = Enum.Font.GothamBold
	v.TextWrapped = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = v
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = v
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 18
	constraint.MaxTextSize = 21
	constraint.Parent = v
	v.Parent = parent
	return v
end
function Hud.create()
	local screen = Instance.new("ScreenGui")
	screen.Name = "GrabItHUD"
	screen.ResetOnSpawn = false
	screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	screen.ClipToDeviceSafeArea = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = screen
	local coins = box(root, "Coins", UDim2.new(0.02, 0, 0, 6), UDim2.new(0.27, 0, 0, 44))
	local round = box(root, "Round", UDim2.new(0.32, 0, 0, 6), UDim2.new(0.36, 0, 0, 44))
	local style = box(root, "Style", UDim2.new(0.71, 0, 0, 6), UDim2.new(0.27, 0, 0, 54))
	for _, field in { coins, round, style } do
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
	button.Position = UDim2.fromScale(0.97, 0.94)
	button.Size = UDim2.fromScale(0.2, 0.15)
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
	style.Visible = false
	local styles = action("Styles", "Styles", UDim2.new(0.73, 0, 0, 6), UDim2.new(0.25, 0, 0, 48))
	local nextButton =
		action("Next", "Next", UDim2.fromScale(0.31, 0.45), UDim2.new(0.38, 0, 0, 48))
	local urgent = Instance.new("UIStroke")
	urgent.Name = "Urgency"
	urgent.Thickness = 3
	urgent.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	urgent.Color = Color3.fromRGB(255, 70, 70)
	urgent.Enabled = false
	urgent.Parent = round
	local stagePath = box(root, "StagePath", UDim2.new(0.08, 0, 0, 56), UDim2.new(0.84, 0, 0, 22))
	stagePath.Text = "Toy Dash > Tech Run > Golden Rush"
	return {
		StagePath = stagePath,
		Next = nextButton,
		Styles = styles,
		Urgency = urgent,
		Screen = screen,
		Root = root,
		Coins = coins,
		Round = round,
		Style = style,
		Bag = bag,
		Message = message,
		Tutorial = tutorial,
		Collect = button,
	}
end
function Hud.update(ui, state, touch: boolean)
	local warning = string.sub(state.save, 1, 13) == "Not saved yet"
	ui.Coins.Text = "COINS "
		.. state.coins
		.. "\n"
		.. (if warning then "Not saved yet" else state.save)
	local seconds = math.max(0, state.remaining)
	ui.Round.Text = (state.stageName or "Toy Dash")
		.. " | "
		.. (state.stage or 1)
		.. " / 3\n"
		.. (if state.open
			then (if state.warning then "RETURN TO BASE" else "WAREHOUSE OPEN")
			else string.upper(state.phase or "Loading"))
		.. string.format("  %d:%02d", math.floor(seconds / 60), seconds % 60)
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
	ui.Collect.Text = if state.tooHeavy then "Too heavy" else "Collect"
	ui.Styles.Visible = state.ready and (state.inBase or not state.open)
	ui.Next.Visible = state.canNext == true
	ui.Next.Text = if state.stage == 3
		then "Finish match"
		else "Next: " .. (if state.stage == 1 then "Tech Run" else "Golden Rush")
	ui.Tutorial.Visible = not state.tutorial or not state.ready or warning or state.warning
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
