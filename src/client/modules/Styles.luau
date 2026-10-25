--!strict
local Ui = require(script.Parent.Ui)
local shared = script.Parent.Parent.Shared
local Cosmetics = require(shared.Cosmetics)
local Gear = require(shared.Gear)
local Styles = {}
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
	}
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
		preview.BackgroundTransparency = 1
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
		local button =
			Ui.label(card, "Action", UDim2.new(0, 0, 1, -48), UDim2.new(1, 0, 0, 48), "", true)
		cards[i] = { Button = button, Preview = preview }
		table.insert(
			connections,
			button.Activated:Connect(function()
				local state = ui.state
				if not state or not state.ready or not (state.inBase or not state.open) then
					return
				end
				if state.owned[style.id] then
					request("equip", style.id)
				elseif state.purchase == "" and state.coins >= style.price then
					request("buy", style.id)
				end
			end)
		)
	end
	return ui
end
function Styles.update(ui, state)
	ui.state = state
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
	ui.Status.Text = state.purchase or ""
end
function Styles.destroy(ui)
	for _, c in ui.Connections do
		c:Disconnect()
	end
	ui.Panel:Destroy()
end
return Styles
