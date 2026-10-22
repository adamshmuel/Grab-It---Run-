--!strict
local tests = game:GetService("ServerStorage").GrabItTests
local total, failed = 0, 0
for _, test in tests:GetChildren() do
	if test:IsA("ModuleScript") then
		local ok, result = pcall(function()
			return require(test)()
		end)
		if ok then
			total += result
		else
			failed += 1
			warn(test.Name .. ": " .. tostring(result))
		end
	end
end
assert(failed == 0, tostring(failed) .. " failing suites")
print("GRABIT_TESTS_PASSED", total)
