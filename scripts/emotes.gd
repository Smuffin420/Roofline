extends RefCounted

const ALL := [
	{"id": "wave", "name": "Wave", "level": 1},
	{"id": "cheer", "name": "Cheer", "level": 1},
	{"id": "spin", "name": "Spin", "level": 3},
	{"id": "bow", "name": "Bow", "level": 5},
	{"id": "flex", "name": "Flex", "level": 8},
	{"id": "dance", "name": "Dance", "level": 12},
	{"id": "sit", "name": "Sit", "level": 18},
]


static func all() -> Array:
	return ALL


static func is_open(id: String, lv: int) -> bool:
	for item in ALL:
		if str(item["id"]) == id:
			return int(item["level"]) <= lv
	return false


static func index_of(id: String) -> int:
	for i in ALL.size():
		if str(ALL[i]["id"]) == id:
			return i + 1
	return 0


static func id_for(index: int) -> String:
	var slot := index - 1
	if slot < 0 or slot >= ALL.size():
		return ""
	return str(ALL[slot]["id"])
