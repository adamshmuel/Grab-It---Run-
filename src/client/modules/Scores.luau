--!strict
local Ui = require(script.Parent.Ui)
local Results = require(script.Parent.Results)
local Scores = {}

function Scores.create(parent: Instance)
	local panel = Ui.panel(parent, "LiveScores")
	local title = Ui.label(panel, "Title", UDim2.new(), UDim2.new(1, 0, 0, 22), "LIVE RESULTS")
	local grid = Results.table(panel)
	local close =
		Ui.label(panel, "Close", UDim2.new(0.78, 0, 0, 6), UDim2.new(0.22, 0, 0, 48), "Close", true)
	local ui = {
		Panel = panel,
		Title = title,
		Container = grid.Container,
		Header = grid.Header,
		Rows = grid.Rows,
		Close = close,
		available = false,
	}
	ui.connection = close.Activated:Connect(function()
		panel.Visible = false
	end)
	return ui
end

function Scores.toggle(ui)
	ui.Panel.Visible = ui.available and not ui.Panel.Visible
end

function Scores.update(ui, state, localId: string)
	ui.available = state.ready and state.phase == "active"
	if not ui.available then
		ui.Panel.Visible = false
	end
	local compact = ui.Panel.AbsoluteSize.Y < 310
	ui.Container.Size = UDim2.fromScale(if compact then 0.76 else 1, 1)
	ui.Title.Size = UDim2.new(if compact then 0.76 else 1, 0, 0, 22)
	ui.Close.Position = if compact then UDim2.new(0.78, 0, 0, 6) else UDim2.new(0.78, 0, 1, -48)
	local seconds = math.max(0, state.remaining)
	ui.Title.Text = string.format(
		"LIVE RESULTS | %d / 3 | %d:%02d",
		state.stage,
		math.floor(seconds / 60),
		seconds % 60
	)
	Results.fill(ui, state.rows or {}, localId, false)
end

function Scores.destroy(ui)
	ui.connection:Disconnect()
	ui.Panel:Destroy()
end

return Scores
