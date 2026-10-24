extends RefCounted

# Off and the wind-line classic are free. Colors open on the level track.
const ALL := [
	{"id": "off", "name": "Off", "level": 1, "kind": "off", "color": "ffffff"},
	{"id": "classic", "name": "Classic", "level": 1, "kind": "wind", "color": "e7eef3"},
	{"id": "red", "name": "Red", "level": 11, "kind": "glow", "color": "e23b2f"},
	{"id": "gold", "name": "Gold", "level": 13, "kind": "glow", "color": "e0a106"},
	{"id": "teal", "name": "Teal", "level": 14, "kind": "glow", "color": "1f8a70"},
	{"id": "violet", "name": "Violet", "level": 17, "kind": "glow", "color": "7a4ea3"},
	{"id": "ember", "name": "Ember", "level": 19, "kind": "glow", "color": "ff6a2a"},
	{"id": "sky", "name": "Sky", "level": 22, "kind": "glow", "color": "7eb6e8"},
	{"id": "rose", "name": "Rose", "level": 25, "kind": "glow", "color": "e07090"},
	{"id": "lime", "name": "Lime", "level": 28, "kind": "glow", "color": "9ed14a"},
	{"id": "ice", "name": "Ice", "level": 32, "kind": "glow", "color": "d7f6ff"},
]


static func all() -> Array:
	return ALL


static func get_trail(id: String) -> Dictionary:
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
	var item := get_trail(id)
	return not item.is_empty() and int(item["level"]) <= lv


static func for_slot(slot: int) -> String:
	return "classic" if posmod(slot, 2) == 0 else "off"
