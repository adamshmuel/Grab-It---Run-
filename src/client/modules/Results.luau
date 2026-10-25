--!strict
local Ui = require(script.Parent.Ui)
local Results = {}
local widths = { 0.20, 0.25, 0.17, 0.18, 0.20 }
function Results.table(parent: Instance)
	local container = Instance.new("Frame")
	container.Name = "ResultTable"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = parent
	local header = {}
	local rows = {}
	local x = 0
	for col, width in widths do
		header[col] = Ui.label(
			container,
			"Column" .. col,
			UDim2.new(x, 0, 0, 22),
			UDim2.new(width, 0, 0, 22),
			""
		)
		x += width
	end
	for i = 1, 8 do
		local cells = {}
		x = 0
		for col, width in widths do
			cells[col] = Ui.label(
				container,
				"Row" .. i .. "Column" .. col,
				UDim2.new(x, 0, 0, 44 + (i - 1) * 26),
				UDim2.new(width, 0, 0, 26),
				""
			)
			x += width
		end
		rows[i] = cells
	end
	return { Container = container, Header = header, Rows = rows }
end
function Results.fill(grid, rows, localId: string, match: boolean)
	local titles = if match
		then { "#", "Player", "Points", "Eligible", "" }
		else { "#", "Player", "Score", "Banked", "Finish" }
	for i, v in grid.Header do
		v.Text = titles[i]
	end
	for index, cells in grid.Rows do
		local row = rows[index]
		for col, cell in cells do
			cell.Visible = row ~= nil
			cell.BackgroundColor3 = if row and row.id == localId
				then Color3.fromRGB(41, 95, 102)
				else Color3.fromRGB(29, 43, 62)
			if row then
				local values = if match
					then {
						if row.place then tostring(row.place) else "—",
						row.name,
						tostring(row.points),
						if row.eligible then "Yes" else "No",
						"",
					}
					else {
						if row.place then tostring(row.place) else "—",
						row.name,
						tostring(row.score),
						tostring(row.percent) .. "%",
						if row.finishTime then string.format("%.2fs", row.finishTime) else "—",
					}
				cell.Text = values[col]
				if col == 1 and not match and not row.ranked then
					cell.Text = "Unranked"
				end
			end
		end
	end
end
function Results.create(parent: Instance)
	local panel = Ui.panel(parent, "StageResults")
	local title = Ui.label(panel, "Title", UDim2.new(), UDim2.new(1, 0, 0, 22), "")
	local grid = Results.table(panel)
	local footer =
		Ui.label(panel, "NextStage", UDim2.new(0, 0, 1, -48), UDim2.new(0.65, 0, 0, 48), "")
	local replay = Ui.label(
		panel,
		"Replay",
		UDim2.new(0.65, 0, 1, -48),
		UDim2.new(0.35, 0, 0, 48),
		"Play again",
		true
	)
	local tab = Ui.label(
		panel,
		"LastStage",
		UDim2.new(0, 0, 1, -48),
		UDim2.new(0.32, 0, 0, 48),
		"Stage 3",
		true
	)
	local styles = Ui.label(
		panel,
		"Styles",
		UDim2.new(0.33, 0, 1, -48),
		UDim2.new(0.32, 0, 0, 48),
		"Styles",
		true
	)
	return {
		Panel = panel,
		Container = grid.Container,
		Title = title,
		Header = grid.Header,
		Rows = grid.Rows,
		Footer = footer,
		Replay = replay,
		Tab = tab,
		Styles = styles,
		showStage = false,
	}
end
local function layout(ui)
	local compact = ui.Panel.AbsoluteSize.Y < 310
	ui.Container.Size = UDim2.fromScale(if compact then 0.76 else 1, 1)
	ui.Title.Size = UDim2.new(if compact then 0.76 else 1, 0, 0, 22)
	ui.Footer.TextWrapped = compact
	ui.Footer.TextTruncate = if compact then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd
	if compact then
		ui.Footer.Position = UDim2.new(0.78, 0, 0, 30)
		ui.Footer.Size = UDim2.new(0.22, 0, 0, 110)
		ui.Styles.Position = UDim2.new(0.78, 0, 0, 160)
		ui.Styles.Size = UDim2.new(0.22, 0, 0, 48)
		for _, button in { ui.Tab, ui.Replay } do
			button.Position = UDim2.new(0.78, 0, 0, 218)
			button.Size = UDim2.new(0.22, 0, 0, 48)
		end
	else
		ui.Footer.Position = UDim2.new(0, 0, 1, -48)
		ui.Footer.Size = UDim2.new(0.65, 0, 0, 48)
		ui.Replay.Position = UDim2.new(0.65, 0, 1, -48)
		ui.Replay.Size = UDim2.new(0.35, 0, 0, 48)
		ui.Tab.Position = UDim2.new(0, 0, 1, -48)
		ui.Tab.Size = UDim2.new(0.32, 0, 0, 48)
		ui.Styles.Position = if ui.summary
			then UDim2.new(0.33, 0, 1, -48)
			else UDim2.new(0.65, 0, 1, -48)
		ui.Styles.Size = UDim2.new(if ui.summary then 0.32 else 0.35, 0, 0, 48)
	end
end
function Results.update(ui, state, localId: string)
	ui.Panel.Visible = state.phase == "results" or state.phase == "summary"
	if not ui.Panel.Visible then
		ui.showStage = false
		return
	end
	local personal = state.personal or { earnings = 0, stages = { 0, 0, 0 } }
	local summary = state.phase == "summary"
	ui.summary = summary
	layout(ui)
	ui.Title.Text = (if summary then "Match results" else "Stage " .. state.stage .. " results")
		.. " | Earned "
		.. personal.earnings
		.. (if summary and state.remaining <= 3 then " | Next match in " else " | ")
		.. state.remaining
		.. "s"
	ui.Replay.Visible = summary and state.mode == "solo"
	ui.Tab.Visible = summary and state.mode ~= "solo"
	ui.Styles.Visible = true
	ui.Footer.Visible = not summary
	ui.Footer.Text = "Next: "
		.. (if state.stage == 1 then "Tech Run | Capacity 14" else "Golden Rush | Capacity 18")
	if summary and state.mode == "solo" and not ui.showStage then
		for i, h in ui.Header do
			h.Text = ({ "Stage", "Name", "Earned", "", "" })[i]
		end
		for i, cells in ui.Rows do
			for col, cell in cells do
				cell.Visible = i <= 3
				if i <= 3 then
					cell.Text = ({
						tostring(i),
						({ "Toy Dash", "Tech Run", "Golden Rush" })[i],
						tostring(personal.stages[i]),
						"",
						"",
					})[col]
				end
			end
		end
	else
		Results.fill(
			ui,
			if summary and not ui.showStage then state.matchRows or {} else state.rows or {},
			localId,
			summary and not ui.showStage
		)
	end
	ui.Tab.Text = if ui.showStage then "Match results" else "Stage 3"
end
function Results.board(parent: Instance, part: BasePart)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "PersonalLiveResults"
	gui.Adornee = part
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.CanvasSize = Vector2.new(720, 480)
	gui.LightInfluence = 0
	gui.AlwaysOnTop = false
	gui.Parent = parent
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(16, 26, 44)
	frame.Parent = gui
	local title = Ui.label(frame, "Title", UDim2.new(), UDim2.new(1, 0, 0, 22), "LIVE RESULTS")
	local grid = Results.table(frame)
	-- The wall uses the same data but a larger canvas and row spacing.
	title.TextSize = 32
	title.Size = UDim2.new(1, 0, 0, 44)
	for _, h in grid.Header do
		h.Position = UDim2.new(h.Position.X.Scale, 0, 0, 48)
		h.Size = UDim2.new(h.Size.X.Scale, 0, 0, 36)
		h.TextSize = 28
	end
	for i, cells in grid.Rows do
		for _, cell in cells do
			cell.Position = UDim2.new(cell.Position.X.Scale, 0, 0, 84 + (i - 1) * 46)
			cell.Size = UDim2.new(cell.Size.X.Scale, 0, 0, 46)
			cell.TextSize = 32
		end
	end
	grid.Gui = gui
	return grid
end
return Results
