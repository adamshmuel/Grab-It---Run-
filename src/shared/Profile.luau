--!strict
local Profile = {}
export type Snapshot = {
	coins: number,
	tutorial: boolean,
	owned: { [string]: boolean },
	selected: string,
	revision: number,
}
function Profile.capture(p): Snapshot
	return {
		coins = p.coins,
		tutorial = p.tutorial,
		owned = table.clone(p.owned),
		selected = p.selected,
		revision = p.revision,
	}
end
function Profile.confirmPurchase(p, before: Snapshot, confirmed: Snapshot): boolean
	local changes = p.revision - before.revision
	local deposits = p.coins - before.coins
	p.coins = confirmed.coins + deposits
	for id in confirmed.owned do
		p.owned[id] = true
	end
	p.revision = confirmed.revision + changes
	return changes > 0
end
return table.freeze(Profile)
