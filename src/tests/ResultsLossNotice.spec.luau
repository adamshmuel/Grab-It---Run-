--!strict
-- Client layout regression; native expiry is verified separately.
return function(): number
	local player = assert(game.Players.LocalPlayer, "ResultsLossNotice requires a client")
	local clone = game.ReplicatedStorage.GrabIt:Clone()
	local Hud = require(clone.ClientModules.Hud)
	local Results = require(clone.ClientModules.Results)
	local ui = Hud.create()
	ui.Screen.Parent = player.PlayerGui
	local results = Results.create(ui.Root)
	local notice = "Cargo lost. Banked coins kept"
	local function overlaps(a, b)
		return a.Visible
			and b.Visible
			and a.AbsolutePosition.X < b.AbsolutePosition.X + b.AbsoluteSize.X
			and a.AbsolutePosition.X + a.AbsoluteSize.X > b.AbsolutePosition.X
			and a.AbsolutePosition.Y < b.AbsolutePosition.Y + b.AbsoluteSize.Y
			and a.AbsolutePosition.Y + a.AbsoluteSize.Y > b.AbsolutePosition.Y
	end
	local count = 0
	local ok, err = pcall(function()
		local rows = {}
		for i = 1, 8 do
			rows[i] = {
				id = tostring(i),
				name = "Player" .. i,
				score = 433,
				percent = 100,
				finishTime = 90,
				ranked = true,
				place = i,
				points = 28,
				eligible = true,
			}
		end
		for _, size in
			{
				Vector2.new(706, 281),
				Vector2.new(750, 332),
				Vector2.new(1280, 662),
				Vector2.new(1920, 1022),
			}
		do
			ui.Root.Size = UDim2.fromOffset(size.X, size.Y)
			task.wait()
			for _, scenario in { { 1, "multi" }, { 2, "multi" }, { 3, "multi" }, { 3, "solo" } } do
				local state = {
					phase = if scenario[1] == 3 then "summary" else "results",
					stage = scenario[1],
					mode = scenario[2],
					remaining = 5,
					rows = rows,
					matchRows = rows,
					personal = { earnings = 433, stages = { 100, 200, 133 } },
				}
				Results.update(results, state, "1", notice)
				task.wait()
				assert(
					results.Footer.Visible and string.find(results.Footer.Text, notice, 1, true),
					"Cargo loss must remain visible inside results and match summary"
				)
				assert(results.Footer.TextFits, "Loss and next-stage information must fit")
				for _, cells in results.Rows do
					for _, cell in cells do
						assert(
							not overlaps(results.Footer, cell),
							"Loss must not cover a result cell"
						)
					end
				end
				for _, other in { results.Title, results.Styles, results.Replay, results.Tab } do
					assert(
						not overlaps(results.Footer, other),
						"Loss must not cover "
							.. other.Name
							.. " at "
							.. tostring(size)
							.. " stage "
							.. tostring(state.stage)
							.. " "
							.. state.mode
					)
				end
				Results.update(results, state, "1", nil)
				assert(
					not string.find(results.Footer.Text, notice, 1, true),
					"Expired loss must clear"
				)
				if state.phase == "results" then
					assert(
						string.find(results.Footer.Text, "Next:", 1, true),
						"Keep next-stage information"
					)
				else
					assert(not results.Footer.Visible, "Summary notice clears after expiry")
				end
				count += 1
			end
		end
	end)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, err)
	return count
end
