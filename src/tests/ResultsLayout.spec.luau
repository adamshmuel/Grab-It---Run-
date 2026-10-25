--!strict
-- Client geometry regression; does not establish touch or leaderboard replication.
return function(): number
	local player = assert(game.Players.LocalPlayer, "ResultsLayout requires a client")
	local clone = game.ReplicatedStorage.GrabIt:Clone()
	local H = require(clone.ClientModules.Hud)
	local R = require(clone.ClientModules.Results)
	local ui = H.create()
	ui.Screen.Parent = player.PlayerGui
	local results = R.create(ui.Root)
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
		for _, size in { Vector2.new(706, 281), Vector2.new(750, 332), Vector2.new(1280, 662) } do
			ui.Root.Size = UDim2.fromOffset(size.X, size.Y)
			task.wait()
			R.update(results, {
				phase = "results",
				stage = 1,
				mode = "multi",
				remaining = 5,
				rows = rows,
				personal = { earnings = 433, stages = { 433, 0, 0 } },
			}, "1")
			task.wait()
			local lastRow = results.Rows[8][3]
			local function overlaps(a, b)
				return a.AbsolutePosition.X < b.AbsolutePosition.X + b.AbsoluteSize.X
					and a.AbsolutePosition.X + a.AbsoluteSize.X > b.AbsolutePosition.X
					and a.AbsolutePosition.Y < b.AbsolutePosition.Y + b.AbsoluteSize.Y
					and a.AbsolutePosition.Y + a.AbsoluteSize.Y > b.AbsolutePosition.Y
			end
			assert(
				not overlaps(lastRow, results.Footer),
				"Eight-player rows must not overlap next-stage information"
			)
			assert(not overlaps(results.Rows[8][5], results.Styles), "Rows must not overlap Styles")
			assert(lastRow.AbsoluteSize.Y >= 26, "Keep approved row height")
			assert(results.Rows[8][1].TextFits, "Unranked must be readable without truncation")
			assert(
				results.Rows[8][3].TextFits and results.Rows[8][5].TextFits,
				"Scores and finish times must fit"
			)
		end
	end)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, err)
	return 1
end
