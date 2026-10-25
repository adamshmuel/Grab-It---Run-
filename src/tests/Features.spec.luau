--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared
	local features = shared:FindFirstChild("Presentation")
	assert(features, "RED: Presentation must exist for progression, item selection and HUD")
	local fresh = features:Clone()
	local View = require(fresh :: ModuleScript)
	fresh:Destroy()
	local function check(value, name)
		assert(value, name)
	end
	local items =
		{ { id = 1, x = -12, z = 12 }, { id = 2, x = 12, z = 12 }, { id = 3, x = -12, z = 18 } }
	check(View.nearest(items, {}, 1, -12, 3, 12) == 1, "nearest item")
	check(
		View.nearest(items, { [1] = true }, 1, -12, 3, 12) == nil,
		"collected items hidden, distance measured in 3D"
	)
	check(View.nearest(items, {}, 1, 0, 3, 12) == nil, "outside range")
	check(View.inDeposit(0, 3, -8) and not View.inDeposit(9, 3, -8), "deposit boundary")
	check(View.inWarehouse(0, 3, 1) and not View.inWarehouse(0, 3, -1), "warehouse boundary")
	assert(View.camera(Vector3.new(0, 4, -18)).LookVector.Z > 0, "initial camera faces warehouse")
	check(
		math.abs(
			(View.camera(Vector3.new(0, 4, -18)).Position - Vector3.new(0, 6, -18)).Magnitude - 14
		) < 0.001,
		"initial camera starts fourteen studs from its focus"
	)
	local stale = { ready = true, open = true, target = 2, roundId = 1, collected = {} }
	check(
		View.collectionTarget(items, stale, Vector3.new(12.074, 3.725, 18.065)) == nil,
		"stale server hint outside six studs is not actionable"
	)
	check(
		View.collectionTarget(items, stale, Vector3.new(12, 3.725, 16)) == 2,
		"nearby item uses current local position"
	)
	print("PASS targeting, camera and world boundaries")
	return 6
end
