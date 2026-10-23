--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").GrabIt.Shared
	local source = shared:FindFirstChild("NetworkState")
	assert(source, "RED: network state codec must exist")
	local fresh = source:Clone()
	local Wire = require(fresh)
	fresh:Destroy()
	local original = { [1] = true, [4] = true, [6] = true, [8] = true, [10] = true }
	local packed = Wire.packCollected(original)
	local count = 0
	for key, value in packed do
		assert(type(key) == "string" and value == true, "wire uses only string keys")
		count += 1
	end
	assert(count == 5 and packed["10"], "sparse collected IDs survive packing")
	local decoded = Wire.unpackCollected(packed)
	for id in original do
		assert(decoded[id], "all collected IDs restored")
	end
	assert(not decoded[2], "uncollected ID stays available")
	local json = game:GetService("HttpService"):JSONEncode(packed)
	local restored = Wire.unpackCollected(game:GetService("HttpService"):JSONDecode(json))
	assert(restored[4] and restored[10], "JSON signature roundtrip retains sparse IDs")
	return 4
end
