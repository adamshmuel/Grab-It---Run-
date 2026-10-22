--!strict
local Prompt = {}
type PromptUI = { Gui: BillboardGui, Label: TextLabel }
type PromptState = {
	ready: boolean,
	open: boolean,
	target: number?,
	collected: { [number]: boolean },
	cargoCount: number,
}

function Prompt.create(parent: Instance): PromptUI
	local gui = Instance.new("BillboardGui")
	gui.Name = "GrabItTargetPrompt"
	gui.Enabled = false
	gui.ResetOnSpawn = false
	gui.AlwaysOnTop = false
	gui.MaxDistance = 32
	gui.Size = UDim2.fromOffset(156, 34)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
	local label = Instance.new("TextLabel")
	label.Name = "Action"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(240, 189, 75)
	label.TextColor3 = Color3.fromRGB(25, 38, 47)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 20
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	gui.Parent = parent
	return { Gui = gui, Label = label }
end

function Prompt.update(ui: PromptUI, state: PromptState, items: Instance?, touch: boolean): ()
	local target = if state.ready
			and state.open
			and state.target
			and not state.collected[state.target]
			and items
		then items:FindFirstChild(tostring(state.target))
		else nil
	ui.Gui.Adornee = if target and target:IsA("BasePart") then target else nil
	ui.Gui.Enabled = ui.Gui.Adornee ~= nil
	ui.Label.Text = if state.cargoCount >= 5
		then "Bag full"
		else (if touch then "Collect" else "Collect [E]")
end

return Prompt
