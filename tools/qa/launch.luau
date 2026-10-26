--!strict
return function(
	players: number,
	duration: number,
	collectionOnly: boolean?,
	loopSmoke: boolean?,
	routePlan: string?,
	staggered: boolean?
)
	assert(game:GetService("RunService"):IsStudio(), "Studio-only QA")
	assert(not game:GetService("RunService"):IsRunning(), "launch from Edit")
	assert(
		game.PlaceId == 0 and game:GetService("ReplicatedStorage"):FindFirstChild("GrabIt"),
		"verify project first"
	)
	assert(
		players >= 1 and players <= 8 and players % 1 == 0 and duration >= 0 and duration <= 900,
		"bounded QA settings"
	)
	assert(
		not staggered or (players >= 2 and routePlan == nil),
		"staggered QA needs 2-8 players without a solo route plan"
	)
	assert(routePlan == nil or (#routePlan <= 10000 and duration >= 450), "bounded route plan")
	local templates = game:GetService("ServerStorage").GrabItQA
	assert(
		string.find(templates.server.Source, "GrabItV1.ImprovementsQA", 1, true)
			and string.find(templates.client.Source, "GrabItV1.ImprovementsQA", 1, true)
			and string.find(templates.routes.Source, "GrabItV1.ImprovementsQA", 1, true),
		"QA templates must match the weight/stage revision"
	)
	local server = game:GetService("ServerScriptService")
	local client = game:GetService("StarterPlayer").StarterPlayerScripts
	assert(
		not server:FindFirstChild("GrabItQA_Server")
			and not client:FindFirstChild("GrabItQA_Client"),
		"QA already attached"
	)
	local serverRunner = templates.server:Clone()
	serverRunner.Name = "GrabItQA_Server"
	serverRunner.Parent = server
	local clientRunner = templates.client:Clone()
	clientRunner.Name = "GrabItQA_Client"
	clientRunner.Parent = client
	local storage = game:GetService("ReplicatedStorage")
	local previousClaim = storage:GetAttribute("JestRobloxRunClaimed")
	-- The installed Jest runner explicitly defers to an existing run claim.
	-- Coordinate this test without changing the plugin or enabling LoadString.
	storage:SetAttribute("JestRobloxRunClaimed", "GrabItV1.ImprovementsQA")
	game:SetAttribute("GrabItQAResult", nil)
	task.spawn(function()
		local ok, result = pcall(function()
			local args = {
				marker = "GrabItV1.ImprovementsQA",
				players = players,
				duration = duration,
				collectionOnly = collectionOnly == true,
				loopSmoke = loopSmoke == true,
				routePlan = routePlan,
				staggered = staggered == true,
			}
			local service = game:GetService("StudioTestService")
			return service:ExecuteMultiplayerTestAsync(if staggered then 1 else players, args)
		end)
		serverRunner:Destroy()
		clientRunner:Destroy()
		storage:SetAttribute("JestRobloxRunClaimed", previousClaim)
		game:SetAttribute(
			"GrabItQAResult",
			game:GetService("HttpService"):JSONEncode({
				ok = ok,
				players = players,
				duration = duration,
				collectionOnly = collectionOnly == true,
				result = result,
			})
		)
	end)
	return "Started bounded QA; read the GrabItQAResult project attribute after completion"
end
