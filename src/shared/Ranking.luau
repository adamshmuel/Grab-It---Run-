--!strict
local Ranking = {}
local points = { 10, 8, 6, 5, 4, 3, 2, 1 }
function Ranking.points(place: number): number
	return points[place] or 0
end
function Ranking.stage(players, total: number)
	local rows = {}
	local function better(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		if a.finishTime ~= nil and b.finishTime ~= nil then
			return a.finishTime < b.finishTime
		end
		return false
	end
	for id, p in players do
		table.insert(rows, {
			id = id,
			name = p.name or id,
			score = p.stageScore,
			banked = p.bankedCount,
			percent = math.floor(100 * p.bankedCount / total + 0.5),
			finishTime = p.finishTime,
			ranked = p.ranked,
		})
	end
	for _, a in rows do
		if a.ranked then
			local place = 1
			for _, b in rows do
				if b.ranked and better(b, a) then
					place += 1
				end
			end
			a.place = place
		end
	end
	table.sort(rows, function(a, b)
		if a.ranked ~= b.ranked then
			return a.ranked
		end
		if a.ranked and a.place ~= b.place then
			return a.place < b.place
		end
		if a.name ~= b.name then
			return a.name < b.name
		end
		return a.id < b.id
	end)
	return rows
end
function Ranking.match(players)
	local rows = {}
	for id, p in players do
		local place = nil
		if p.eligible then
			place = 1
			for _, other in players do
				if other.eligible and other.matchPoints > p.matchPoints then
					place += 1
				end
			end
		end
		table.insert(rows, {
			id = id,
			name = p.name or id,
			points = p.matchPoints,
			eligible = p.eligible,
			place = place,
		})
	end
	table.sort(rows, function(a, b)
		if a.eligible ~= b.eligible then
			return a.eligible
		end
		if a.points ~= b.points then
			return a.points > b.points
		end
		if a.name ~= b.name then
			return a.name < b.name
		end
		return a.id < b.id
	end)
	return rows
end
return table.freeze(Ranking)
