--!strict
return function(): number
	local p = assert(game.Players.LocalPlayer, "StylesLayout requires a client")
	local clone = game.ReplicatedStorage.GrabIt:Clone()
	local H = require(clone.ClientModules.Hud)
	local S = require(clone.ClientModules.Styles)
	local ui = H.create()
	ui.Screen.Parent = p.PlayerGui
	ui.Root.Size = UDim2.fromOffset(706, 281)
	local requests = {}
	local collection = S.create(ui.Root, function(action, id)
		table.insert(requests, { action, id })
	end)
	collection.Panel.Visible = true
	local ok, err = pcall(function()
		task.wait()
		S.update(collection, {
			ready = true,
			inBase = true,
			open = true,
			owned = { basic = true },
			selected = "basic",
			coins = 62,
			purchase = "",
		})
		task.wait()
		local button = collection.Cards[1].Button
		assert(
			button.AbsolutePosition.X >= ui.Root.AbsolutePosition.X + ui.Root.AbsoluteSize.X * 0.2,
			"Style actions must leave the mobile joystick region clear"
		)
		for _, card in collection.Cards do
			assert(card.Button.AbsoluteSize.Y >= 48, "Style actions keep a 48px touch target")
			assert(
				card.Button.Parent:FindFirstChild("Name").TextFits,
				"Design names remain readable"
			)
		end
		ui.Root.Size = UDim2.fromOffset(923, 592)
		S.update(collection, {
			ready = true,
			inBase = true,
			open = true,
			owned = { basic = true },
			selected = "basic",
			coins = 62,
			purchase = "",
		})
		task.wait()
		for _, card in collection.Cards do
			local preview = card.Preview
			local camera = assert(preview.CurrentCamera, "Equipment preview needs a camera")
			local halfHeight = math.tan(math.rad(camera.FieldOfView / 2))
			local halfWidth = halfHeight * preview.AbsoluteSize.X / preview.AbsoluteSize.Y
			local model =
				assert(preview:FindFirstChildWhichIsA("Model"), "Equipment preview needs its model")
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					for _, x in { -1, 1 } do
						for _, y in { -1, 1 } do
							for _, z in { -1, 1 } do
								local corner = part.CFrame:PointToWorldSpace(
									part.Size * Vector3.new(x, y, z) / 2
								)
								local point = camera.CFrame:PointToObjectSpace(corner)
								assert(
									point.Z < 0
										and math.abs(point.X) < -point.Z * halfWidth * 0.96
										and math.abs(point.Y) < -point.Z * halfHeight * 0.96,
									"Every equipment part must fit inside its preview with margin, including wide cases"
								)
							end
						end
					end
				end
			end
		end
		local owned: { [string]: boolean } = { basic = true }
		local state = {
			ready = true,
			inBase = true,
			open = true,
			owned = owned,
			selected = "basic",
			coins = 99,
			purchase = "",
		}
		S.update(collection, state)
		collection.Panel.Visible = true
		S.activate(collection, "canvas")
		assert(
			collection.Status.Text == "Not enough Coins.",
			"Insufficient Coins has a simple visible message"
		)
		assert(#requests == 0, "Rejected purchases do not send buy or equip requests")
		S.update(collection, state)
		assert(
			collection.Status.Text == "Not enough Coins.",
			"State updates must not erase the message"
		)
		state.coins = 100
		S.update(collection, state)
		assert(
			collection.Status.Text == "" and #requests == 0,
			"New funds clear the error without buying"
		)
		S.activate(collection, "canvas")
		assert(
			#requests == 1 and requests[1][1] == "buy" and requests[1][2] == "canvas",
			"Exact funds request one purchase"
		)
		state.purchase = "Purchase pending"
		state.coins = 0
		S.update(collection, state)
		S.activate(collection, "field")
		assert(
			collection.Status.Text == "Purchase pending" and #requests == 1,
			"Pending wins over local errors and duplicate buys"
		)
		state.purchase = ""
		state.owned.canvas = true
		S.update(collection, state)
		S.activate(collection, "canvas")
		assert(#requests == 2 and requests[2][1] == "equip", "Owned styles equip with zero Coins")
		state.owned.canvas = nil
		S.update(collection, state)
		S.activate(collection, "canvas")
		collection.Panel.Visible = false
		task.wait()
		collection.Panel.Visible = true
		S.update(collection, state)
		assert(collection.Status.Text == "", "Reopening does not restore stale errors")
		S.activate(collection, "canvas")
		task.wait(3.1)
		S.update(collection, state)
		assert(collection.Status.Text == "", "The simple message expires")
	end)
	S.destroy(collection)
	ui.Screen:Destroy()
	clone:Destroy()
	assert(ok, err)
	return 2
end
