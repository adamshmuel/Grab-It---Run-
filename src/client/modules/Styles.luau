--!strict
local Ui = require(script.Parent.Ui)
local shared = script.Parent.Parent.Shared
local Cosmetics = require(shared.Cosmetics)
local Gear = require(shared.Gear)
local Styles = {}
local function fitPreview(preview: ViewportFrame, model: Model, camera: Camera)
	local area = preview.AbsoluteSize
	if area.X <= 0 or area.Y <= 0 then
		return
	end
	local bounds, size = model:GetBoundingBox()
	local center = bounds.Position
	local direction = Vector3.new(3, 1.4, -4).Unit
	local rotation = CFrame.lookAt(direction, Vector3.zero).Rotation
	local vertical = math.tan(math.rad(camera.FieldOfView / 2))
	local horizontal = vertical * area.X / area.Y
	local distance = 0.5
	for _, x in { -1, 1 } do
		for _, y in { -1, 1 } do
			for _, z in { -1, 1 } do
				local corner = bounds:PointToWorldSpace(size * Vector3.new(x, y, z) / 2)
				local point = rotation:VectorToObjectSpace(corner - center)
				distance = math.max(
					distance,
					point.Z + math.abs(point.X) / (horizontal * 0.88),
					point.Z + math.abs(point.Y) / (vertical * 0.88)
				)
			end
		end
	end
	camera.CFrame = CFrame.lookAt(center + direction * distance, center)
end
local function updateStatus(ui, state)
	local style = if ui.errorStyle then Cosmetics.get(ui.errorStyle) else nil
	if
		style
		and (os.clock() >= ui.errorUntil or state.coins >= style.price or state.owned[style.id])
	then
		ui.errorStyle = nil
	end
	local pending = state.purchase or ""
	ui.Status.Text = if pending ~= ""
		then pending
		elseif ui.errorStyle then "Not enough Coins."
		else ""
end
function Styles.activate(ui, id: string)
	local state = ui.state
	local style = Cosmetics.get(id)
	if
		not style
		or not state
		or not state.ready
		or not ui.Panel.Visible
		or not (state.inBase or not state.open)
	then
		return
	end
	if state.owned[id] then
		ui.errorStyle = nil
		ui.Request("equip", id)
	elseif (state.purchase or "") == "" then
		if state.coins >= style.price then
			ui.errorStyle = nil
			ui.Request("buy", id)
		else
			ui.errorStyle = id
			ui.errorUntil = os.clock() + 3
		end
	end
	updateStatus(ui, state)
end
function Styles.create(parent: Instance, request: (string, string) -> ())
	local panel = Ui.panel(parent, "StyleCollection")
	panel.ZIndex = 30
	panel.Size = UDim2.fromScale(0.96, 0.96)
	local title = Ui.label(panel, "Title", UDim2.new(), UDim2.new(0.82, 0, 0, 32), "Styles")
	local close =
		Ui.label(panel, "Close", UDim2.new(1, -64, 0, 0), UDim2.fromOffset(64, 48), "Close", true)
	local status =
		Ui.label(panel, "PurchaseStatus", UDim2.fromOffset(0, 30), UDim2.new(0.82, 0, 0, 22), "")
	local cards = {}
	local connections = {}
	local ui = {
		Panel = panel,
		Title = title,
		Status = status,
		Cards = cards,
		state = nil,
		Connections = connections,
		Request = request,
	}
	table.insert(
		connections,
		panel:GetPropertyChangedSignal("Visible"):Connect(function()
			if not panel.Visible then
				ui.errorStyle = nil
				ui.Status.Text = if ui.state then ui.state.purchase or "" else ""
			end
		end)
	)
	table.insert(
		connections,
		close.Activated:Connect(function()
			panel.Visible = false
		end)
	)
	for i, style in Cosmetics.list do
		local card = Instance.new("Frame")
		card.Name = style.id
		card.Position = UDim2.new((i - 1) * 0.25, 4, 0, 52)
		card.Size = UDim2.new(0.25, -8, 1, -58)
		card.BackgroundColor3 = Color3.fromRGB(29, 43, 62)
		card.BorderSizePixel = 0
		card.Parent = panel
		local name = Ui.label(card, "Name", UDim2.new(), UDim2.new(1, 0, 0, 28), style.name)
		name.TextSize = 18
		local preview = Instance.new("ViewportFrame")
		preview.Size = UDim2.new(1, 0, 1, -80)
		preview.Position = UDim2.fromOffset(0, 28)
		preview.BackgroundColor3 = Color3.fromRGB(85, 106, 127)
		preview.BackgroundTransparency = 0
		preview.Ambient = Color3.new(0.8, 0.8, 0.8)
		preview.LightColor = Color3.new(1, 1, 1)
		preview.Parent = card
		local model = Gear.create(style.id)
		model.Parent = preview
		local camera = Instance.new("Camera")
		camera.CFrame = CFrame.lookAt(Vector3.new(3, 1.4, -4), Vector3.new(0, 0, 0))
		camera.FieldOfView = 42
		camera.Parent = preview
		preview.CurrentCamera = camera
		fitPreview(preview, model, camera)
		table.insert(
			connections,
			preview:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				fitPreview(preview, model, camera)
			end)
		)
		local button =
			Ui.label(card, "Action", UDim2.new(0, 0, 1, -48), UDim2.new(1, 0, 0, 48), "", true)
		cards[i] = { Button = button, Preview = preview }
		table.insert(
			connections,
			button.Activated:Connect(function()
				Styles.activate(ui, style.id)
			end)
		)
	end
	return ui
end
function Styles.update(ui, state)
	ui.state = state
	local compact = ui.Panel.Parent.AbsoluteSize.Y < 400
	ui.Panel.Size = UDim2.fromScale(if compact then 0.78 else 0.96, 0.96)
	ui.Panel.Position = UDim2.fromScale(if compact then 0.59 else 0.5, 0.5)
	if not state.ready or (state.open and not state.inBase) then
		ui.Panel.Visible = false
	end
	local all = true
	for i, style in Cosmetics.list do
		local owned = state.owned and state.owned[style.id]
		if not owned then
			all = false
		end
		local button = ui.Cards[i].Button
		button.Text = if state.selected == style.id
			then "Equipped"
			elseif owned then "Equip"
			elseif state.purchase ~= "" then "Pending"
			else "Buy " .. style.price
		button.BackgroundColor3 = if owned
			then Color3.fromRGB(43, 115, 101)
			else Color3.fromRGB(113, 81, 40)
	end
	ui.Title.Text = "Styles | Coins " .. state.coins .. (if all then " | All designs owned" else "")
	if not ui.Panel.Visible then
		ui.errorStyle = nil
	end
	updateStatus(ui, state)
end
function Styles.destroy(ui)
	for _, c in ui.Connections do
		c:Disconnect()
	end
	ui.Panel:Destroy()
end
return Styles
