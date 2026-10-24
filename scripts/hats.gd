extends RefCounted

# Three hats from the start. The rest open with the level track.
const ALL := [
	{"id": "cap", "name": "Cap", "level": 1},
	{"id": "beanie", "name": "Beanie", "level": 1},
	{"id": "band", "name": "Band", "level": 1},
	{"id": "bucket", "name": "Bucket", "level": 2},
	{"id": "beret", "name": "Beret", "level": 3},
	{"id": "hardhat", "name": "Hard hat", "level": 5},
	{"id": "visor", "name": "Visor", "level": 7},
	{"id": "boater", "name": "Boater", "level": 10},
	{"id": "hood", "name": "Hood", "level": 12},
	{"id": "tophat", "name": "Top hat", "level": 15},
	{"id": "crown", "name": "Crown", "level": 20},
]


static func all() -> Array:
	return ALL


static func get_hat(id: String) -> Dictionary:
	for item in ALL:
		if str(item["id"]) == id:
			return item
	return {}


static func index_of(id: String) -> int:
	for i in ALL.size():
		if str(ALL[i]["id"]) == id:
			return i
	return 0


static func is_open(id: String, lv: int) -> bool:
	var item := get_hat(id)
	return not item.is_empty() and int(item["level"]) <= lv


static func next_locked(lv: int) -> Dictionary:
	for item in ALL:
		if int(item["level"]) > lv:
			return item
	return {}


static func starter(slot: int) -> String:
	var open: Array[String] = ["cap", "beanie", "band"]
	return open[posmod(slot, open.size())]
