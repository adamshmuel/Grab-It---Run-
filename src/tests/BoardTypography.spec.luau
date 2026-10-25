--!strict
return function(): number
	local modules = game.ReplicatedStorage.GrabIt.ClientModules:Clone()
	local R = require(modules.Results)
	local owner = Instance.new("Folder")
	local part = Instance.new("Part")
	local board = R.board(owner, part)
	local ok, err = pcall(function()
		-- World-space tables need their own type scale. A state update must
		-- preserve it rather than silently reverting to the screen-table size.
		board.Rows[1][3].TextSize = 30
		R.fill(
			board,
			{ { id = "a", name = "Adam", score = 17, percent = 20, ranked = true, place = 1 } },
			"a",
			false
		)
		assert(board.Rows[1][3].Text == "17", "The board receives the deposited score")
		assert(
			board.Rows[1][3].TextSize == 30,
			"Updating a score must preserve world-board typography"
		)
	end)
	owner:Destroy()
	part:Destroy()
	modules:Destroy()
	assert(ok, err)
	return 1
end
