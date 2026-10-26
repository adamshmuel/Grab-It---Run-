--!strict
-- Client regression: state preservation and readable rows, not multiplayer evidence.
return function(): number
	local player = assert(game.Players.LocalPlayer, "ScoresLayout requires a client")
	local clone = game.ReplicatedStorage.GrabIt:Clone()
	local H = require(clone.ClientModules.Hud)
	local module = assert(clone.ClientModules:FindFirstChild("Scores"), "Scores dialog must exist")
	local S = require(module)
	local ui = H.create()
	ui.Screen.Parent = player.PlayerGui
	local scores = S.create(ui.Root)
	local ok, err = pcall(function()
		local rows = {}
		for i = 1, 8 do
			rows[i] = {
				id = tostring(i),
				name = "PlayerName1234567890",
				score = 433,
				percent = 100,
				finishTime = 165.24,
				ranked = i ~= 8,
				place = if i ~= 8 then i else nil,
			}
		end
		local state = {
			ready = true,
			phase = "active",
			remaining = 99,
			stage = 3,
			rows = rows,
			cargoWeight = "4 + ?",
			cargoValue = "7 + ?",
			coins = 0,
		}
		S.update(scores, state, "1")
		S.toggle(scores)
		assert(scores.Panel.Visible, "Scores opens during active collection")
		state.remaining = 98
		rows[1].score = 488
		S.update(scores, state, "1")
		assert(scores.Rows[1][3].Text == "488", "Deposits update while Scores stays open")
		assert(
			string.find(scores.Title.Text, "1:38", 1, true),
			"Clock remains visible and advances"
		)
		assert(
			state.remaining == 98
				and state.coins == 0
				and state.cargoWeight == "4 + ?"
				and state.cargoValue == "7 + ?",
			"Viewing scores must not mutate gameplay state"
		)
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
			S.update(scores, state, "1")
			task.wait()
			assert(
				ui.Scores.AbsoluteSize.X >= 48 and ui.Scores.AbsoluteSize.Y >= 48,
				"Scores target >= 48px"
			)
			assert(
				ui.Scores.AbsolutePosition.X + ui.Scores.AbsoluteSize.X
					<= ui.Styles.AbsolutePosition.X,
				"Scores and Styles must not overlap"
			)
			local cell = scores.Rows[8][5]
			assert(
				cell.AbsoluteSize.Y >= 26 and cell.TextSize >= 18 and cell.TextFits,
				"Score row readable"
			)
			assert(scores.Rows[8][1].TextFits, "Unranked must fit")
			assert(
				cell.AbsolutePosition.Y + cell.AbsoluteSize.Y
					<= scores.Panel.AbsolutePosition.Y + scores.Panel.AbsoluteSize.Y,
				"Eighth row stays inside panel"
			)
			assert(
				scores.Close.AbsoluteSize.X >= 48 and scores.Close.AbsoluteSize.Y >= 48,
				"Close target >= 48px"
			)
			local separateX = cell.AbsolutePosition.X + cell.AbsoluteSize.X
				<= scores.Close.AbsolutePosition.X
			local separateY = cell.AbsolutePosition.Y + cell.AbsoluteSize.Y
				<= scores.Close.AbsolutePosition.Y
			assert(separateX or separateY, "Close must not cover the eighth row")
		end
		S.toggle(scores)
		assert(not scores.Panel.Visible, "Scores closes on request")
		S.toggle(scores)
		state.phase = "results"
		S.update(scores, state, "1")
		assert(not scores.Panel.Visible, "Stage transition closes Scores")
		S.toggle(scores)
		assert(not scores.Panel.Visible, "Scores does not replace stage results")
		state.phase = "active"
		state.ready = false
		S.update(scores, state, "1")
		S.toggle(scores)
		assert(not scores.Panel.Visible, "Loading player cannot open Scores")
	end)
	S.destroy(scores)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, err)
	return 1
end
