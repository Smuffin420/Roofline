extends RefCounted

const _PATHS := {
	"bulbous": "res://Assets/Characters/Meshy_AI_Bulbous_Mascot_Rigged_All_Animations.glb",
	"chill": "res://Assets/Characters/Meshy_AI_chill_male_mascot_rig_All_Animations.glb",
	"confident": "res://Assets/Characters/Meshy_AI_confident_female_masc_All_Animations.glb",
	"quirky": "res://Assets/Characters/Meshy_AI_quirky_female_mascot__All_Animations.glb",
	"serious": "res://Assets/Characters/Meshy_AI_serious_male_mascot_r_All_Animations.glb",
}

static var _scenes := {}

# The body picker cycles these characters. Hats are off for now.
const ALL := [
	{"id": "bulbous", "name": "Bulbous", "level": 1},
	{"id": "chill", "name": "Chill", "level": 1},
	{"id": "confident", "name": "Confident", "level": 1},
	{"id": "quirky", "name": "Quirky", "level": 1},
	{"id": "serious", "name": "Serious", "level": 1},
]


static func all() -> Array:
	return ALL


static func get_style(id: String) -> Dictionary:
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
	var item := get_style(id)
	return not item.is_empty() and int(item["level"]) <= lv


static func for_slot(slot: int) -> String:
	return str(ALL[posmod(slot, ALL.size())]["id"])


static func random_id() -> String:
	return str(ALL[randi() % ALL.size()]["id"])


static func request(id: String) -> void:
	var key := id if _PATHS.has(id) else "bulbous"
	var path := str(_PATHS[key])
	if _scenes.has(key) or ResourceLoader.has_cached(path):
		return
	var status := ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS or status == ResourceLoader.THREAD_LOAD_LOADED:
		return
	ResourceLoader.load_threaded_request(path)


static func scene_for(id: String) -> PackedScene:
	var key := id if _PATHS.has(id) else "bulbous"
	if not _scenes.has(key):
		var path := str(_PATHS[key])
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return null
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			_scenes[key] = ResourceLoader.load_threaded_get(path)
		else:
			_scenes[key] = load(path)
	return _scenes[key]
