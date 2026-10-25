--!strict
local Prompt = {}
type PromptUI = { Gui: ScreenGui, Label: TextLabel, Adornee: BasePart? }
type PromptState = {
	ready: boolean,
	open: boolean,
	target: number?,
	collected: { [number]: boolean },
	cargoCount: number,
	tooHeavy: boolean?,
	targetInfo: string?,
	targetName: string?,
}

function Prompt.create(parent: Instance): PromptUI
	local gui = Instance.new("ScreenGui")
	gui.Name = "GrabItTargetPrompt"
	gui.Enabled = false
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	gui.ClipToDeviceSafeArea = true
	gui.DisplayOrder = 1
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local label = Instance.new("TextLabel")
	label.Name = "Action"
	label.Size = UDim2.fromOffset(220, 66)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundColor3 = Color3.fromRGB(240, 189, 75)
	label.TextColor3 = Color3.fromRGB(25, 38, 47)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	gui.Parent = parent
	return { Gui = gui, Label = label, Adornee = nil }
end

function Prompt.update(ui: PromptUI, state: PromptState, items: Instance?, touch: boolean): ()
	local target = if state.ready
			and state.open
			and state.target
			and not state.collected[state.target]
			and items
		then items:FindFirstChild(tostring(state.target))
		else nil
	ui.Adornee = if target and target:IsA("BasePart") then target else nil
	ui.Gui.Enabled = ui.Adornee ~= nil
	ui.Label.Text = (if state.targetName then state.targetName .. "\n" else "")
		.. (if state.tooHeavy then "Too heavy" else (if touch then "Collect" else "Collect [E]"))
		.. (if state.targetInfo then "\n" .. state.targetInfo else "")
end

function Prompt.placement(anchor: Vector2, size: Vector2, bounds): Vector2
	local half = size / 2
	local left = bounds.left + half.X + 8
	local right = math.max(left, bounds.right - half.X - 8)
	local first = math.clamp(anchor.X - size.X * 0.65, left, right)
	local second = math.clamp(anchor.X + size.X * 0.65, left, right)
	local x = if math.abs(first - bounds.headX) > math.abs(second - bounds.headX)
		then first
		else second
	local top = bounds.top + half.Y + 8
	local bottom = math.max(top, bounds.bottom - half.Y - 8)
	return Vector2.new(x, math.clamp(anchor.Y, top, bottom))
end

function Prompt.place(ui: PromptUI, camera: Camera, bounds): ()
	local target = ui.Adornee
	if not ui.Gui.Enabled or not target or not target:IsA("BasePart") then
		return
	end
	local point = camera:WorldToViewportPoint(target.Position + Vector3.new(0, 2, 0))
	local ignore = { target.Parent }
	local character = game:GetService("Players").LocalPlayer.Character
	if character then
		table.insert(ignore, character)
	end
	if point.Z <= 0 or not Prompt.lineOfSight(camera.CFrame.Position, target.Position, ignore) then
		ui.Gui.Enabled = false
		return
	end
	local size = Vector2.new(ui.Label.Size.X.Offset, ui.Label.Size.Y.Offset)
	local placed = Prompt.placement(Vector2.new(point.X, point.Y), size, bounds)
	ui.Label.Position = UDim2.fromOffset(placed.X, placed.Y)
end

function Prompt.lineOfSight(origin: Vector3, target: Vector3, ignore: { Instance }): boolean
	local excluded = table.clone(ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	for _ = 1, 8 do
		params.FilterDescendantsInstances = excluded
		local hit = workspace:Raycast(origin, target - origin, params)
		if not hit then
			return true
		end
		local part = hit.Instance
		if
			not part:IsA("BasePart")
			or (part.LocalTransparencyModifier == 0 and part.Transparency < 0.95)
		then
			return false
		end
		table.insert(excluded, part)
	end
	return false
end

return Prompt
