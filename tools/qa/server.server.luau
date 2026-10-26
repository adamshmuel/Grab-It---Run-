--!strict
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end
local service = game:GetService("StudioTestService")
local args = service:GetTestArgs()
for _ = 1, 50 do
	if args ~= nil then
		break
	end
	task.wait(0.1)
	args = service:GetTestArgs()
end
if type(args) ~= "table" or args.marker ~= "GrabItV1.ImprovementsQA" then
	return
end
local Players = game:GetService("Players")
local suites = {}
local clientLayouts = {
	["ScoresLayout.spec"] = true,
	["StylesLayout.spec"] = true,
	["ResultsLayout.spec"] = true,
	["ResultsLossNotice.spec"] = true,
	["TouchButtonLayout.spec"] = true,
}
for _, entry in game:GetService("ServerStorage").GrabItTests:GetChildren() do
	if entry:IsA("ModuleScript") and not clientLayouts[entry.Name] then
		local ok, result = pcall(function()
			return require(entry)()
		end)
		suites[entry.Name] = { passed = ok, result = tostring(result) }
		if not ok then
			service:EndTest({ passed = false, error = "failing suite", suites = suites })
			return
		end
	end
end
local channel = Instance.new("RemoteEvent")
channel.Name = "GrabItQAChannel"
channel:SetAttribute("Duration", args.duration)
channel:SetAttribute("CollectionOnly", args.collectionOnly == true)
channel:SetAttribute("MeasureFrames", args.duration < 600)
channel:SetAttribute("LoopSmoke", args.loopSmoke == true)
channel:SetAttribute("Marker", args.marker)
channel:SetAttribute("RoutePlan", args.routePlan)
channel:SetAttribute("Staggered", args.staggered == true)
channel:SetAttribute("ExpectedPlayers", args.players)
if args.routePlan then
	local routes = game:GetService("ServerStorage").GrabItQA.routes:Clone()
	routes.Parent = channel
end
channel.Parent = game:GetService("ReplicatedStorage")
local results = {}
local finished = false
local joined = 0
local checkingLeave = false
local addedPlayers = false
local leaveChecks = {}
local function finish(value)
	if finished then
		return
	end
	finished = true
	channel:Destroy()
	service:EndTest(value)
end
local connection = channel.OnServerEvent:Connect(function(player, report)
	if args.staggered and type(report) == "table" and report.stage == "started-active" then
		if not addedPlayers then
			addedPlayers = true
			channel:SetAttribute("OriginalPlayer", player.UserId)
			channel:SetAttribute("OriginalRound", report.round)
			channel:SetAttribute("OriginalRemaining", report.remaining)
			task.defer(function()
				local ok, err = pcall(function()
					service:AddPlayers(args.players - 1)
				end)
				if not ok then
					finish({ passed = false, error = tostring(err) })
				end
			end)
		end
		return
	end
	if checkingLeave and type(report) == "table" and report.stage == "after-leave" then
		leaveChecks[tostring(player.UserId)] = report
		local count = 0
		local passed = true
		for _, entry in leaveChecks do
			count += 1
			passed = passed and entry.passed == true
		end
		if count == args.players - 1 then
			finish({
				passed = passed,
				joined = joined,
				reports = results,
				suites = suites,
				leaveChecks = leaveChecks,
			})
		end
		return
	end
	if results[tostring(player.UserId)] or type(report) ~= "table" then
		return
	end
	results[tostring(player.UserId)] = report
	channel:SetAttribute(
		"Report_" .. player.UserId,
		game:GetService("HttpService"):JSONEncode(report)
	)
	local count = 0
	local passed = true
	for _, entry in results do
		count += 1
		passed = passed and entry.passed == true
	end
	if count >= args.players then
		if not passed or args.collectionOnly or args.players == 1 then
			finish({ passed = passed, joined = joined, reports = results, suites = suites })
			return
		end
		checkingLeave = true
		task.spawn(function()
			local leaving = Players:GetPlayers()[#Players:GetPlayers()]
			leaving:Kick("GrabIt automated QA disconnect")
			local deadline = os.clock() + 8
			repeat
				task.wait(0.1)
			until #Players:GetPlayers() == args.players - 1 or os.clock() >= deadline
			if #Players:GetPlayers() ~= args.players - 1 then
				finish({ passed = false, error = "test player did not leave", reports = results })
				return
			end
			channel:FireAllClients("verify-after-leave")
		end)
	end
end)
local joinConnection = Players.PlayerAdded:Connect(function()
	joined += 1
end)
joined = #Players:GetPlayers()
task.delay(math.max(args.duration, if args.collectionOnly then 0 else 220) + 110, function()
	if not finished then
		finish({ passed = false, error = "QA watchdog timeout", joined = joined, reports = results })
	end
	connection:Disconnect()
	joinConnection:Disconnect()
end)
