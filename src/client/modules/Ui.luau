--!strict
local Ui = {}
function Ui.label(
	parent: Instance,
	name: string,
	pos: UDim2,
	size: UDim2,
	text: string,
	button: boolean?
)
	local v = Instance.new(if button then "TextButton" else "TextLabel")
	v.Name = name
	v.Position = pos
	v.Size = size
	v.Text = text
	v.TextSize = 18
	v.Font = Enum.Font.GothamBold
	v.TextColor3 = Color3.fromRGB(237, 242, 237)
	v.BackgroundColor3 = Color3.fromRGB(29, 43, 62)
	v.BorderSizePixel = 0
	v.TextTruncate = Enum.TextTruncate.AtEnd
	v.Parent = parent
	return v
end
function Ui.panel(parent: Instance, name: string): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5, 0.5)
	f.Size = UDim2.fromScale(0.96, 1)
	f.BackgroundColor3 = Color3.fromRGB(16, 26, 44)
	f.BorderSizePixel = 0
	f.Visible = false
	f.ZIndex = 20
	f.Parent = parent
	return f
end
return table.freeze(Ui)
