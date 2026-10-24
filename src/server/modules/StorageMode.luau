--!strict
local Mode = {}
export type Selection = { memory: boolean, name: string?, keyPrefix: string }

function Mode.select(isStudio: boolean, runId: any): Selection
	if not isStudio then
		return { memory = false, name = "GrabItV1_PlayerData", keyPrefix = "" }
	end
	if type(runId) == "string" and #runId > 0 and #runId <= 20 and runId:match("^[%w_%-]+$") then
		return {
			memory = false,
			name = "GrabItV1_QA_Verification",
			keyPrefix = "QA_" .. runId .. "_",
		}
	end
	return { memory = true, keyPrefix = "" }
end

return Mode
