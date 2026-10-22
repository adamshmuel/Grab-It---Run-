--!strict
return function()
	local probe = require(script.Parent.Probe)
	assert(probe.revision == probe.expectedRevision, "SYNC_SMOKE: expected revision 2")
	return "SYNC_SMOKE: passed"
end
