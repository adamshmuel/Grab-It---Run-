--!strict
return function(): number
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared:Clone()
	local R = require(shared.GameRules)
	local a, b = R.newPlayer(), R.newPlayer()
	assert(a.coins == 0 and #a.cargo == 0 and R.speed(a) == 16, "fresh player")
	assert(
		not R.collect(a, 1, 1, false, 0) and not R.collect(a, 1, 1, true, 6.01),
		"closed and distant rejected"
	)
	assert(R.collect(a, 1, 1, true, 6) and R.collect(b, 1, 1, true, 6), "personal copies")
	assert(not R.collect(a, 1, 1, true, 0), "duplicate rejected")
	assert(R.bank(a) == 2 and R.bank(a) == 0 and a.coins == 2, "bank exactly once")
	assert(R.collect(a, 2, 1, true, 0), "Gameplay.spec: R.collect(a, 2, 1, true, 0)")
	R.lose(a)
	assert(
		a.coins == 2 and not a.collected[2],
		"Gameplay.spec: a.coins == 2 and not a.collected[2]"
	)
	R.beginStage(a, 2, 2)
	assert(
		R.collect(a, 1, 2, true, 0) and R.bank(a) == 3 and a.coins == 5,
		"subsequent stage continues"
	)
	shared:Destroy()
	return 7
end
