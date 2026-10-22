--!strict
local View = require(script.Parent.Parent.Shared.Presentation)
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
	constraint.MinTextSize = 11
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
	local coins = box(root, "Coins", UDim2.fromScale(0.02, 0.02), UDim2.fromScale(0.27, 0.13))
	local round = box(root, "Round", UDim2.fromScale(0.32, 0.02), UDim2.fromScale(0.36, 0.13))
	local style = box(root, "Style", UDim2.fromScale(0.71, 0.02), UDim2.fromScale(0.27, 0.13))
	local bag = box(root, "Bag", UDim2.fromScale(0.29, 0.72), UDim2.fromScale(0.42, 0.10))
	local message = box(root, "Message", UDim2.fromScale(0.21, 0.18), UDim2.fromScale(0.58, 0.13))
	message.BackgroundTransparency = 0.2
	message.Visible = false
	local tutorial = box(root, "Tutorial", UDim2.fromScale(0.22, 0.85), UDim2.fromScale(0.52, 0.09))
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
	local corner = Instance.new("UICorner")
	corner.Parent = button
	corner.CornerRadius = UDim.new(0, 12)
	return {
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
	local savingWarning = string.sub(state.save, 1, 13) == "Not saved yet"
	ui.Coins.Text = "COINS "
		.. state.coins
		.. "\n"
		.. (if savingWarning then "Not saved yet" else state.save)
	local seconds = math.max(0, state.remaining)
	ui.Round.Text = (
		if state.open
			then (if state.warning then "RETURN TO BASE" else "WAREHOUSE OPEN")
			else "WAREHOUSE CLOSED"
	) .. string.format("\n%d:%02d", math.floor(seconds / 60), seconds % 60)
	ui.Round.TextColor3 = if state.warning
		then Color3.fromRGB(255, 188, 111)
		else Color3.fromRGB(236, 247, 240)
	ui.Bag.Text = string.format("BAG  %d / 5     VALUE  %d", state.cargoCount, state.cargoValue)
	local style = View.style(state.coins)
	ui.Style.Text = if style.target
		then "NEXT: " .. string.upper(style.nextName) .. "\n" .. state.coins .. " / " .. style.target
		else "ALL STYLES\nUNLOCKED"
	ui.Collect.Visible = state.open and state.target ~= nil and state.ready == true
	ui.Collect.Text = if state.cargoCount >= 5
		then "Bag full"
		else (if touch then "Collect" else "Collect [E]")
	ui.Tutorial.Visible = not state.tutorial or not state.ready or savingWarning
	ui.Tutorial.Text = if savingWarning
		then state.save
		elseif not state.ready then state.save
		elseif not state.open then "Next round in " .. state.remaining .. "s"
		elseif state.cargoCount > 0 then "Return before closing"
		else "Collect items. Return here to bank them."
end
return Hud
