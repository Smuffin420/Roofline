extends Node3D

const Catalog := preload("res://scripts/catalog.gd")
const PATH_HALF := 2.45
const RISK_HALF := 0.9
const _BOOSTON_RISE := 12.0
const _BOOSTON_INNER := 11.5
const _BOOSTON_GAP := 2.4
const _BOOSTON_AHEAD := 160.0
const _BOOSTON_BEHIND := 90.0
const _BOOSTON_FILES: Array[String] = [
	"res://Assets/Buildings/Meshy_AI_booston_01_dome_hall__1014012925_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_02_brownstone_1014012816_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_03_market_hal_1014012939_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_04_steeple_to_1014012754_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_05_wharf_ware_1014012906_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_06_clock_towe_1014012835_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_07_monument_o_1014013002_image-to-3d-texture.glb",
	"res://Assets/Buildings/Meshy_AI_booston_08_belt_mill__1014012844_image-to-3d-texture.glb",
]
const _DRONE_PATH := "res://Assets/background/Meshy_AI_broadcast_drone_v2_3d_1014081153_image-to-3d-texture.glb"
const _DRONE_SCRIPT := preload("res://scripts/drone.gd")
const _BOOST_PATH := "res://Assets/background/Meshy_AI_roofline_speed_boost__1014214538_image-to-3d-texture.glb"
const _JUMP_PATH := "res://Assets/background/Meshy_AI_roofline_jump_pad_3d_1014215118_image-to-3d-texture.glb"
const _FAN_PATH := "res://Assets/background/Meshy_AI_roofline_updraft_fan__1014215835_image-to-3d-texture.glb"
const _SCREEN_PATH := "res://Assets/background/Meshy_AI_roofline_floating_mon_1024035719_image-to-3d-texture.glb"
const _SCREEN_SCRIPT := preload("res://scripts/broadcast_screen.gd")
const _GANTRY_PATH := "res://Assets/Props/Meshy_AI_roofline_finish_gantr_1024041329_image-to-3d-texture.glb"
const _POST_PATH := "res://Assets/Props/Meshy_AI_roofline_checkpoint_p_1024042954_image-to-3d-texture.glb"
const _KIT_DECK := "res://Assets/Props/Meshy_AI_roofline_deck_tile_3d_1024085057_image-to-3d-texture.glb"
const _KIT_EDGE := "res://Assets/Props/Meshy_AI_roofline_edge_trim_3d_1024085046_image-to-3d-texture.glb"
const _KIT_COLUMN := "res://Assets/Props/Meshy_AI_roofline_support_colu_1024085025_image-to-3d-texture.glb"
const _KIT_CHUNK := "res://Assets/Props/Meshy_AI_roofline_broken_chunk_1024085107_image-to-3d-texture.glb"
const _KIT_WALL := "res://Assets/Props/Meshy_AI_roofline_wall_run_pan_1024085035_image-to-3d-texture.glb"
const _KIT_DUCT := "res://Assets/Props/Meshy_AI_roofline_slide_duct_3_1024085211_image-to-3d-texture.glb"
const _KIT_BELT := "res://Assets/Props/Meshy_AI_roofline_conveyor_til_1024085254_image-to-3d-texture.glb"
const _KIT_PLANK := "res://Assets/Props/Meshy_AI_roofline_narrow_plank_1024085245_image-to-3d-texture.glb"
const _KIT_HURDLE := "res://Assets/Props/Meshy_AI_roofline_low_hurdle_3_1024085322_image-to-3d-texture.glb"
const _KIT_BAR := "res://Assets/Props/Meshy_AI_roofline_swinging_bar_1024085219_image-to-3d-texture.glb"
const _KIT_POLE := "res://Assets/Props/Meshy_AI_roofline_zip_pole_3d_1024085230_image-to-3d-texture.glb"
const _KIT_BAG := "res://Assets/Props/Meshy_AI_roofline_bumper_bag_3_1024085446_image-to-3d-texture.glb"
const _KIT_RAIL := "res://Assets/Props/Meshy_AI_roofline_bumper_rail__1024085458_image-to-3d-texture.glb"
const _KIT_BUTTON := "res://Assets/Props/Meshy_AI_roofline_floor_button_1024085435_image-to-3d-texture.glb"
const _KIT_GATE := "res://Assets/Props/Meshy_AI_roofline_lowering_gat_1024085419_image-to-3d-texture.glb"
const _KIT_RING := "res://Assets/Props/Meshy_AI_roofline_jump_ring_3d_1024085409_image-to-3d-texture.glb"
const _KIT_TOWER := "res://Assets/Props/Meshy_AI_roofline_water_tower__1024085822_image-to-3d-texture.glb"
const _KIT_LINE := "res://Assets/Props/Meshy_AI_roofline_clothesline__1024090001_image-to-3d-texture.glb"
const _KIT_CAP := "res://Assets/Props/Meshy_AI_roofline_roof_cap_3d_1024085922_image-to-3d-texture.glb"
const _KIT_PATHS: Array[String] = [
	_KIT_DECK, _KIT_EDGE, _KIT_COLUMN, _KIT_CHUNK, _KIT_WALL, _KIT_DUCT, _KIT_BELT, _KIT_PLANK,
	_KIT_HURDLE, _KIT_BAR, _KIT_POLE, _KIT_BAG, _KIT_RAIL, _KIT_BUTTON, _KIT_GATE, _KIT_RING,
	_KIT_TOWER, _KIT_LINE, _KIT_CAP,
]
const _DECK_POS := Vector3(-0.948727, -0.284912, -0.952206)
const _DECK_SIZE := Vector3(1.89659, 0.56868, 1.903265)
const _EDGE_POS := Vector3(-0.951875, -0.252891, -0.167269)
const _EDGE_SIZE := Vector3(1.902693, 0.504671, 0.333489)
const _COLUMN_POS := Vector3(-0.666117, -0.951924, -0.663349)
const _COLUMN_SIZE := Vector3(1.33122, 1.902918, 1.325792)
const _CHUNK_POS := Vector3(-0.95188, -0.23294, -0.557002)
const _CHUNK_SIZE := Vector3(1.90278, 0.464962, 1.111795)
const _WALL_POS := Vector3(-0.80087, -0.951942, -0.128697)
const _WALL_SIZE := Vector3(1.605338, 1.902889, 0.256356)
const _DUCT_POS := Vector3(-0.943882, -0.457628, -0.739602)
const _DUCT_SIZE := Vector3(1.886765, 0.914511, 1.477964)
const _BELT_POS := Vector3(-0.951879, -0.124766, -0.861456)
const _BELT_SIZE := Vector3(1.902842, 0.256526, 1.720757)
const _PLANK_POS := Vector3(-0.95206, -0.132546, -0.220807)
const _PLANK_SIZE := Vector3(1.903092, 0.265019, 0.441329)
const _HURDLE_POS := Vector3(-0.951909, -0.366589, -0.330205)
const _HURDLE_SIZE := Vector3(1.902939, 0.732093, 0.658463)
const _BAR_POS := Vector3(-0.952046, -0.829589, -0.249443)
const _BAR_SIZE := Vector3(1.903074, 1.658023, 0.498027)
const _POLE_POS := Vector3(-0.316186, -0.952011, -0.597449)
const _POLE_SIZE := Vector3(0.632113, 1.902999, 1.192678)
const _BAG_POS := Vector3(-0.795983, -0.951929, -0.793894)
const _BAG_SIZE := Vector3(1.59165, 1.90283, 1.586954)
const _RAIL_POS := Vector3(-0.951811, -0.394906, -0.289388)
const _RAIL_SIZE := Vector3(1.902904, 0.789027, 0.57822)
const _BUTTON_POS := Vector3(-0.951826, -0.256583, -0.913626)
const _BUTTON_SIZE := Vector3(1.902571, 0.524589, 1.825548)
const _GATE_POS := Vector3(-0.951847, -0.359848, -0.201971)
const _GATE_SIZE := Vector3(1.902797, 0.719363, 0.404148)
const _RING_POS := Vector3(-0.952046, -0.694293, -0.145225)
const _RING_SIZE := Vector3(1.903121, 1.387543, 0.28968)
const _TOWER_POS := Vector3(-0.443929, -0.952325, -0.443705)
const _TOWER_SIZE := Vector3(0.885932, 1.903094, 0.885311)
const _LINE_POS := Vector3(-0.952192, -0.393703, -0.243948)
const _LINE_SIZE := Vector3(1.903371, 0.785801, 0.472593)
const _CAP_POS := Vector3(-0.651426, -0.952178, -0.65136)
const _CAP_SIZE := Vector3(1.301254, 1.903125, 1.301486)
const _GANTRY_SCALE := 4.2
const _GANTRY_BOTTOM := -0.766888
const _GANTRY_FRONT := 0.226751
const _POST_SCALE := 1.75
const _POST_BOTTOM := -0.95201
const _POST_HALF := 0.359228
const _SPRING_SHADER := preload("res://shaders/spring_pad.gdshader")
const _FAN_SHADER := preload("res://shaders/fan_blades.gdshader")
const _BOOST_SIZE := Vector3(1.903, 0.087, 1.376)
const _JUMP_SIZE := Vector3(1.902, 1.037, 1.902)
const _FAN_SIZE := Vector3(1.896, 1.227, 1.903)

var _packed := {}
var _visual_later: Array = []
var map_id := "annex"
var map_name := "Booston"
var sky := Color("dcdcdc")
var travel := 0.0
var checkpoint_count := 0

var _rng := RandomNumberGenerator.new()
var _floor_y := 0.0
var _solid_end := -10.0
var _min_floor := 0.0
var _cp := 0
var _since_cp := 0.0
var _last_cp_z := 99999.0
var _beacon_at: Array[Vector3] = []
var _beacon_flip: Array[bool] = []
var _finish_z := 0.0
var _finish_y := 0.0
var _concrete := Color("c4c4c4")
var _dark := Color("a3a3a3")
var _metal := Color("5e5e5e")
var _hazard := Color("1a1a1a")
var _accent := Color("3a3a3a")
var _sea := Color("3a3c40")
var _road := Color("2a2c2e")
var _lane := Color("c8c6be")
var _cloud := Color("8a8c90")
var _cloud_hi := Color("b4b6ba")
var _win := Color("2a2c30")
var _abyss_dark := false
var _deck_z: PackedFloat32Array = PackedFloat32Array()
var _deck_y: PackedFloat32Array = PackedFloat32Array()
var _drops := 0
var _plunges := 0
var _canyons := 0
var _narrow := false
var _bite_side := 1.0
var _forks := 0
var _fork_side := 1.0
var _slabs: Array[Dictionary] = []
var _deck_shader: Shader
var _intro: Array = []
var _lane_half := 2.45
var _gap_scale := 1.0
var _hops := 3
var _hops_base := 3
var _landing_len := 11.0
var _landing_base := 11.0
var _teeth_lo_base := 3
var _teeth_hi_base := 5
var _run_lo_base := 12.0
var _run_hi_base := 18.0
var _hop_base := 8.6
var _slide_lo_base := 12.0
var _slide_hi_base := 16.0
var _act := 0
var _drop_cap := 6
var _plunge_cap := 4
var _floor_cut := -22.0
var _plunge_cut := -28.0
var _climb := 2.55
var _run_lo := 16.0
var _run_hi := 26.0
var _teeth_lo := 4
var _teeth_hi := 6
var _cp_span := 78.0
var _cp_min := 12.0
var _hop := 8.6
var _slide_lo := 12.0
var _slide_hi := 16.0
var _tooth_half := 1.25
var _hue := 0.58
var _sat := 0.16
var _kinds := {}
var _preview := false
var _booston_packed: Array[PackedScene] = []
var _booston_bounds: Array[AABB] = []
var _booston_slots: Array[Dictionary] = []
var _booston_live: Dictionary = {}
var _booston_serial := 0
var _booston_load_i := 0
var _booston_wait := ""
var _booston_file_prog := 0.0
var _build_sync := false
var _build_phase := 3
var _build_target := 0.0
var _build_frac := 1.0
var _build_acts: Array = []
var _build_act := 0
var _build_beat := 0
var _build_beat_n := 0
var _ahead := ""
var _city_y := 0.0
var _city_z := 26.0
var _city_i := 0
var _city_cap := 0
var _city_on := false
var _city_span := 1.0
var _win_chunks: Dictionary = {}


func build(id: String, preview_meters: int = -1) -> void:
	_build_sync = true
	begin(id, preview_meters)
	while not step():
		pass
	_build_sync = false


func begin(id: String, preview_meters: int = -1) -> void:
	add_to_group("course")
	var map := Catalog.get_map(id)
	map_id = str(map["id"])
	map_name = str(map["name"])
	_warm_heavy()
	_preview = preview_meters > 0
	_concrete = Color(str(map["concrete"]))
	_dark = Color(str(map["dark"]))
	_metal = Color(str(map["metal"]))
	_accent = Color(str(map["accent"]))
	_hazard = Color(str(map["hazard"]))
	_apply_abyss(str(map.get("abyss", "bright")), Color(str(map["sky"])))
	_apply_style(map_id)
	_rng.seed = int(map["seed"])
	var target := preview_meters if preview_meters > 0 else Catalog.meters_for(map)
	if preview_meters <= 0:
		var forced := OS.get_environment("ROOFLINE_METERS")
		if forced.is_valid_int():
			target = int(forced)
	_build_target = float(target)
	_floor_y = 0.0
	_narrow = false
	_slab(-8.0, 8.0, -10.0, 14.0, 0.0, _concrete)
	_solid_end = -10.0
	_deck_z.append(14.0)
	_deck_y.append(0.0)
	_note_deck()
	if not _preview:
		_hint(map_name.to_upper(), Vector3(0, 3.4, 0.5))
	_funnel()
	_note_deck()
	_narrow = true
	_build_acts = _journey(map_id)
	for i in _intro.size():
		_note_ahead(_intro, i, _build_acts)
		_segment(str(_intro[i]))
		_note_deck()
	_build_act = 0
	_build_beat = 0
	_build_beat_n = 0
	_build_phase = 0
	_build_frac = 0.06


func step() -> bool:
	_flush_props(4)
	if _build_phase >= 3:
		return _props_ready()
	if _build_phase == 0:
		if not _journey_step():
			_build_phase = 1
		_build_frac = 0.06 + 0.5 * clampf(travel / maxf(_build_target, 1.0), 0.0, 1.0)
		return false
	if _build_phase == 1:
		_close_course()
		_build_phase = 2
		_build_frac = 0.6
		return false
	if map_id == "annex" and not _booston_ready():
		_booston_load_one()
		_build_frac = 0.6 + 0.22 * _booston_load_frac()
		return false
	var batch := 4 if map_id == "annex" else 2
	var placed := false
	for _n in batch:
		if not _city_more():
			break
		placed = true
	if placed:
		_build_frac = 0.82 + 0.18 * _city_frac()
		return false
	_flush_windows()
	checkpoint_count = _cp
	_build_phase = 3
	_build_frac = 1.0
	if OS.get_environment("ROOFLINE_BOT") == "1":
		print("COURSE ", map_id, " travel=", snappedf(travel, 1.0), " cps=", _cp, " ", _kind_line())
	return _props_ready()


func fraction() -> float:
	return _build_frac


func _warm_heavy() -> void:
	var paths: Array[String] = [_DRONE_PATH, _BOOST_PATH, _JUMP_PATH, _FAN_PATH, _SCREEN_PATH, _GANTRY_PATH, _POST_PATH]
	if map_id == "annex":
		paths.append_array(_BOOSTON_FILES)
		paths.append_array(_KIT_PATHS)
	for path in paths:
		_request_scene(path)


func _request_scene(path: String) -> void:
	if _packed.has(path) or ResourceLoader.has_cached(path):
		return
	var status := ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS or status == ResourceLoader.THREAD_LOAD_LOADED:
		return
	ResourceLoader.load_threaded_request(path)


func _packed_scene(path: String) -> PackedScene:
	if _packed.has(path):
		return _packed[path]
	if ResourceLoader.has_cached(path):
		var cached := load(path) as PackedScene
		_packed[path] = cached
		return cached
	var status := ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var done := ResourceLoader.load_threaded_get(path) as PackedScene
		_packed[path] = done
		return done
	if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		ResourceLoader.load_threaded_request(path)
	return null


func _with_scene(path: String, use: Callable) -> void:
	var packed := _packed_scene(path)
	if packed != null:
		use.call(packed)
		return
	_visual_later.append(func() -> bool:
		var ready := _packed_scene(path)
		if ready == null:
			return false
		use.call(ready)
		return true
	)


func _flush_props(limit: int) -> bool:
	var pending: Array = []
	var ran := 0
	for job in _visual_later:
		if ran >= limit:
			pending.append(job)
			continue
		if bool(job.call()):
			ran += 1
		else:
			pending.append(job)
	_visual_later = pending
	return pending.is_empty()


func _props_ready() -> bool:
	if not _flush_props(8):
		return false
	var paths: Array[String] = [_DRONE_PATH, _BOOST_PATH, _JUMP_PATH, _FAN_PATH, _SCREEN_PATH, _GANTRY_PATH, _POST_PATH]
	if map_id == "annex":
		paths.append_array(_KIT_PATHS)
	for path in paths:
		if _packed_scene(path) == null:
			return false
	return true


func _journey_step() -> bool:
	if _build_act >= _build_acts.size():
		return false
	var beats: Array = _build_acts[_build_act]
	if _build_beat >= beats.size():
		_build_act += 1
		_build_beat = 0
		return _journey_step()
	var finale := _build_act == _build_acts.size() - 1 and _build_beat >= beats.size() - 2
	if travel >= _build_target and not finale:
		_build_act = _build_acts.size()
		return false
	_act = _build_act
	_dress_beat(_build_beat_n)
	_build_beat_n += 1
	var later: Array = []
	if _build_act + 1 < _build_acts.size():
		later = _build_acts.slice(_build_act + 1)
	_note_ahead(beats, _build_beat, later)
	_segment(str(beats[_build_beat]))
	_note_deck()
	_build_beat += 1
	return true


func _close_course() -> void:
	_narrow = false
	_ahead = ""
	_straight(20.0)
	_note_deck()
	if not _preview:
		_outer_walls()
	_finish_line()
	_place_beacons()
	_place_screens()
	_place_drones()
	_character()
	_skyline()
	_void_floor()


func _apply_abyss(kind: String, catalog_sky: Color) -> void:
	_abyss_dark = kind == "dark"
	sky = catalog_sky
	var night := catalog_sky.get_luminance() < 0.42
	if night:
		_sea = catalog_sky.darkened(0.62)
		_road = catalog_sky.darkened(0.5)
		_lane = Color(0.92, 0.72, 0.38)
		_cloud = catalog_sky.darkened(0.35)
		_cloud_hi = catalog_sky.lightened(0.12)
		_win = Color(1.0, 0.86, 0.55)
	else:
		_sea = catalog_sky.darkened(0.38)
		_road = catalog_sky.darkened(0.48)
		_lane = Color(0.95, 0.84, 0.46)
		_cloud = catalog_sky.darkened(0.22)
		_cloud_hi = catalog_sky.lightened(0.12)
		_win = Color(0.16, 0.18, 0.22)


func _apply_style(id: String) -> void:
	var style := _style(id)
	_intro = style["intro"]
	_lane_half = float(style["lane"])
	_gap_scale = float(style["gap"])
	_hops = int(style["hops"])
	_drop_cap = int(style["drop_cap"])
	_plunge_cap = int(style["plunge_cap"])
	_floor_cut = float(style["floor_cut"])
	_plunge_cut = float(style["plunge_cut"])
	_climb = float(style["climb"])
	_run_lo = float(style["run_lo"])
	_run_hi = float(style["run_hi"])
	_teeth_lo = int(style["teeth_lo"])
	_teeth_hi = int(style["teeth_hi"])
	_cp_span = float(style["cp"])
	if style.has("cp_min"):
		_cp_min = float(style["cp_min"])
	elif id == "highline":
		_cp_min = 28.0
	elif id == "spire":
		_cp_min = 24.0
	else:
		_cp_min = 12.0
	_landing_len = float(style.get("landing", 11.0))
	_hop = float(style.get("hop", 8.6))
	_slide_lo = float(style.get("slide_lo", 12.0))
	_slide_hi = float(style.get("slide_hi", 16.0))
	_tooth_half = float(style.get("tooth", 1.25))
	_hue = float(style["hue"])
	_sat = float(style["sat"])
	_hops_base = _hops
	_landing_base = _landing_len
	_teeth_lo_base = _teeth_lo
	_teeth_hi_base = _teeth_hi
	_run_lo_base = _run_lo
	_run_hi_base = _run_hi
	_hop_base = _hop
	_slide_lo_base = _slide_lo
	_slide_hi_base = _slide_hi


func _style(id: String) -> Dictionary:
	match id:
		"kiln":
			return _look(["vent", "wall", "teeth"], 2.35, 1.0, 3, 6, 1, -22.0, -28.0, 2.9, 12.0, 18.0, 5, 7, 72.0, 0.07, 0.34)
		"culvert":
			return _look(["jet", "slide", "teeth"], 2.3, 0.9, 3, 1, 0, -12.0, -16.0, 2.2, 14.0, 22.0, 6, 8, 74.0, 0.38, 0.22)
		"highline":
			return _look(["gust", "mill", "spring"], 2.25, 1.22, 3, 8, 6, -40.0, -46.0, 3.3, 12.0, 18.0, 3, 4, 84.0, 0.58, 0.28)
		"switchback":
			return _look(["saw", "bounce", "wall"], 2.4, 1.0, 4, 1, 0, -14.0, -18.0, 2.4, 12.0, 18.0, 3, 4, 76.0, 0.04, 0.3)
		"overpass":
			return _look(["truck", "mover", "shutter"], 2.9, 1.05, 3, 2, 1, -16.0, -20.0, 2.4, 22.0, 34.0, 3, 4, 110.0, 0.6, 0.08)
		"gallery":
			return _look(["crumble", "slide", "gap"], 2.25, 0.95, 3, 4, 1, -20.0, -24.0, 2.3, 10.0, 16.0, 4, 6, 58.0, 0.09, 0.2)
		"spire":
			return _look(["gust", "fan", "chute"], 2.3, 1.05, 4, 2, 2, -18.0, -24.0, 3.15, 12.0, 18.0, 3, 4, 80.0, 0.62, 0.18)
		"canal":
			return _look(["current", "chute"], 2.55, 1.0, 3, 1, 0, -10.0, -14.0, 2.2, 16.0, 24.0, 3, 5, 78.0, 0.48, 0.32)
		"market":
			return _look(["sign", "hammer", "fan"], 2.4, 1.0, 3, 2, 1, -16.0, -20.0, 2.5, 12.0, 20.0, 3, 5, 72.0, 0.1, 0.12)
		"needle":
			var needle := _cruel(["teeth", "gap"], 2.18, 1.16, 3, 2, 0, -18.0, -22.0, 2.4, 10.0, 14.0, 8, 11, 90.0, 0.58, 0.2, 46.0, 8.0, 8.6, 12.0, 16.0)
			needle["tooth"] = 1.02
			return needle
		"razor":
			return _cruel(["saw", "bounce"], 2.3, 1.05, 5, 1, 0, -16.0, -20.0, 2.4, 10.0, 14.0, 3, 4, 80.0, 0.02, 0.35, 40.0, 8.0, 9.3, 12.0, 16.0)
		"well":
			return _cruel(["crumble", "plunge", "gap"], 2.2, 1.22, 3, 8, 7, -48.0, -54.0, 3.2, 10.0, 16.0, 3, 4, 90.0, 0.55, 0.22, 44.0, 8.0, 8.6, 12.0, 16.0)
		"flue":
			return _cruel(["vent", "slide", "teeth"], 2.15, 1.05, 3, 1, 0, -12.0, -16.0, 2.2, 12.0, 18.0, 6, 9, 80.0, 0.08, 0.18, 42.0, 8.5, 8.6, 20.0, 26.0)
		"gale":
			return _cruel(["mill", "gust", "fan"], 2.25, 1.08, 4, 2, 1, -20.0, -26.0, 3.2, 10.0, 16.0, 3, 4, 86.0, 0.52, 0.28, 40.0, 8.0, 9.0, 12.0, 16.0)
		"glaze":
			return _cruel(["current", "ice", "bounce"], 2.2, 1.08, 4, 1, 0, -14.0, -18.0, 2.3, 12.0, 18.0, 3, 5, 78.0, 0.48, 0.38, 38.0, 8.0, 9.0, 12.0, 16.0)
		"clockwork":
			return _cruel(["truck", "hammer", "mover"], 2.25, 1.1, 3, 2, 1, -18.0, -22.0, 2.5, 12.0, 18.0, 3, 5, 70.0, 0.12, 0.16, 36.0, 8.5, 8.6, 12.0, 16.0)
		"spireline":
			return _cruel(["fan", "rise", "chute"], 2.22, 1.1, 5, 2, 2, -24.0, -30.0, 3.45, 10.0, 16.0, 3, 4, 88.0, 0.62, 0.2, 48.0, 8.0, 9.2, 12.0, 16.0)
		"span":
			return _cruel(["gust", "gap"], 2.12, 1.2, 3, 2, 1, -30.0, -36.0, 2.6, 8.0, 12.0, 3, 4, 100.0, 0.58, 0.12, 52.0, 7.6, 8.6, 12.0, 16.0)
		"blackout":
			var blackout := _cruel(["sign", "bounce", "fan"], 2.2, 1.14, 5, 3, 2, -28.0, -34.0, 3.1, 10.0, 16.0, 7, 10, 84.0, 0.08, 0.14, 42.0, 8.0, 9.1, 16.0, 22.0)
			blackout["tooth"] = 1.1
			return blackout
		"annex":
			return _look(["straight", "bumper", "gap"], 2.45, 0.92, 3, 2, 0, -16.0, -20.0, 2.4, 14.0, 22.0, 3, 5, 76.0, 0.08, 0.1)
		_:
			return _look(["belt", "boost", "spring"], 2.45, 0.92, 3, 2, 0, -16.0, -20.0, 2.4, 14.0, 22.0, 3, 5, 76.0, 0.08, 0.1)


func _look(intro: Array, lane: float, gap: float, hops: int, drop_cap: int, plunge_cap: int, floor_cut: float, plunge_cut: float, climb: float, run_lo: float, run_hi: float, teeth_lo: int, teeth_hi: int, cp: float, hue: float, sat: float) -> Dictionary:
	return {
		"intro": intro,
		"lane": lane,
		"gap": gap,
		"hops": hops,
		"drop_cap": drop_cap,
		"plunge_cap": plunge_cap,
		"floor_cut": floor_cut,
		"plunge_cut": plunge_cut,
		"climb": climb,
		"run_lo": run_lo,
		"run_hi": run_hi,
		"teeth_lo": teeth_lo,
		"teeth_hi": teeth_hi,
		"cp": cp,
		"hue": hue,
		"sat": sat,
	}


func _cruel(intro: Array, lane: float, gap: float, hops: int, drop_cap: int, plunge_cap: int, floor_cut: float, plunge_cut: float, climb: float, run_lo: float, run_hi: float, teeth_lo: int, teeth_hi: int, cp: float, hue: float, sat: float, cp_min: float, landing: float, hop: float, slide_lo: float, slide_hi: float) -> Dictionary:
	var style := _look(intro, lane, gap, hops, drop_cap, plunge_cap, floor_cut, plunge_cut, climb, run_lo, run_hi, teeth_lo, teeth_hi, cp, hue, sat)
	style["cp_min"] = cp_min
	style["landing"] = landing
	style["hop"] = hop
	style["slide_lo"] = slide_lo
	style["slide_hi"] = slide_hi
	return style


func _kind_line() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for key in _kinds.keys():
		parts.append("%s=%s" % [str(key), str(_kinds[key])])
	return " ".join(parts)


func _lay_journey(target: float) -> void:
	var acts := _journey(map_id)
	var beat_n := 0
	for act_i in acts.size():
		_act = act_i
		var beats: Array = acts[act_i]
		for beat_i in beats.size():
			var finale := act_i == acts.size() - 1 and beat_i >= beats.size() - 2
			if travel >= target and not finale:
				return
			_dress_beat(beat_n)
			beat_n += 1
			var later: Array = []
			if act_i + 1 < acts.size():
				later = acts.slice(act_i + 1)
			_note_ahead(beats, beat_i, later)
			_segment(str(beats[beat_i]))
			_note_deck()


func _dress_beat(index: int) -> void:
	var wave := index % 5
	var act := _act
	_hops = clampi(_hops_base + act - 1 + (1 if wave >= 3 else 0), 2, 6)
	_landing_len = clampf(_landing_base + (4.0 if act == 0 else 0.0) - (2.5 if act >= 2 else 0.0) + float(wave) * 0.7, 7.0, 18.0)
	_teeth_lo = clampi(_teeth_lo_base + int(act / 2) + int(wave / 2), 2, 14)
	_teeth_hi = mini(16, _teeth_lo + 1 + act)
	var run_scale := 1.0 - 0.08 * float(mini(act, 3))
	_run_lo = maxf(8.0, _run_lo_base * run_scale)
	_run_hi = maxf(_run_lo + 2.0, _run_hi_base * run_scale)
	_hop = _hop_base * (0.9 + 0.07 * float(act))
	_slide_lo = maxf(8.0, _slide_lo_base * (0.85 + 0.08 * float(act)))
	_slide_hi = maxf(_slide_lo + 2.0, _slide_hi_base * (0.9 + 0.06 * float(act)))


func _note_ahead(beats: Array, index: int, later_acts: Array) -> void:
	if index + 1 < beats.size():
		_ahead = str(beats[index + 1])
		return
	for act in later_acts:
		var nxt: Array = act
		if nxt.size() > 0:
			_ahead = str(nxt[0])
			return
	_ahead = ""


func _lines(rows: Array) -> Array:
	var acts: Array = []
	for row in rows:
		acts.append(str(row).split(" ", false))
	return acts


func _journey(id: String) -> Array:
	# Four chapters. Each one uses the roof's pieces in a different order,
	# and later chapters run tighter and longer than the opening.
	match id:
		"annex":
			return _lines([
				"straight slide belt button gap teeth straight",
				"zip straight wall gap wall straight",
				"chain straight boost chain straight chain straight chain straight",
				"wall straight chain straight wall bumper straight",
				"spring rise belt button teeth gap spring straight straight",
			])
		"kiln":
			return _lines([
				"gap vent wall zip straight drop teeth spring wall vent chute gap teeth",
				"spring teeth vent wall chute rise drop wall teeth vent gap chute",
				"drop wall vent teeth rise chute wall spring drop teeth vent wall",
				"chute wall drop vent teeth wall rise vent wall teeth chute wall",
			])
		"culvert":
			return _lines([
				"slide jet teeth gap straight slide jet shutter gap teeth slide jet",
				"shutter jet chute teeth slide gap jet slide shutter teeth chute gap",
				"jet teeth slide shutter chute jet gap slide teeth jet shutter slide",
				"chute jet teeth slide shutter jet slide teeth gap jet chute slide",
			])
		"highline":
			return _lines([
				"gap gust canyon mill straight chute gap chain mill gust spring gap",
				"drop rise plunge gust gap mill chute drop spring gust rise gap",
				"boost plunge gust mill drop gap chute rise mill plunge gust gap",
				"plunge mill gust drop gap chute mill boost plunge gust gap mill",
			])
		"switchback":
			return _lines([
				"tower gap wall straight gap saw slide wall saw spring gap wall",
				"bounce saw gap bounce wall straight saw bounce gap wall bounce saw",
				"wall saw gap wall straight saw bounce wall saw gap bounce saw",
				"saw bounce wall bounce saw bounce gap saw bounce wall bounce saw",
			])
		"overpass":
			return _lines([
				"straight truck shutter gap mover straight truck button gap shutter mover truck",
				"button truck spring mover gap shutter hammer truck mover gap button shutter",
				"hammer truck mover button shutter truck gap spring mover hammer truck shutter",
				"truck hammer shutter mover truck button gap truck mover hammer shutter truck",
			])
		"gallery":
			return _lines([
				"slide gap canyon straight spring gap slide teeth crumble gap spring slide",
				"teeth drop slide button crumble gap spring slide drop teeth gap crumble",
				"drop crumble slide teeth spring gap bumper drop slide crumble gap teeth",
				"crumble gap drop slide teeth spring crumble gap slide drop button gap",
			])
		"spire":
			return _lines([
				"gust tower wall spring chute gap gust wall fan spring gap chute",
				"rise bounce gust fan wall plunge chute rise fan bounce gust wall",
				"chute rise fan bounce gust plunge wall fan rise bounce chute gust",
				"plunge fan bounce gust rise wall fan chute bounce gust plunge fan",
			])
		"canal":
			return _lines([
				"ice current slide gap straight chute ice slide current gap ice chute",
				"bounce ice current gap slide ice chute bounce current slide ice gap",
				"chute bounce current ice slide current gap ice bounce chute slide ice",
				"current ice bounce chute slide ice current bounce gap ice chute current",
			])
		"market":
			return _lines([
				"sign fan zip chain straight mover sign shutter fan gap boost sign",
				"hammer button shutter sign fan gap boost hammer mover sign button fan",
				"boost hammer sign mover button hammer shutter fan sign hammer gap button",
				"hammer sign fan button mover hammer boost sign shutter hammer fan sign",
			])
		"needle":
			return _lines([
				"teeth gap straight teeth spring gap teeth chain gap slide",
				"gap teeth spring boost teeth gap wall teeth slide gap",
				"teeth boost gap teeth spring slide gap teeth wall boost",
				"gap teeth boost wall teeth gap spring teeth boost gap",
			])
		"razor":
			return _lines([
				"saw gap wall straight gap saw slide wall spring gap",
				"bounce saw gap bounce wall saw bounce gap wall bounce",
				"wall bounce saw bounce gap saw bounce wall saw bounce",
				"saw bounce wall bounce saw bounce gap bounce wall saw",
			])
		"well":
			return _lines([
				"slide gap crumble drop spring gap slide drop crumble spring gap",
				"plunge rise gap crumble drop plunge spring gap rise drop",
				"plunge drop gap rise crumble plunge gap drop spring plunge",
				"crumble plunge gap drop rise plunge crumble gap plunge drop",
				"slide gap crumble spring wall slide gap rise crumble slide spring gap",
				"chute slide wall crumble spring slide gap chute crumble wall slide gap",
			])
		"flue":
			return _lines([
				"vent slide teeth gap slide vent teeth straight shutter gap",
				"slide vent chute teeth gap slide vent shutter teeth chute",
				"vent teeth slide chute teeth vent gap slide shutter vent",
				"chute vent slide teeth vent slide chute teeth gap vent",
			])
		"gale":
			return _lines([
				"mill gust gap fan spring gust mill gap chute fan",
				"gust rise mill chute fan gust gap mill spring chute",
				"fan gust mill plunge gap chute gust fan rise mill",
				"mill plunge gust fan chute gust mill gap fan plunge",
				"gust mill fan gap chute gust mill plunge fan gap gust",
			])
		"glaze":
			return _lines([
				"ice current slide gap ice chute current slide gap ice",
				"bounce ice chute current gap ice bounce slide current ice",
				"ice bounce current chute bounce ice gap current slide bounce",
				"current bounce ice chute ice bounce current ice gap bounce",
			])
		"clockwork":
			return _lines([
				"truck gap mover straight shutter truck button gap mover truck",
				"hammer button truck shutter mover hammer gap truck button shutter",
				"mover hammer truck button shutter truck hammer mover gap button",
				"hammer truck mover shutter button hammer truck gap mover hammer",
				"truck mover gap hammer truck shutter mover button truck hammer gap",
			])
		"spireline":
			return _lines([
				"fan rise gust wall chute fan gap spring wall gust",
				"chute bounce fan plunge rise gust wall fan bounce chute",
				"rise fan bounce chute gust plunge fan wall bounce rise",
				"plunge chute fan bounce rise fan gust bounce chute fan",
			])
		"span":
			return _lines([
				"gust gap spring straight gap boost gust chute spring gap",
				"gap drop gust chute spring gap boost drop gust gap",
				"plunge gust gap boost chute gap gust drop spring plunge",
				"gust plunge gap chute boost gap gust spring chute gap",
				"gap gust boost chute gap spring gust gap",
			])
		"blackout":
			return _lines([
				"sign gap fan straight sign shutter fan gap wall sign",
				"bounce sign saw fan gap bounce sign wall fan saw",
				"bounce sign bounce fan saw sign wall bounce fan sign",
				"fan bounce sign saw bounce fan sign bounce wall fan",
				"bounce sign fan wall bounce saw sign fan bounce gap",
			])
		_:
			return _lines([
				"belt gap boost slide spring straight belt teeth gap boost",
				"button teeth belt slide boost rise gap spring belt boost",
				"rise belt boost teeth slide spring gap belt boost rise",
				"boost belt spring slide teeth boost gap rise belt boost",
			])


func _segment(kind: String) -> void:
	_kinds[kind] = int(_kinds.get(kind, 0)) + 1
	match kind:
		"straight":
			_straight(_rng.randf_range(_run_lo, _run_hi))
		"gap":
			_gap()
		"slide":
			_slide()
		"wall":
			_wall()
		"bounce":
			_bounce()
		"bumper":
			_bumper()
		"drop":
			_drop()
		"teeth":
			_teeth()
		"hammer":
			_hammer()
		"ice":
			_ice()
		"shutter":
			_shutter()
		"button":
			_button_gate()
		"boost":
			_boost_gap()
		"chain":
			_chain()
		"fan":
			_fan()
		"mover":
			_mover()
		"rise":
			_rise()
		"plunge":
			_plunge()
		"tower":
			_tower()
		"zip":
			_zip()
		"canyon":
			_canyon()
		"split":
			_split()
		"belt":
			_belt()
		"vent":
			_vent()
		"jet":
			_jet()
		"gust":
			_gust()
		"saw":
			_saw()
		"truck":
			_truck()
		"crumble":
			_crumble()
		"sign":
			_sign()
		"current":
			_current()
		"spring":
			_spring()
		"chute":
			_chute()
		"mill":
			_mill()
		_:
			_straight(18.0)


func _half() -> float:
	return 3.4 if not _narrow else _lane_half


func _funnel() -> void:
	var length := 18.0
	var steps := 4
	var step := length / float(steps)
	var z1 := _solid_end
	for i in steps:
		var t := float(i + 1) / float(steps)
		var half := lerpf(6.4, _lane_half, t)
		var z0 := z1 - step
		_slab(-half, half, z0, z1, _floor_y, _concrete if i % 2 == 0 else _dark)
		z1 = z0
	_solid_end = z1
	travel += length
	_since_cp += length
	_mark_checkpoint()


func _straight(length: float) -> void:
	var near := _solid_end
	var far := near - length
	var color := _concrete if int(travel / 18.0) % 2 == 0 else _dark
	if _narrow and length >= 12.0:
		_bitten(far, near, color)
		_sprinkle(far, near)
	else:
		var half := _half()
		_slab(-half, half, far, near, _floor_y, color)
	_solid_end = far
	travel += length
	_since_cp += length
	_min_floor = minf(_min_floor, _floor_y)
	if not _narrow and length >= 16.0 and _rng.randf() < 0.4:
		_back_pad(near - length * 0.55)
	if _since_cp > _cp_span:
		_mark_checkpoint()


func _bitten(far: float, near: float, color: Color) -> void:
	var z := near
	while z > far + 0.4:
		var z0 := maxf(far, z - _rng.randf_range(6.2, 8.4))
		var bite := _rng.randf_range(1.25, 1.55)
		var min_x := -_lane_half
		var max_x := _lane_half
		if _bite_side > 0.0:
			max_x = _lane_half - bite
		else:
			min_x = -_lane_half + bite
		_slab(min_x, max_x, z0, z, _floor_y, color)
		_chunk(_bite_side, (z0 + z) * 0.5)
		z = z0
		_bite_side = -_bite_side


func _chunk(side: float, z: float) -> void:
	var x := side * _rng.randf_range(3.4, 5.2)
	var w := _rng.randf_range(1.1, 2.2)
	if _kit_on():
		_place_prop(_KIT_CHUNK, Vector3(x, _floor_y - 0.55, z), Vector3(1.2, 1.05, 1.35), 0.4 * side, _CHUNK_POS, _CHUNK_SIZE, "center")
		return
	_dress(Vector3(x, _floor_y - _rng.randf_range(1.4, 3.2), z), Vector3(w, 0.35, _rng.randf_range(1.4, 2.6)), _dark)


func _sprinkle(far: float, near: float) -> void:
	var lo := far + 10.0
	var hi := near - 5.0
	if hi - lo < 5.0:
		return
	var count := 1 if hi - lo < 16.0 else 2
	for i in count:
		var z := lerpf(hi, lo, (float(i) + 1.0) / (float(count) + 1.0))
		if i == 0:
			_bar_at(z)
		else:
			_hurdle_at(z, 0.0)


func _deck(length: float, half: float, skin: String = "") -> void:
	var far := _solid_end - length
	var color := _concrete if int(travel / 18.0) % 2 == 0 else _dark
	_slab(-half, half, far, _solid_end, _floor_y, color, false, 0.0, "", skin)
	_solid_end = far
	travel += length
	_since_cp += length
	_min_floor = minf(_min_floor, _floor_y)


func _landing() -> void:
	_deck(_landing_len, 2.7)
	_mark_checkpoint()


func _gap() -> void:
	var span := _rng.randf_range(3.7, 4.2) * _gap_scale
	var lip := _solid_end
	_hint("JUMP", Vector3(0, _floor_y + 2.3, lip - 1.2))
	_solid_end -= span
	travel += span
	if span >= 4.9:
		_jump_ring(0.0, lip - span * 0.46, _floor_y + 1.12)
	elif span >= 4.25 and _rng.randf() < 0.55:
		_jump_ring(0.0, lip - span * 0.46, _floor_y + 1.12)
	_landing()


func _slide() -> void:
	var length := _rng.randf_range(_slide_lo, _slide_hi)
	var near_z := _solid_end
	_hint("SLIDE", Vector3(0, _floor_y + 2.5, near_z - 1.0))
	_deck(length, 1.7, "duct")
	var far_z := _solid_end
	var center_z := (near_z + far_z) * 0.5
	var depth := absf(near_z - far_z)
	var dressed := _kit_on()
	_box(Vector3(-2.15, _floor_y + 1.45, center_z), Vector3(0.55, 2.9, depth), _metal, false, 0.0, "", dressed)
	_box(Vector3(2.15, _floor_y + 1.45, center_z), Vector3(0.55, 2.9, depth), _metal, false, 0.0, "", dressed)
	_box(Vector3(0, _floor_y + 1.28, center_z), Vector3(3.7, 0.36, depth), _hazard, false, 0.0, "roof", dressed)
	_slide_lip(near_z)
	# Small floor pads. They shove you forward with no lift, and they sit off center.
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_shove_at(lerpf(near_z, far_z, 0.38), side * 0.7, _floor_y)
	if depth > 12.0:
		_shove_at(lerpf(near_z, far_z, 0.7), -side * 0.62, _floor_y)
	_landing()


func _slide_lip(near_z: float) -> void:
	# Hands can catch this. The body cannot, so the slide underneath stays open.
	var lip := StaticBody3D.new()
	lip.collision_layer = 4
	lip.collision_mask = 0
	lip.add_to_group("roof")
	lip.position = Vector3(0.0, _floor_y + 1.09, near_z - 0.08)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.2, 0.74, 0.28)
	shape.shape = box
	lip.add_child(shape)
	add_child(lip)


func _wall() -> void:
	var side := -1 if _rng.randf() < 0.5 else 1
	var pit := _rng.randf_range(12.4, 14.6)
	var face := float(side) * 1.08
	var thick := 1.25
	var center_x := face + float(side) * thick * 0.5
	var z_hi := _solid_end + 8.0
	var z_lo := _solid_end - pit + 3.5
	var center_z := (z_hi + z_lo) * 0.5
	var depth := absf(z_hi - z_lo)
	var wall_size := Vector3(thick, 12.0, depth)
	var wall_center := Vector3(center_x, _floor_y + 4.2, center_z)
	_box(wall_center, wall_size, _accent, false, 0.0, "", _kit_on())
	if _kit_on():
		_pave_run_wall(wall_center, wall_size, float(side))
	# The pads sit on the face, over the gap, so the shove happens while you are on the wall.
	var run_z := _solid_end - 1.8
	_wall_pad(side, run_z, face, _floor_y)
	if run_z - 6.2 > z_lo + 1.4:
		_wall_pad(side, run_z - 6.2, face, _floor_y)
	_hint("WALL RUN", Vector3(face * 0.35, _floor_y + 2.2, _solid_end + 3.0))
	_solid_end -= pit
	travel += pit
	_landing()


func _bounce() -> void:
	var hops := _hops
	var hop := _hop
	var overlap := 2.8
	var start := _solid_end
	_hint("BOUNCE", Vector3(0, _floor_y + 2.4, start + 2.0))
	var z_cursor := start + 1.4
	for i in hops:
		var side := -1 if i % 2 == 0 else 1
		var z_hi := z_cursor
		var z_lo := z_cursor - hop
		var center_z := (z_hi + z_lo) * 0.5
		var face := float(side) * 1.55
		var thick := 1.15
		var center_x := face + float(side) * thick * 0.5
		var wall_size := Vector3(thick, 14.0, hop)
		var wall_center := Vector3(center_x, _floor_y + 5.0, center_z)
		_box(wall_center, wall_size, _accent)
		_crown_boost(wall_center, wall_size)
		z_cursor = z_lo + overlap
	var pit := hop * float(hops) - overlap * float(hops - 1) + 3.2
	_solid_end -= pit
	travel += pit
	_landing()


func _tower() -> void:
	_hint("CLIMB", Vector3(0, _floor_y + 2.6, _solid_end + 2.0))
	_deck(8.0, 3.2)
	var base := _floor_y
	var z := _solid_end
	var hop := 4.6
	for i in 8:
		var side := -1 if i % 2 == 0 else 1
		var face := float(side) * 1.2
		var thick := 1.05
		var center_x := face + float(side) * thick * 0.5
		var center_z := z - hop * 0.42
		_box(Vector3(center_x, base + 8.0, center_z), Vector3(thick, 16.0, hop * 0.88), _accent)
		z -= hop * 0.62
	_floor_y = base + 9.0
	var near := z - 1.4
	var far := near - 12.0
	_slab(-3.2, 3.2, far, near, _floor_y, _concrete)
	_pier(Vector3(0, (base + _floor_y) * 0.5, (near + far) * 0.5), _floor_y - base)
	_solid_end = far
	travel += 8.0 + hop * 5.0 + 12.0
	_since_cp += 8.0 + hop * 5.0 + 12.0
	_min_floor = minf(_min_floor, base)
	_landing()


func _zip() -> void:
	_hint("ZIP", Vector3(0, _floor_y + 2.8, _solid_end - 1.2))
	_deck(8.0, 3.4)
	var lip := _solid_end
	var y := _floor_y
	var reach := 18.0
	var lines: Array[float] = [-1.25, 1.25]
	for x in lines:
		var start := Vector3(x, y + 1.55, lip - 0.15)
		var finish := Vector3(x, y + 1.22, lip - reach)
		_cable(start, finish)
		var lean := 0.72 if x > 0.0 else -0.72
		_wire_pole(Vector3(x + lean, y, lip + 0.85))
		_wire_pole(Vector3(x + lean, y, lip - reach + 0.35))
	var land_near := lip - reach + 3.2
	var land_far := lip - reach - 12.0
	_slab(-3.6, 3.6, land_far, land_near, y, _concrete)
	_solid_end = land_far
	travel += 8.0 + reach + 12.0
	_since_cp += 8.0 + reach + 12.0
	_min_floor = minf(_min_floor, _floor_y)
	_landing()


func _wire_pole(at: Vector3) -> void:
	if _kit_on():
		var tall := 2.55 / _POLE_SIZE.y
		_place_prop(_KIT_POLE, at, Vector3(tall, tall, tall), 0.0, _POLE_POS, _POLE_SIZE, "bottom")
		return
	_box(Vector3(at.x, at.y + 0.78, at.z), Vector3(0.08, 1.56, 0.08), _metal)


func _canyon() -> void:
	if _canyons >= 2 or _floor_y < _plunge_cut:
		_plunge()
		return
	_canyons += 1
	var span := 9.4
	var drop := 16.5
	var lip := _solid_end
	_hint("SEND IT", Vector3(0, _floor_y + 2.8, lip - 1.4))
	_jump_ring(0.0, lip - span * 0.28, _floor_y + 1.2)
	_solid_end -= span
	travel += span
	_floor_y -= drop
	var near := _solid_end
	var length := 16.0
	var far := near - length
	_slab(-3.6, 3.6, far, near, _floor_y, _dark)
	_pier(Vector3(0, _floor_y - drop * 0.35, (near + far) * 0.5), drop)
	_solid_end = far
	travel += length
	_since_cp += span + length
	_min_floor = minf(_min_floor, _floor_y)
	_mark_checkpoint()


func _pier(at: Vector3, height: float) -> void:
	if height < 1.0:
		return
	_dress(at, Vector3(1.6, height, 1.6), _metal)


func _cable(a: Vector3, b: Vector3) -> void:
	var line := Area3D.new()
	line.set_script(load("res://scripts/zip.gd"))
	var along := b - a
	line.position = (a + b) * 0.5
	if along.length() > 0.5:
		line.basis = Basis.looking_at(along.normalized(), Vector3.UP)
	line.add_to_group("zip")
	add_child(line)
	var from := a
	var to := b
	if is_inside_tree():
		from = to_global(a)
		to = to_global(b)
	line.setup(from, to)
	var length := a.distance_to(b)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.7, 1.45, length)
	shape.shape = box
	line.add_child(shape)
	var mesh := MeshInstance3D.new()
	var bar := BoxMesh.new()
	bar.size = Vector3(0.08, 0.08, length)
	mesh.mesh = bar
	mesh.material_override = _glow(_accent)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	line.add_child(mesh)


func _bumper() -> void:
	var length := 36.0
	var half := 6.4
	var y := _floor_y
	var near := _solid_end
	var far := near - length
	_hint("BUMPERS", Vector3(0, y + 2.7, near - 1.6))
	_slab(-half, half, far, near, y, _concrete)
	var wall_h := 3.15
	var wall_t := 0.48
	var mid_z := (near + far) * 0.5
	var dressed := _kit_on()
	_box(Vector3(-half, y + wall_h * 0.5, mid_z), Vector3(wall_t, wall_h, length), _dark, false, 0.0, "", dressed)
	_box(Vector3(half, y + wall_h * 0.5, mid_z), Vector3(wall_t, wall_h, length), _dark, false, 0.0, "", dressed)
	if dressed:
		_pave_rail(-half, y + wall_h * 0.5, far, near, 1.0, wall_h)
		_pave_rail(half, y + wall_h * 0.5, far, near, -1.0, wall_h)
	else:
		_dress(Vector3(-half, y + wall_h + 0.08, mid_z), Vector3(wall_t + 0.08, 0.16, length), _accent)
		_dress(Vector3(half, y + wall_h + 0.08, mid_z), Vector3(wall_t + 0.08, 0.16, length), _accent)
	var bags := [
		[-2.5, 0.18, 1.42],
		[2.7, 0.34, 1.22],
		[0.15, 0.5, 1.62],
		[-2.9, 0.66, 1.28],
		[2.35, 0.82, 1.48],
	]
	for i in bags.size():
		var spot: Array = bags[i]
		var along := lerpf(near - 5.5, far + 8.0, float(spot[1]))
		var color := _accent.lightened(0.12) if i % 2 == 0 else _accent.lightened(0.42)
		_bumper_bag(Vector3(float(spot[0]), y, along), float(spot[2]), color)
	_solid_end = far
	travel += length
	_since_cp += length
	_min_floor = minf(_min_floor, y)
	_landing()


func _bumper_bag(at: Vector3, radius: float, color: Color) -> void:
	var body := StaticBody3D.new()
	body.set_script(load("res://scripts/bumper.gd"))
	body.position = Vector3(at.x, at.y + radius * 0.9, at.z)
	body.collision_layer = 1
	body.collision_mask = 0
	body.add_to_group("bumper")
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = radius
	col.shape = shape
	body.add_child(col)
	if _kit_on():
		var holder := Node3D.new()
		holder.name = "Bag"
		var fit := (radius * 2.0) / _BAG_SIZE.x
		body.add_child(holder)
		_place_prop(_KIT_BAG, Vector3.ZERO, Vector3(fit, fit, fit), 0.0, _BAG_POS, _BAG_SIZE, "center", holder)
		add_child(body)
		return
	var mesh := MeshInstance3D.new()
	mesh.name = "Bag"
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 24
	sphere.rings = 16
	mesh.mesh = sphere
	mesh.material_override = _mat(color, 0.32, 0.04)
	body.add_child(mesh)
	var band := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.07
	torus.outer_radius = radius + 0.1
	torus.rings = 8
	torus.ring_segments = 18
	band.mesh = torus
	band.material_override = _mat(Color(0.96, 0.94, 0.88), 0.45, 0.0)
	body.add_child(band)
	var knot := MeshInstance3D.new()
	var cap := SphereMesh.new()
	cap.radius = radius * 0.16
	cap.height = radius * 0.3
	knot.mesh = cap
	knot.position = Vector3(0, radius * 0.9, 0)
	knot.material_override = _mat(color.darkened(0.28), 0.5, 0.0)
	body.add_child(knot)
	add_child(body)


func _drop() -> void:
	if _drops >= _drop_cap or _floor_y < _floor_cut:
		_gap()
		return
	_drops += 1
	var span := _rng.randf_range(3.9, 4.3)
	var lip := _solid_end
	_hint("DROP", Vector3(0, _floor_y + 2.2, _solid_end - 1.0))
	if _rng.randf() < 0.55:
		_jump_ring(0.0, lip - span * 0.42, _floor_y + 1.05)
	_solid_end -= span
	travel += span
	_floor_y -= _rng.randf_range(5.2, 7.4)
	_landing()


func _rise() -> void:
	var side := -1 if _rng.randf() < 0.5 else 1
	var span := _rng.randf_range(5.9, 6.4)
	var climb := _climb
	var lip := _solid_end
	_hint("KICK UP", Vector3(float(side) * 0.5, _floor_y + 2.5, lip + 2.2))
	var face := float(side) * 1.05
	var thick := 1.15
	var center_x := face + float(side) * thick * 0.5
	var z_hi := lip + 4.5
	var z_lo := lip - span + 2.4
	var center_z := (z_hi + z_lo) * 0.5
	var depth := absf(z_hi - z_lo)
	var wall_size := Vector3(thick, 16.0, depth)
	var wall_center := Vector3(center_x, _floor_y + 6.5, center_z)
	_box(wall_center, wall_size, _accent, false, 0.0, "", _kit_on())
	if _kit_on():
		_pave_run_wall(wall_center, wall_size, float(side))
	_wall_pad(side, lip - 1.4, face, _floor_y)
	_solid_end = lip - span
	travel += span
	_floor_y += climb
	var near := _solid_end
	var length := 12.0
	var far := near - length
	var open := 4.6
	var min_x := -open
	var max_x := open
	if side > 0:
		max_x = face - 0.12
	else:
		min_x = face + 0.12
	_slab(min_x, max_x, far, near, _floor_y, _concrete)
	var fascia_top := _floor_y
	var fascia_bottom := _floor_y - climb - 1.1
	var fascia_h := fascia_top - fascia_bottom
	var fascia_y := (fascia_top + fascia_bottom) * 0.5
	var fascia_cx := (min_x + max_x) * 0.5
	var fascia_at := Vector3(fascia_cx, fascia_y, near + 0.16)
	var fascia_size := Vector3(max_x - min_x, fascia_h, 0.32)
	_box(fascia_at, fascia_size, _dark, false, 0.0, "", _kit_on())
	if _kit_on():
		_pave_fascia(fascia_at, fascia_size)
	var pier_h := climb + 7.0
	if _kit_on():
		var column_s := Vector3(1.5 / _COLUMN_SIZE.x, pier_h / _COLUMN_SIZE.y, 1.5 / _COLUMN_SIZE.z)
		_place_prop(_KIT_COLUMN, Vector3(0, _floor_y - pier_h, (near + far) * 0.5), column_s, 0.0, _COLUMN_POS, _COLUMN_SIZE, "bottom")
	else:
		_dress(Vector3(0, _floor_y - pier_h * 0.5, (near + far) * 0.5), Vector3(1.5, pier_h, 1.5), _metal)
	_solid_end = far
	travel += length
	_since_cp += span + length
	_min_floor = minf(_min_floor, fascia_bottom)
	_mark_checkpoint()


func _plunge() -> void:
	if _plunges >= _plunge_cap or _floor_y < _plunge_cut:
		_gap()
		return
	_plunges += 1
	var span := _rng.randf_range(7.4, 8.3)
	var drop := _rng.randf_range(8.2, 10.4)
	var lip := _solid_end
	_hint("DOWN", Vector3(0, _floor_y + 2.6, lip - 1.5))
	_jump_ring(0.0, lip - span * 0.4, _floor_y + 1.15)
	_dress(Vector3(0, _floor_y + 0.04, lip - 0.35), Vector3(5.4, 0.05, 0.16), _hazard)
	_solid_end -= span
	travel += span
	_floor_y -= drop
	var near := _solid_end
	var length := 13.0
	var far := near - length
	_slab(-3.2, 3.2, far, near, _floor_y, _dark)
	var pier_h := drop + 6.0
	_dress(Vector3(0, _floor_y - pier_h * 0.42, (near + far) * 0.5), Vector3(1.8, pier_h * 0.84, 1.8), _metal)
	_solid_end = far
	travel += length
	_since_cp += span + length
	_min_floor = minf(_min_floor, _floor_y)
	_mark_checkpoint()


func _teeth() -> void:
	_hint("DON'T FALL", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var count := _rng.randi_range(_teeth_lo, _teeth_hi)
	for i in count:
		var gap := _rng.randf_range(2.7, 3.45)
		_solid_end -= gap
		travel += gap
		var length := _rng.randf_range(4.4, 6.2)
		var far := _solid_end - length
		var shift := _rng.randf_range(-0.45, 0.45)
		var color := _dark if i % 2 == 0 else _concrete
		_slab(shift - _tooth_half, shift + _tooth_half, far, _solid_end, _floor_y, color, false, 0.0, "", "plank")
		_chunk(1.0 if shift >= 0.0 else -1.0, (far + _solid_end) * 0.5)
		_solid_end = far
		travel += length
		_since_cp += length + gap
	_min_floor = minf(_min_floor, _floor_y)
	_mark_checkpoint()


func _hammer() -> void:
	_hint("HAMMER", Vector3(0, _floor_y + 2.6, _solid_end - 1.0))
	var near := _solid_end
	_deck(16.0, 2.6)
	_swing(near - 8.0)
	_landing()


func _swing(z: float, x: float = 0.0) -> void:
	var rig := AnimatableBody3D.new()
	rig.set_script(load("res://scripts/hammer.gd"))
	rig.position = Vector3(x, _floor_y + 3.35, z)
	rig.phase = _rng.randf() * TAU
	rig.period = _rng.randf_range(1.65, 2.15)
	_mover_mesh(rig, Vector3(0.16, 2.3, 0.16), Vector3(0, -1.15, 0), _metal)
	_mover_mesh(rig, Vector3(0.78, 0.52, 0.78), Vector3(0, -2.48, 0), _hazard)
	var area := Area3D.new()
	area.position = Vector3(0, -2.48, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitoring = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 0.75, 1.0)
	shape.shape = box
	area.add_child(shape)
	rig.add_child(area)
	rig.area = area
	add_child(rig)


func _split() -> void:
	if _forks >= 3 or not _narrow:
		_straight(18.0)
		return
	_forks += 1
	if _forks % 2 == 0:
		_split_cut()
	else:
		_split_weave()


func _split_weave() -> void:
	# The bow stays wide and empty. The straight road is shorter, and it is a
	# single-file lane with jumps, a saw, and a hammer.
	var fork := _begin_fork(17.0, 36.0)
	var low := float(fork["low"])
	var risk_x := float(fork["risk_x"])
	var mouth := float(fork["mouth"])
	var join := float(fork["join"])
	var half := RISK_HALF
	var gap_near := mouth - 14.4
	var gap_far := mouth - 16.9
	_slab(risk_x - half, risk_x + half, gap_near, mouth - 0.35, low, _dark)
	_slab(risk_x - half, risk_x + half, join, gap_far, low, _dark)
	_prop(risk_x, low, mouth - 8.0)
	_prop(risk_x, low, mouth - 22.0)
	_prop(risk_x, low, mouth - 31.0)
	_dress(Vector3(risk_x, low + 0.04, gap_near + 0.12), Vector3(half * 2.0 - 0.12, 0.05, 0.14), _hazard)
	_dress(Vector3(risk_x, low + 0.04, gap_far - 0.12), Vector3(half * 2.0 - 0.12, 0.05, 0.14), _hazard)
	_floor_y = low
	_hurdle_at(mouth - 5.2, risk_x, half * 2.0 - 0.16)
	_bar_at(mouth - 9.6)
	_lane_saw(risk_x, mouth - 20.4, 0.28)
	_swing(mouth - 24.6, risk_x)
	_hurdle_at(mouth - 28.4, risk_x, half * 2.0 - 0.16)
	_close_split(float(fork["near"]), join, low)


func _split_cut() -> void:
	# The shortcut is still the boost gap. The lane around it is narrow, and the
	# landing has a saw and a hurdle so the boost does not carry you through clean.
	var fork := _begin_fork(17.0, 38.0)
	var low := float(fork["low"])
	var risk_x := float(fork["risk_x"])
	var mouth := float(fork["mouth"])
	var join := float(fork["join"])
	var half := RISK_HALF
	var lip := mouth - 14.0
	var landing := lip - 8.2
	_slab(risk_x - half, risk_x + half, lip, mouth - 0.35, low, _dark)
	_slab(risk_x - half, risk_x + half, join, landing, low, _dark)
	_prop(risk_x, low, mouth - 6.0)
	_prop(risk_x, low, mouth - 30.0)
	_floor_y = low
	_hurdle_at(mouth - 5.4, risk_x, half * 2.0 - 0.16)
	_bar_at(mouth - 9.4)
	_boost_at(lip + 1.15, risk_x, low, false, half * 2.0 - 0.2)
	_dress(Vector3(risk_x, low + 0.04, lip - 0.12), Vector3(half * 2.0 - 0.12, 0.05, 0.16), _hazard)
	_lane_saw(risk_x, landing - 3.4, 0.28)
	_hurdle_at(landing - 7.2, risk_x, half * 2.0 - 0.16)
	_close_split(float(fork["near"]), join, low)


func _begin_fork(amp: float, span: float) -> Dictionary:
	var risk_side := _fork_side
	_fork_side = -_fork_side
	var high := _floor_y
	var low := high - 5.6
	var near := _solid_end
	var mouth := near - 8.0
	_hint("SPLIT", Vector3(0, high + 2.35, near - 1.3))
	_slab(-7.4, 7.4, mouth, near, high, _concrete)
	var join := mouth - span
	_bow_lane(-risk_side, mouth, join, high, amp)
	var risk_x := risk_side * 5.15
	_slab(risk_x - RISK_HALF, risk_x + RISK_HALF, mouth - 2.4, mouth + 0.6, high, _dark)
	_dress(Vector3(risk_x, high + 0.04, mouth - 2.2), Vector3(RISK_HALF * 2.0 - 0.12, 0.05, 0.16), _hazard)
	return {
		"near": near,
		"mouth": mouth,
		"join": join,
		"low": low,
		"risk_x": risk_x,
	}


func _prop(x: float, low: float, z: float) -> void:
	_dress(Vector3(x, low - 3.6, z), Vector3(1.15, 5.2, 1.15), _metal)


func _bow_lane(bow_sign: float, z_near: float, z_far: float, y: float, amp: float) -> void:
	var span := z_near - z_far
	var steps := maxi(10, int(ceil(amp * 1.4)))
	var step := span / float(steps)
	var z1 := z_near
	var bias := 3.1
	for i in steps:
		var t := float(i) / float(max(steps - 1, 1))
		var cx := bow_sign * (sin(t * PI) * amp + bias * (1.0 - t))
		var z0 := z1 - step
		var color := _concrete if i % 2 == 0 else _dark
		_slab(cx - 2.35, cx + 2.35, z0, z1 + 0.75, y, color)
		z1 = z0


func _close_split(near: float, join: float, y: float) -> void:
	var merge_far := join - 9.0
	# Reaches back under the end of the high road so that bow can drop onto it.
	_slab(-7.4, 7.4, merge_far, join + 6.5, y, _concrete)
	_floor_y = y
	_solid_end = merge_far
	var length := near - merge_far
	travel += length
	_since_cp += length
	_min_floor = minf(_min_floor, y)
	_mark_checkpoint()


func _ice() -> void:
	_hint("SLIP", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var push := 2.6 if _rng.randf() < 0.5 else -2.6
	var length := 14.0
	var far := _solid_end - length
	_slab(-2.7, 2.7, far, _solid_end, _floor_y, Color(0.58, 0.6, 0.64), true, push)
	var z := _solid_end - 1.5
	while z > far + 1.0:
		_dress(Vector3(0, _floor_y + 0.02, z), Vector3(4.6, 0.02, 0.08), _hazard)
		z -= 2.2
	_solid_end = far
	travel += length
	_since_cp += length
	_min_floor = minf(_min_floor, _floor_y)
	_landing()


func _belt() -> void:
	_hint("BELT", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var push := 9.0 if _rng.randf() < 0.5 else -9.0
	var length := 12.0
	var far := _solid_end - length
	_slab(-2.5, 2.5, far, _solid_end, _floor_y, _accent, false, push, "belt")
	if not _kit_on():
		var z := _solid_end - 1.2
		while z > far + 0.8:
			_dress(Vector3(push * 0.04, _floor_y + 0.04, z), Vector3(1.6, 0.04, 0.28), _hazard)
			z -= 1.6
	_solid_end = far
	travel += length
	_since_cp += length
	_gap()


func _vent() -> void:
	_hint("VENT", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(11.0, 2.5)
	var z := near - 5.5
	_glow_box(Vector3(0, _floor_y + 0.04, z), Vector3(1.8, 0.06, 1.8), _accent)
	var area := Area3D.new()
	area.set_script(load("res://scripts/vent.gd"))
	area.position = Vector3(0, _floor_y + 0.9, z)
	area.phase = _rng.randf() * TAU
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.7, 1.6, 1.7)
	shape.shape = box
	area.add_child(shape)
	var plume := MeshInstance3D.new()
	plume.name = "Plume"
	var plume_mesh := BoxMesh.new()
	plume_mesh.size = Vector3(0.7, 1.6, 0.7)
	plume.mesh = plume_mesh
	plume.position = Vector3(0, 0.5, 0)
	plume.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	plume.material_override = _glow(_accent.lightened(0.25))
	area.add_child(plume)
	add_child(area)
	_landing()


func _jet() -> void:
	_hint("JET", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	var near := _solid_end
	_deck(12.0, 2.45)
	var z := near - 6.0
	_box(Vector3(side * 2.15, _floor_y + 0.7, z), Vector3(0.45, 0.7, 0.7), _metal)
	_glow_box(Vector3(side * 1.85, _floor_y + 0.72, z), Vector3(0.2, 0.28, 0.28), _accent)
	_drift_volume(Vector3(side * 28.0, 0, 0), Vector3(0, _floor_y + 1.0, z), Vector3(3.6, 1.5, 2.4), false)
	for i in 3:
		_dress(Vector3(side * (1.4 - float(i) * 0.45), _floor_y + 0.7, z), Vector3(0.35, 0.08, 0.08), _accent.lightened(0.2))
	_landing()


func _gust() -> void:
	_hint("GUST", Vector3(0, _floor_y + 2.5, _solid_end - 1.0))
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	var near := _solid_end
	_deck(6.0, 2.4)
	var span := minf(4.6, 3.8 * _gap_scale)
	_solid_end -= span
	travel += span
	_since_cp += span
	var mid := near - 6.0 - span * 0.5
	for pole in [-1.0, 1.0]:
		_box(Vector3(pole * 1.7, _floor_y + 2.1, mid), Vector3(0.12, 4.2, 0.12), _metal)
		_dress(Vector3(pole * 1.15, _floor_y + 3.5, mid), Vector3(0.9, 0.9, 0.05), _accent)
	var gust_size := Vector3(3.2, 2.4, span * 0.75)
	var gust_at := Vector3(0, _floor_y + 1.5, mid)
	_drift_volume(Vector3(side * 16.0, 0, 0), gust_at, gust_size, true)
	var wind := MeshInstance3D.new()
	wind.set_script(load("res://scripts/windfield.gd"))
	wind.position = gust_at
	wind.push = Vector3(side * 16.0, 0, 0)
	wind.span = gust_size
	add_child(wind)
	_landing()


func _saw() -> void:
	_hint("SAW", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(12.0, 2.5)
	var saw := AnimatableBody3D.new()
	saw.set_script(load("res://scripts/saw.gd"))
	saw.position = Vector3(0, _floor_y + 0.48, near - 6.0)
	saw.travel = 1.9
	saw.period = 1.15
	saw.phase = _rng.randf() * TAU
	var blade := Node3D.new()
	blade.name = "Blade"
	saw.add_child(blade)
	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.42
	disc_mesh.bottom_radius = 0.42
	disc_mesh.height = 0.08
	disc.mesh = disc_mesh
	disc.rotation.x = PI * 0.5
	disc.material_override = _mat(_hazard, 0.35, 0.45)
	blade.add_child(disc)
	for i in 4:
		var tooth := MeshInstance3D.new()
		var tooth_mesh := BoxMesh.new()
		tooth_mesh.size = Vector3(0.16, 0.16, 0.1)
		tooth.mesh = tooth_mesh
		var ang := float(i) * TAU / 4.0
		tooth.position = Vector3(cos(ang) * 0.5, sin(ang) * 0.5, 0)
		tooth.material_override = _mat(_metal, 0.4, 0.3)
		blade.add_child(tooth)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.15, 0.36, 0.36)
	shape.shape = box
	saw.add_child(shape)
	_box(Vector3(-2.2, _floor_y + 0.7, near - 6.0), Vector3(0.16, 1.4, 0.16), _metal)
	_box(Vector3(2.2, _floor_y + 0.7, near - 6.0), Vector3(0.16, 1.4, 0.16), _metal)
	add_child(saw)
	_landing()


func _truck() -> void:
	_hint("TRUCK", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(14.0, 2.7)
	var truck := AnimatableBody3D.new()
	truck.set_script(load("res://scripts/mover.gd"))
	truck.position = Vector3(0, _floor_y + 0.55, near - 7.0)
	truck.axis = Vector3(1, 0, 0)
	truck.travel = 2.15
	truck.period = 2.6
	truck.phase = _rng.randf() * TAU
	_mover_box(truck, Vector3(2.3, 0.85, 1.35), Vector3(0, 0, 0), _dark)
	_mover_box(truck, Vector3(0.7, 0.55, 1.15), Vector3(-0.55, 0.55, 0), _accent)
	_mover_mesh(truck, Vector3(0.28, 0.28, 0.28), Vector3(0.7, -0.28, 0.45), _metal)
	_mover_mesh(truck, Vector3(0.28, 0.28, 0.28), Vector3(0.7, -0.28, -0.45), _metal)
	_mover_mesh(truck, Vector3(0.28, 0.28, 0.28), Vector3(-0.7, -0.28, 0.45), _metal)
	_mover_mesh(truck, Vector3(0.28, 0.28, 0.28), Vector3(-0.7, -0.28, -0.45), _metal)
	add_child(truck)
	_landing()


func _crumble() -> void:
	_hint("CRUMBLE", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	_deck(5.5, 2.5)
	var span := 5.0
	var z_near := _solid_end
	_solid_end -= span
	travel += span
	_since_cp += span
	var plate := AnimatableBody3D.new()
	plate.set_script(load("res://scripts/crumble.gd"))
	plate.position = Vector3(0, _floor_y - 0.16, (z_near + _solid_end) * 0.5)
	plate.phase = _rng.randf() * 2.5
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(4.6, 0.32, span - 0.2)
	mesh.mesh = box_mesh
	mesh.material_override = _deck_mat(_dark, 0.9, 0.0)
	plate.add_child(mesh)
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var col := BoxShape3D.new()
	col.size = box_mesh.size
	shape.shape = col
	plate.add_child(shape)
	for crack in 3:
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(3.2, 0.03, 0.06)
		line.mesh = line_mesh
		line.position = Vector3(0, 0.17, lerpf(-1.4, 1.4, float(crack) / 2.0))
		line.rotation.y = 0.4 if crack == 1 else -0.25
		line.material_override = _mat(_hazard, 0.6, 0.0)
		plate.add_child(line)
	add_child(plate)
	_landing()


func _mill() -> void:
	_hint("MILL", Vector3(0, _floor_y + 2.6, _solid_end - 1.0))
	var near := _solid_end
	_deck(14.0, 2.7)
	var hub := Vector3(0, _floor_y + 1.55, near - 7.0)
	var rig := Node3D.new()
	rig.set_script(load("res://scripts/windmill.gd"))
	rig.position = hub
	rig.phase = _rng.randf() * TAU
	var rotor := Node3D.new()
	rotor.name = "Rotor"
	rig.add_child(rotor)
	for i in 3:
		var blade := Node3D.new()
		blade.rotation.z = float(i) * TAU / 3.0
		var mesh := MeshInstance3D.new()
		var board := BoxMesh.new()
		board.size = Vector3(2.35, 0.22, 0.1)
		mesh.mesh = board
		mesh.position = Vector3(1.42, 0, 0)
		mesh.material_override = _mat(_metal if i != 0 else _hazard, 0.42, 0.35)
		blade.add_child(mesh)
		var tip := MeshInstance3D.new()
		var tip_mesh := BoxMesh.new()
		tip_mesh.size = Vector3(0.34, 0.42, 0.12)
		tip.mesh = tip_mesh
		tip.position = Vector3(2.55, 0, 0)
		tip.material_override = _mat(_accent, 0.4, 0.1)
		blade.add_child(tip)
		var area := Area3D.new()
		area.name = "Hit"
		area.position = Vector3(1.5, 0, 0)
		area.collision_layer = 0
		area.collision_mask = 2
		area.monitoring = true
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(2.15, 0.42, 0.5)
		shape.shape = box
		area.add_child(shape)
		blade.add_child(area)
		rotor.add_child(blade)
	var cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.28
	cap_mesh.bottom_radius = 0.28
	cap_mesh.height = 0.22
	cap.mesh = cap_mesh
	cap.rotation.x = PI * 0.5
	cap.material_override = _mat(_accent, 0.35, 0.2)
	rig.add_child(cap)
	var tail := MeshInstance3D.new()
	var tail_mesh := BoxMesh.new()
	tail_mesh.size = Vector3(0.08, 0.7, 0.85)
	tail.mesh = tail_mesh
	tail.position = Vector3(0, 0.15, 0.7)
	tail.material_override = _mat(_hazard, 0.45, 0.1)
	rig.add_child(tail)
	_box(Vector3(0, _floor_y + 0.68, near - 7.0), Vector3(0.26, 1.36, 0.26), _metal)
	add_child(rig)
	_landing()


func _sign() -> void:
	_hint("SLIDE", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(12.0, 2.5)
	var rig := Node3D.new()
	rig.set_script(load("res://scripts/sign.gd"))
	rig.position = Vector3(0, _floor_y + 2.35, near - 6.0)
	rig.phase = _rng.randf() * TAU
	var board := Node3D.new()
	board.name = "Board"
	rig.add_child(board)
	var panel := MeshInstance3D.new()
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(2.6, 1.05, 0.12)
	panel.mesh = panel_mesh
	panel.position = Vector3(0, -0.62, 0)
	panel.material_override = _glow(_accent)
	board.add_child(panel)
	var area := Area3D.new()
	area.name = "Hit"
	area.position = Vector3(0, -0.85, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitoring = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.4, 0.55, 0.4)
	shape.shape = box
	area.add_child(shape)
	board.add_child(area)
	_box(Vector3(0, _floor_y + 2.7, near - 6.0), Vector3(0.16, 0.8, 0.16), _metal)
	add_child(rig)
	_landing()


func _current() -> void:
	_hint("CURRENT", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var push := 7.5 if _rng.randf() < 0.5 else -7.5
	var length := 14.0
	var far := _solid_end - length
	_slab(-2.6, 2.6, far, _solid_end, _floor_y, Color(0.72, 0.86, 0.92), true, push)
	var z := _solid_end - 1.4
	var dir := signf(push)
	while z > far + 1.0:
		_dress(Vector3(dir * 0.35, _floor_y + 0.05, z), Vector3(1.3, 0.04, 0.28), _accent)
		_dress(Vector3(dir * 0.95, _floor_y + 0.05, z - 0.35), Vector3(0.45, 0.04, 0.16), _hazard)
		z -= 2.4
	_solid_end = far
	travel += length
	_since_cp += length
	_min_floor = minf(_min_floor, _floor_y)
	_landing()


func _drift_volume(push: Vector3, pos: Vector3, size: Vector3, air_only: bool) -> void:
	var area := Area3D.new()
	area.set_script(load("res://scripts/drift.gd"))
	area.position = pos
	area.push = push
	area.air_only = air_only
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	add_child(area)


func _shutter() -> void:
	_hint("WALL", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(14.0, 3.2)
	var gate := AnimatableBody3D.new()
	gate.set_script(load("res://scripts/shutter.gd"))
	gate.position = Vector3(0, _floor_y + 1.2, near - 7.0)
	gate.phase = _rng.randf() * TAU
	_mover_box(gate, Vector3(1.7, 2.35, 0.42), Vector3(-1.8, 0, 0), _accent)
	_mover_box(gate, Vector3(1.7, 2.35, 0.42), Vector3(1.8, 0, 0), _accent)
	add_child(gate)
	_landing()


func _button_gate() -> void:
	_hint("BUTTON", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(15.0, 2.5)
	var door := AnimatableBody3D.new()
	door.set_script(load("res://scripts/gate.gd"))
	door.position = Vector3(0, _floor_y + 1.15, near - 10.0)
	door.phase = _rng.randf() * TAU
	_mover_box(door, Vector3(4.4, 2.15, 0.36), Vector3.ZERO, _hazard, _kit_on())
	if _kit_on():
		var gate_s := Vector3(4.4 / _GATE_SIZE.x, 2.15 / _GATE_SIZE.y, 0.42 / _GATE_SIZE.z)
		_place_prop(_KIT_GATE, Vector3.ZERO, gate_s, 0.0, _GATE_POS, _GATE_SIZE, "center", door)
	add_child(door)
	_pad(near - 2.4, door)
	_landing()


func _pad(z: float, door: Node) -> void:
	var area := Area3D.new()
	area.set_script(load("res://scripts/button.gd"))
	area.position = Vector3(0, _floor_y + 0.9, z)
	area.gate = door
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.5, 1.6)
	shape.shape = box
	area.add_child(shape)
	if _kit_on():
		var holder := Node3D.new()
		holder.position = Vector3(0, -0.9, 0)
		area.add_child(holder)
		area.pad = holder
		var button_s := 1.25 / _BUTTON_SIZE.x
		_place_prop(_KIT_BUTTON, Vector3.ZERO, Vector3(button_s, button_s * 0.72, button_s), 0.0, _BUTTON_POS, _BUTTON_SIZE, "bottom", holder)
		add_child(area)
		return
	var mesh := MeshInstance3D.new()
	var pad := BoxMesh.new()
	pad.size = Vector3(1.15, 0.1, 1.15)
	mesh.mesh = pad
	mesh.position = Vector3(0, -0.82, 0)
	var mat := _mat(Color(0.55, 0.55, 0.55), 0.45, 0.2)
	mesh.material_override = mat
	area.add_child(mesh)
	area.pad = mesh
	var rim := MeshInstance3D.new()
	var rim_mesh := BoxMesh.new()
	rim_mesh.size = Vector3(1.45, 0.06, 1.45)
	rim.mesh = rim_mesh
	rim.position = Vector3(0, -0.9, 0)
	rim.material_override = _mat(_hazard)
	area.add_child(rim)
	add_child(area)


func _crown_boost(center: Vector3, size: Vector3) -> void:
	var top := center.y + size.y * 0.5
	_boost_at(center.z, center.x, top)


func _fan() -> void:
	_hint("FAN", Vector3(0, _floor_y + 2.6, _solid_end - 1.0))
	var near := _solid_end
	_deck(6.0, 2.5)
	var gap := 7.5
	var column_z := near - 6.0 - gap * 0.35
	_solid_end -= gap
	travel += gap
	_since_cp += gap
	var rise := 4.2
	_fan_column(column_z, _floor_y - 0.4, _floor_y + rise + 2.4)
	_floor_y += rise
	_landing()


func _fan_column(z: float, y0: float, y1: float) -> void:
	var height := maxf(2.0, y1 - y0)
	var area := Area3D.new()
	area.set_script(load("res://scripts/fan.gd"))
	area.position = Vector3(0, (y0 + y1) * 0.5, z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.4, height, 3.4)
	shape.shape = box
	area.add_child(shape)
	var mesh := MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = 1.35
	tube.bottom_radius = 1.35
	tube.height = height
	mesh.mesh = tube
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.72, 0.86, 0.96, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = mat
	var fit := 2.55 / _FAN_SIZE.x
	var fan_h := _FAN_SIZE.y * fit
	var shaft := maxf(0.8, height - fan_h * 0.72)
	tube.height = shaft
	mesh.position = Vector3(0, height * 0.5 - shaft * 0.5, 0)
	area.add_child(mesh)
	_with_scene(_FAN_PATH, func(packed: PackedScene) -> void:
		var fan := packed.instantiate() as Node3D
		fan.name = "FanBody"
		fan.scale = Vector3(fit, fit, fit)
		fan.position = Vector3(0, -height * 0.5 + 0.18 + fan_h * 0.5, 0)
		_arm_fan(fan)
		_quiet_pad(fan)
		area.add_child(fan)
	)
	add_child(area)


func _mover() -> void:
	_hint("RIDE", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(7.0, 2.6)
	var gap := 7.2
	var plat := AnimatableBody3D.new()
	plat.set_script(load("res://scripts/mover.gd"))
	plat.position = Vector3(0, _floor_y, near - 7.0 - gap * 0.5)
	plat.axis = Vector3(1, 0, 0)
	plat.travel = 2.5
	plat.period = 2.7
	plat.phase = _rng.randf() * TAU
	_mover_box(plat, Vector3(2.6, 0.32, 3.4), Vector3.ZERO, _accent)
	_top_stripe(plat, Vector3(2.6, 0.32, 3.4))
	add_child(plat)
	_solid_end -= gap
	travel += gap
	_since_cp += gap
	_deck(11.0, 2.8)
	var wall := AnimatableBody3D.new()
	wall.set_script(load("res://scripts/mover.gd"))
	wall.position = Vector3(0, _floor_y + 1.25, _solid_end + 5.5)
	wall.axis = Vector3(1, 0, 0)
	wall.travel = 2.3
	wall.period = 2.3
	wall.phase = _rng.randf() * TAU
	_mover_box(wall, Vector3(2.4, 2.4, 0.42), Vector3.ZERO, _hazard)
	add_child(wall)
	_landing()


func _outer_walls() -> void:
	var z_near := 18.0
	var z_far := _solid_end - 12.0
	if z_near - z_far < 20.0:
		return
	var center_z := (z_near + z_far) * 0.5
	var depth := absf(z_near - z_far)
	for side in [-1, 1]:
		_box(Vector3(float(side) * 30.0, -4.0, center_z), Vector3(1.4, 120.0, depth), _accent)


func _spring() -> void:
	var roll := _rng.randi() % 3
	if roll == 0:
		_spring_fork(true)
	elif roll == 1:
		_spring_fork(false)
	else:
		_spring_mandatory()


func _spring_fork(high_fast: bool) -> void:
	_hint("UP" if high_fast else "DETOUR", Vector3(1.5, _floor_y + 2.5, _solid_end - 1.2))
	_deck(8.0, 3.1)
	var lip := _solid_end
	_spring_pad(1.55, lip + 3.6, _floor_y, false)
	var high_y := _floor_y + 4.0
	var tight := RISK_HALF
	if high_fast:
		_slab(-tight, tight, lip - 13.0, lip + 0.6, high_y, _accent)
		_hurdle_at(lip - 4.2, 0.0, tight * 2.0 - 0.16, high_y)
		_bar_at(lip - 8.2, high_y)
		_lane_saw(0.0, lip - 11.0, 0.28, high_y)
		_high_lane(lip, lip - 13.0, _floor_y, 7.5)
		_solid_end = lip - 13.0
		travel += 22.0
		_since_cp += 22.0
	else:
		_slab(-tight, tight, lip - 16.0, lip, _floor_y, _concrete)
		_hurdle_at(lip - 4.0, 0.0, tight * 2.0 - 0.16)
		_bar_at(lip - 8.2)
		_lane_saw(0.0, lip - 12.4, 0.28)
		_high_lane(lip + 0.4, lip - 16.0, high_y, 8.5)
		_solid_end = lip - 16.0
		travel += 24.0
		_since_cp += 24.0
	_landing()


func _spring_mandatory() -> void:
	_hint("BOUNCE", Vector3(0, _floor_y + 2.5, _solid_end - 1.2))
	var near := _solid_end
	_deck(7.0, 2.6)
	var lip := _solid_end
	_spring_pad(0.0, lip + 3.4, _floor_y, true)
	if _rng.randf() < 0.5:
		_jump_ring(0.0, lip - 5.0, _floor_y + 3.6)
	_floor_y += 4.0
	_slab(-2.2, 2.2, lip - 12.0, lip + 0.5, _floor_y, _accent)
	_solid_end = lip - 12.0
	travel += near - _solid_end
	_since_cp += near - _solid_end
	_landing()


func _spring_pad(x: float, z: float, y: float, wide: bool) -> void:
	var area := Area3D.new()
	area.set_script(load("res://scripts/spring.gd"))
	area.position = Vector3(x, y + 0.7, z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.6 if wide else 2.5, 1.3, 2.5)
	shape.shape = box
	area.add_child(shape)
	var copies := 2 if wide else 1
	var span := 4.4 if wide else 2.3
	var tile := span / float(copies)
	var fit := tile / _JUMP_SIZE.x
	_with_scene(_JUMP_PATH, func(packed: PackedScene) -> void:
		for i in copies:
			var vis := packed.instantiate() as Node3D
			vis.scale = Vector3(fit, fit, fit)
			var side_x := -span * 0.5 + tile * (float(i) + 0.5)
			vis.position = Vector3(side_x, -0.7 + _JUMP_SIZE.y * 0.5 * fit, 0.0)
			vis.set_meta("coil", true)
			_arm_spring(vis)
			_quiet_pad(vis)
			area.add_child(vis)
	)
	add_child(area)


func _high_lane(z_near: float, z_far: float, y: float, amp: float) -> void:
	var span := z_near - z_far
	var steps := 8
	var step := span / float(steps)
	var z1 := z_near
	for i in steps:
		var t := float(i) / float(maxi(steps - 1, 1))
		var cx := sin(t * PI) * amp
		var z0 := z1 - step
		var color := _accent if i % 2 == 0 else _concrete
		_slab(cx - 2.2, cx + 2.2, z0, z1 + 0.55, y, color)
		z1 = z0


func _chute() -> void:
	var base := _floor_y
	if base < 8.0:
		_hint("CLIMB", Vector3(0, base + 2.4, _solid_end - 1.0))
		_easy_ramp(base + 9.0)
	else:
		_hint("CHUTE", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var crown := _floor_y
	var landing_y := base - 7.0
	if base >= 8.0:
		landing_y = maxf(_floor_cut + 1.5, base - _rng.randf_range(9.0, 13.0))
	else:
		landing_y = maxf(_floor_cut + 1.5, base - 6.0)
	if crown - landing_y < 6.0:
		landing_y = crown - 8.0
	var bottom := _icy_chute(crown, landing_y)
	_floor_y = landing_y
	_solid_end = bottom
	_deck(12.0, 2.6)
	_mark_checkpoint()


func _easy_ramp(top: float) -> void:
	var y0 := _floor_y
	var rise := top - y0
	var horizontal := rise / tan(deg_to_rad(22.0))
	var z0 := _solid_end + 0.8
	var z1 := _solid_end - horizontal
	_slope_span(0.0, z0, y0, 0.0, z1, top, 2.55, false, 0.0)
	_solid_end = z1
	_floor_y = top
	travel += horizontal
	_since_cp += horizontal


func _icy_chute(y0: float, y1: float) -> float:
	_hint("CHUTE", Vector3(0, y0 + 2.2, _solid_end - 0.6))
	var drop := y0 - y1
	var horizontal := drop / tan(deg_to_rad(34.0))
	var segments := 4
	var dz := horizontal / float(segments)
	var dy := drop / float(segments)
	var z := _solid_end
	var y := y0
	var sway := 0.8
	for i in segments:
		var x := sin(float(i) * 0.85) * sway
		var next_x := sin(float(i + 1) * 0.85) * sway
		var push := clampf((next_x - x) * 9.0, -7.5, 7.5)
		if i == segments - 1:
			push = 0.0
		var z2 := z - dz
		var y2 := y - dy
		_slope_span(x, z + 0.45, y, x, z2, y2, 0.9, true, push)
		_dress(Vector3(x, y - dy * 0.5 + 0.08, (z + z2) * 0.5), Vector3(0.7, 0.04, 0.22), _hazard)
		z = z2
		y = y2
	travel += horizontal
	_since_cp += horizontal
	_min_floor = minf(_min_floor, y1)
	return z


func _slope_span(x0: float, z0: float, y0: float, x1: float, z1: float, y1: float, half: float, slippery: bool, push: float) -> void:
	var horizontal := absf(z0 - z1)
	var drop := y0 - y1
	var slope_len := sqrt(horizontal * horizontal + drop * drop)
	var body := StaticBody3D.new()
	body.position = Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5 - 0.16, (z0 + z1) * 0.5)
	body.rotation.x = -atan2(drop, maxf(horizontal, 0.001))
	body.collision_layer = 1
	body.collision_mask = 1
	if slippery:
		body.add_to_group("ice")
		body.add_to_group("chute")
		body.set_meta("push", push)
	var mesh_node := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(half * 2.0, 0.32, slope_len + 0.35)
	mesh_node.mesh = box_mesh
	var ice_color := Color(0.78, 0.9, 0.96)
	mesh_node.material_override = _deck_mat(ice_color if slippery else _concrete, 0.28 if slippery else 0.9, 0.15 if slippery else 0.0)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_mesh.size
	col.shape = shape
	body.add_child(mesh_node)
	body.add_child(col)
	add_child(body)


func _boost_gap() -> void:
	_hint("BOOST", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var near := _solid_end
	_deck(7.0, 2.4)
	_boost_at(near - 2.6)
	var takeoff := _solid_end
	_solid_end -= 5.2
	travel += 5.2
	_since_cp += 5.2
	var lip := _solid_end
	if _rng.randf() < 0.5:
		_jump_ring(0.0, takeoff - 2.6, _floor_y + 1.15)
	_landing()
	# The shove holds 22 m/s for 0.62s, about 13.6m. This smaller pad sits
	# just as that speed lets go, so a clean run chains into a second shove.
	var fade_z := (near - 2.6) - 12.8
	if fade_z < lip - 1.4 and fade_z > _solid_end + 2.0:
		_boost_at(fade_z, 0.0, _floor_y, false, 1.8, 0.72)
	if _landing_len >= 10.0:
		_back_pad(lip - 7.2, 2.7)


func _back_pad(z: float, half: float = -1.0) -> void:
	# Reverse pads are fine on open runs. Skip the one that would sit on the lip of a single wall.
	if _ahead == "wall":
		return
	if half < 0.0:
		half = _lane_half if _narrow else _half()
	_boost_at(z, 0.0, _floor_y, true, maxf(2.2, half * 2.0 - 0.25))


func _chain() -> void:
	_hint("CHAIN", Vector3(0, _floor_y + 2.4, _solid_end - 1.0))
	var start := _solid_end
	var step := 12.8
	var pads := 5
	var length := 5.0 + step * float(pads - 1) + 9.0
	_deck(length, 3.2)
	for i in pads:
		_boost_at(start - 4.0 - step * float(i), 0.0, _floor_y, false, 2.05, 0.8)
	_landing()


func _wall_pad(side: int, z: float, face_x: float, surface_y: float) -> void:
	var area := Area3D.new()
	area.set_script(load("res://scripts/boost.gd"))
	area.set_meta("wall", true)
	area.position = Vector3(face_x - float(side) * 0.42, surface_y + 1.45, z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.85, 1.35, 1.15)
	shape.shape = box
	area.add_child(shape)
	var along := 1.15
	var tall := 1.25
	var thick := 0.07
	var lean := float(side)
	_with_scene(_BOOST_PATH, func(packed: PackedScene) -> void:
		var vis := packed.instantiate() as Node3D
		# Local +X is the chevron. Lay that down the wall, and the thin axis out from the face.
		var x_axis := Vector3(0.0, 0.0, -1.0) * (along / _BOOST_SIZE.x)
		var y_axis := Vector3(lean, 0.0, 0.0) * (thick / _BOOST_SIZE.y)
		var z_axis := Vector3(0.0, 1.0, 0.0) * (tall / _BOOST_SIZE.z)
		vis.basis = Basis(x_axis, y_axis, z_axis)
		vis.position = Vector3(lean * 0.36, 0.0, 0.0)
		_quiet_pad(vis)
		area.add_child(vis)
	)
	add_child(area)


func _boost_at(z: float, x: float = 0.0, surface_y: float = -99999.0, backward: bool = false, span: float = -1.0, depth: float = -1.0) -> void:
	var surface := _floor_y if surface_y < -9000.0 else surface_y
	var area := Area3D.new()
	area.set_script(load("res://scripts/boost.gd"))
	area.position = Vector3(x, surface + 0.8, z)
	if backward:
		area.set_meta("back", true)
	else:
		area.add_to_group("boost")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var pad_w := span if span > 0.0 else (1.5 if absf(x) > 0.4 else 3.2)
	var pad_d := depth if depth > 0.0 else (1.15 if backward else 1.35)
	# Reverse pads stay low, so a jump clears them. Forward pads reach up and catch a run.
	if backward:
		box.size = Vector3(pad_w, 0.46, pad_d + 0.1)
		shape.position = Vector3(0, -0.52, 0)
	else:
		box.size = Vector3(pad_w, 1.15, pad_d + 0.2)
		shape.position = Vector3(0, -0.15, 0)
	shape.shape = box
	area.add_child(shape)
	_boost_visual(area, pad_w, pad_d, backward, -0.78)
	add_child(area)


func _shove_at(z: float, x: float, surface_y: float) -> void:
	var area := Area3D.new()
	area.set_script(load("res://scripts/shove.gd"))
	area.position = Vector3(x, surface_y + 0.36, z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.95, 0.5, 1.05)
	shape.shape = box
	area.add_child(shape)
	_boost_visual(area, 0.95, 1.05, false, -0.32)
	add_child(area)


func _jump_ring(x: float, z: float, y: float) -> void:
	var area := Area3D.new()
	area.set_script(load("res://scripts/ring.gd"))
	area.position = Vector3(x, y, z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.7, 1.7, 0.7)
	shape.shape = box
	area.add_child(shape)
	if _kit_on():
		var ring_s := 2.15 / _RING_SIZE.x
		_place_prop(_KIT_RING, Vector3.ZERO, Vector3(ring_s, ring_s, ring_s), 0.0, _RING_POS, _RING_SIZE, "center", area)
		add_child(area)
		return
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.78
	torus.outer_radius = 1.05
	torus.rings = 10
	torus.ring_segments = 20
	mesh.mesh = torus
	mesh.rotation.x = PI * 0.5
	mesh.material_override = _glow(_accent.lightened(0.2))
	area.add_child(mesh)
	add_child(area)


func _boost_visual(parent: Node3D, span: float, depth: float, backward: bool, bottom_y: float) -> void:
	var visual_d := maxf(depth, 1.05)
	var tiles := maxi(1, int(ceil(span / 2.15)))
	var tile_w := span / float(tiles)
	# Chevrons run along the model's +X, so a quarter turn lays them on the run.
	var sx := visual_d / _BOOST_SIZE.x
	var sy := 1.45
	var sz := tile_w / _BOOST_SIZE.z
	_with_scene(_BOOST_PATH, func(packed: PackedScene) -> void:
		for i in tiles:
			var vis := packed.instantiate() as Node3D
			vis.scale = Vector3(sx, sy, sz)
			var x := -span * 0.5 + tile_w * (float(i) + 0.5)
			vis.position = Vector3(x, bottom_y + _BOOST_SIZE.y * 0.5 * sy, 0.0)
			vis.rotation.y = -PI * 0.5 if backward else PI * 0.5
			_quiet_pad(vis)
			parent.add_child(vis)
	)


func _arm_fan(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_inst := node as MeshInstance3D
		var src: Material = mesh_inst.get_active_material(0)
		var mat := ShaderMaterial.new()
		mat.shader = _FAN_SHADER
		if src is BaseMaterial3D and (src as BaseMaterial3D).albedo_texture != null:
			mat.set_shader_parameter("albedo", (src as BaseMaterial3D).albedo_texture)
		mat.set_shader_parameter("spin", 0.0)
		mesh_inst.material_override = mat
		mesh_inst.set_meta("fan_mat", mat)
	for child in node.get_children():
		_arm_fan(child)


func _arm_spring(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_inst := node as MeshInstance3D
		var src: Material = mesh_inst.get_active_material(0)
		var mat := ShaderMaterial.new()
		mat.shader = _SPRING_SHADER
		if src is BaseMaterial3D and (src as BaseMaterial3D).albedo_texture != null:
			mat.set_shader_parameter("albedo", (src as BaseMaterial3D).albedo_texture)
		mat.set_shader_parameter("dip", 0.0)
		mesh_inst.material_override = mat
		mesh_inst.set_meta("spring_mat", mat)
	for child in node.get_children():
		_arm_spring(child)


func _quiet_pad(node: Node) -> void:
	if node is GeometryInstance3D:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children():
		_quiet_pad(child)


func _mover_mesh(body: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.position = pos
	mesh.material_override = _mat(color, 0.55, 0.25)
	body.add_child(mesh)


func _mover_box(body: Node3D, size: Vector3, pos: Vector3, color: Color, bare: bool = false) -> void:
	if not bare:
		var mesh := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = size
		mesh.mesh = box_mesh
		mesh.position = pos
		mesh.material_override = _mat(color, 0.55, 0.25)
		body.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	col.position = pos
	body.add_child(col)


func _hurdle_at(z: float, shift: float, wide: float = 1.7, surface: float = -99999.0) -> void:
	var y := _floor_y if surface < -9000.0 else surface
	_box(Vector3(shift, y + 0.38, z), Vector3(wide, 0.76, 0.48), _hazard, false, 0.0, "", _kit_on())
	if _kit_on():
		var hurdle_s := Vector3(wide / _HURDLE_SIZE.x, 0.78 / _HURDLE_SIZE.y, 0.62 / _HURDLE_SIZE.z)
		_place_prop(_KIT_HURDLE, Vector3(shift, y, z), hurdle_s, 0.0, _HURDLE_POS, _HURDLE_SIZE, "bottom")


func _lane_saw(x: float, z: float, sweep: float, surface: float = -99999.0) -> void:
	var y := _floor_y if surface < -9000.0 else surface
	var saw := AnimatableBody3D.new()
	saw.set_script(load("res://scripts/saw.gd"))
	saw.position = Vector3(x, y + 0.48, z)
	saw.travel = sweep
	saw.period = 1.05
	saw.phase = _rng.randf() * TAU
	var blade := Node3D.new()
	blade.name = "Blade"
	saw.add_child(blade)
	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.42
	disc_mesh.bottom_radius = 0.42
	disc_mesh.height = 0.08
	disc.mesh = disc_mesh
	disc.rotation.x = PI * 0.5
	disc.material_override = _mat(_hazard, 0.35, 0.45)
	blade.add_child(disc)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.05, 0.36, 0.36)
	shape.shape = box
	saw.add_child(shape)
	add_child(saw)


func _bar_at(z: float, surface: float = -99999.0) -> void:
	var saved := _floor_y
	if surface > -9000.0:
		_floor_y = surface
	var min_x := -PATH_HALF
	var max_x := PATH_HALF
	var deck := _deck_span_at(z)
	if not deck.is_empty():
		min_x = float(deck["min_x"])
		max_x = float(deck["max_x"])
	var span := max_x - min_x
	if span < 1.2:
		_floor_y = saved
		return
	var mid_x := (min_x + max_x) * 0.5
	var post_h := 1.85
	var bar := AnimatableBody3D.new()
	bar.set_script(load("res://scripts/bar.gd"))
	bar.position = Vector3(mid_x, _floor_y, z)
	bar.phase = _rng.randf() * TAU
	bar.period = _rng.randf_range(2.15, 2.7)
	_mover_box(bar, Vector3(span - 0.28, 0.32, 0.4), Vector3.ZERO, _hazard, _kit_on())
	if _kit_on():
		var bar_s := Vector3((span - 0.1) / _BAR_SIZE.x, 1.7 / _BAR_SIZE.y, 1.05)
		_place_prop(_KIT_BAR, Vector3(0, -0.56, 0), bar_s, 0.0, _BAR_POS, _BAR_SIZE, "bottom", bar)
	else:
		_box(Vector3(min_x + 0.12, _floor_y + post_h * 0.5, z), Vector3(0.16, post_h, 0.16), _metal)
		_box(Vector3(max_x - 0.12, _floor_y + post_h * 0.5, z), Vector3(0.16, post_h, 0.16), _metal)
	add_child(bar)
	_floor_y = saved


func _deck_span_at(z: float) -> Dictionary:
	var best: Dictionary = {}
	var best_width := -1.0
	for slab in _slabs:
		if absf(float(slab["top"]) - _floor_y) > 0.25:
			continue
		if z < float(slab["min_z"]) + 0.3 or z > float(slab["max_z"]) - 0.3:
			continue
		var width := float(slab["max_x"]) - float(slab["min_x"])
		if width > best_width:
			best_width = width
			best = slab
	return best


func _mark_checkpoint() -> void:
	var feet := _checkpoint_feet()
	if absf(feet.z - _last_cp_z) < _cp_min:
		_since_cp = 0.0
		return
	_cp += 1
	_since_cp = 0.0
	_last_cp_z = feet.z
	var area := Area3D.new()
	area.set_script(load("res://scripts/checkpoint.gd"))
	area.index = _cp
	area.spawn = feet
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var span := 8.0
	var under := _slab_at_end()
	if not under.is_empty():
		span = maxf(span, float(under["max_x"]) - float(under["min_x"]) + 0.8)
	box.size = Vector3(span, 10, 3.2)
	shape.shape = box
	area.add_child(shape)
	area.position = feet + Vector3(0, 4.2, 0)
	add_child(area)
	_note_beacons(feet)


func _finish_line() -> void:
	var z := _solid_end + 6.0
	_finish_z = z
	_finish_y = _floor_y
	var apron := 0.952 * _GANTRY_SCALE + 0.4
	_slab(-apron, apron, z - 1.6, z + 1.4, _floor_y, _concrete)
	var area := Area3D.new()
	area.set_script(load("res://scripts/finish_line.gd"))
	# The near face meets the front of the arch, so the pass counts as you reach it.
	var front := z + _GANTRY_FRONT * _GANTRY_SCALE
	area.position = Vector3(0, _floor_y + 2.0, front - 0.22)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(8, 8, 0.45)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	_with_scene(_GANTRY_PATH, _spawn_gantry)


func _note_beacons(feet: Vector3) -> void:
	var half_w := _POST_HALF * _POST_SCALE
	var deck_y := feet.y - 0.08
	var y := deck_y - _POST_BOTTOM * _POST_SCALE
	var want := _lane_half + half_w + 0.12
	var left := feet.x - want
	var right := feet.x + want
	var slab := _slab_at_end()
	if not slab.is_empty():
		var lo := float(slab["min_x"]) + half_w + 0.06
		var hi := float(slab["max_x"]) - half_w - 0.06
		if left < lo:
			left = lo
		if right > hi:
			right = hi
	if right - left < 1.4:
		return
	_beacon_at.append(Vector3(left, y, feet.z))
	_beacon_flip.append(true)
	_beacon_at.append(Vector3(right, y, feet.z))
	_beacon_flip.append(false)


func _place_beacons() -> void:
	if _beacon_at.is_empty():
		return
	_with_scene(_POST_PATH, _spawn_beacons)


func _spawn_beacons(packed: PackedScene) -> void:
	for i in _beacon_at.size():
		var post := packed.instantiate() as Node3D
		post.position = _beacon_at[i]
		var side := -_POST_SCALE if _beacon_flip[i] else _POST_SCALE
		post.scale = Vector3(side, _POST_SCALE, _POST_SCALE)
		_fit_prop(post, 110.0)
		post.name = "CheckpointBeacon"
		add_child(post)


func _spawn_gantry(packed: PackedScene) -> void:
	var gate := packed.instantiate() as Node3D
	var y := _finish_y - _GANTRY_BOTTOM * _GANTRY_SCALE
	gate.position = Vector3(0.0, y, _finish_z)
	gate.scale = Vector3(_GANTRY_SCALE, _GANTRY_SCALE, _GANTRY_SCALE)
	_fit_prop(gate, 180.0)
	gate.name = "FinishGantry"
	add_child(gate)


func _fit_prop(root: Node, reach: float) -> void:
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	for item in meshes:
		var mesh := item as MeshInstance3D
		mesh.visibility_range_end = reach
		mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF


func _kit_on() -> bool:
	return map_id == "annex"


func _place_prop(path: String, at: Vector3, scale: Vector3, yaw: float, native_pos: Vector3, native_size: Vector3, anchor: String, parent: Node = null) -> void:
	_with_scene(path, func(packed: PackedScene) -> void:
		var node := packed.instantiate() as Node3D
		node.scale = scale
		node.rotation.y = yaw
		var pivot := native_pos + native_size * 0.5
		if anchor == "bottom":
			pivot.y = native_pos.y
		elif anchor == "top":
			pivot.y = native_pos.y + native_size.y
		var spun := Basis(Vector3.UP, yaw)
		var shifted := Vector3(pivot.x * scale.x, pivot.y * scale.y, pivot.z * scale.z)
		node.position = at - spun * shifted
		_fit_prop(node, 220.0)
		if path == _KIT_DUCT:
			node.add_to_group("kit_duct")
		elif path == _KIT_WALL:
			node.add_to_group("kit_wall")
		elif path == _KIT_BELT:
			node.add_to_group("kit_belt")
		elif path == _KIT_TOWER:
			node.add_to_group("kit_tower")
		elif path == _KIT_DECK:
			node.add_to_group("kit_deck")
		elif path == _KIT_EDGE:
			node.add_to_group("kit_edge")
		elif path == _KIT_PLANK:
			node.add_to_group("kit_plank")
		elif path == _KIT_HURDLE:
			node.add_to_group("kit_hurdle")
		elif path == _KIT_CAP:
			node.add_to_group("kit_cap")
		var host: Node = self if parent == null else parent
		host.add_child(node)
	)


func _scale_for_foot(native_size: Vector3, world_x: float, world_z: float, yaw: float, height_scale: float) -> Vector3:
	var turned := absf(wrapf(yaw, -PI, PI)) > 0.7 and absf(wrapf(yaw, -PI, PI)) < 2.45
	if turned:
		return Vector3(world_z / native_size.x, height_scale, world_x / native_size.z)
	return Vector3(world_x / native_size.x, height_scale, world_z / native_size.z)


func _pave_deck(min_x: float, max_x: float, min_z: float, max_z: float, top: float) -> void:
	_pave_grid(_KIT_DECK, _DECK_POS, _DECK_SIZE, min_x, max_x, min_z, max_z, top, 0.0, 4.0, 4.0, 1.35)


func _pave_belt(min_x: float, max_x: float, min_z: float, max_z: float, top: float, push: float) -> void:
	var yaw := PI * 0.5 if push >= 0.0 else -PI * 0.5
	_pave_grid(_KIT_BELT, _BELT_POS, _BELT_SIZE, min_x, max_x, min_z, max_z, top, yaw, 2.05, 2.05, 1.15)


func _pave_grid(path: String, native_pos: Vector3, native_size: Vector3, min_x: float, max_x: float, min_z: float, max_z: float, surface_y: float, yaw: float, want_x: float, want_z: float, height_scale: float) -> void:
	var span_x := max_x - min_x
	var span_z := max_z - min_z
	if span_x < 0.4 or span_z < 0.4:
		return
	var nx := maxi(1, int(round(span_x / want_x)))
	var nz := maxi(1, int(round(span_z / want_z)))
	var tile_x := span_x / float(nx)
	var tile_z := span_z / float(nz)
	var scale := _scale_for_foot(native_size, tile_x, tile_z, yaw, height_scale)
	for ix in nx:
		for iz in nz:
			var cx := min_x + tile_x * (float(ix) + 0.5)
			var cz := min_z + tile_z * (float(iz) + 0.5)
			_place_prop(path, Vector3(cx, surface_y, cz), scale, yaw, native_pos, native_size, "top")


func _pave_edges(min_x: float, max_x: float, min_z: float, max_z: float, top: float) -> void:
	var span_z := max_z - min_z
	var span_x := max_x - min_x
	if span_z < 2.4 or span_x < 1.1:
		return
	_pave_trim(min_x, min_z, max_z, top, -1.0)
	_pave_trim(max_x, min_z, max_z, top, 1.0)


func _pave_trim(edge_x: float, min_z: float, max_z: float, top: float, outward: float) -> void:
	var span := max_z - min_z
	var count := maxi(1, int(round(span / 4.0)))
	var tile := span / float(count)
	var yaw := outward * PI * 0.5
	var scale := _scale_for_foot(_EDGE_SIZE, 0.42, tile, yaw, 1.55)
	for i in count:
		var cz := min_z + tile * (float(i) + 0.5)
		_place_prop(_KIT_EDGE, Vector3(edge_x, top, cz), scale, yaw, _EDGE_POS, _EDGE_SIZE, "top")


func _pave_plank(min_x: float, max_x: float, min_z: float, max_z: float, top: float) -> void:
	var span_x := max_x - min_x
	var span_z := max_z - min_z
	var yaw := PI * 0.5
	var scale := _scale_for_foot(_PLANK_SIZE, span_x, span_z, yaw, span_z / _PLANK_SIZE.x * 0.55)
	_place_prop(_KIT_PLANK, Vector3((min_x + max_x) * 0.5, top, (min_z + max_z) * 0.5), scale, yaw, _PLANK_POS, _PLANK_SIZE, "top")


func _pave_duct(min_x: float, max_x: float, min_z: float, max_z: float, top: float) -> void:
	var span_z := max_z - min_z
	var count := maxi(1, int(round(span_z / 3.6)))
	var tile := span_z / float(count)
	var scale := Vector3(4.7 / _DUCT_SIZE.x, 1.55 / _DUCT_SIZE.y, tile / _DUCT_SIZE.z)
	var cx := (min_x + max_x) * 0.5
	for i in count:
		var cz := min_z + tile * (float(i) + 0.5)
		_place_prop(_KIT_DUCT, Vector3(cx, top - 0.06, cz), scale, 0.0, _DUCT_POS, _DUCT_SIZE, "bottom")


func _pave_run_wall(center: Vector3, size: Vector3, side: float) -> void:
	var normal := -side
	var yaw := normal * PI * 0.5
	var nz := maxi(1, int(round(size.z / 4.2)))
	var ny := maxi(1, int(round(size.y / 6.0)))
	var tile_z := size.z / float(nz)
	var tile_y := size.y / float(ny)
	var sx := tile_z / _WALL_SIZE.x
	var sy := tile_y / _WALL_SIZE.y
	var sz := 1.45
	var thick := _WALL_SIZE.z * sz
	var face_x := center.x + normal * size.x * 0.5
	var panel_x := face_x - normal * thick * 0.5
	var z0 := center.z - size.z * 0.5
	var y0 := center.y - size.y * 0.5
	for iz in nz:
		for iy in ny:
			var cz := z0 + tile_z * (float(iz) + 0.5)
			var cy := y0 + tile_y * (float(iy) + 0.5)
			_place_prop(_KIT_WALL, Vector3(panel_x, cy, cz), Vector3(sx, sy, sz), yaw, _WALL_POS, _WALL_SIZE, "center")


func _pave_fascia(center: Vector3, size: Vector3) -> void:
	var nx := maxi(1, int(round(size.x / 4.2)))
	var ny := maxi(1, int(round(maxf(size.y, 0.4) / 6.0)))
	var tile_x := size.x / float(nx)
	var tile_y := size.y / float(ny)
	var sx := tile_x / _WALL_SIZE.x
	var sy := tile_y / _WALL_SIZE.y
	var sz := 1.2
	var thick := _WALL_SIZE.z * sz
	var face_z := center.z + size.z * 0.5
	var panel_z := face_z - thick * 0.5
	var x0 := center.x - size.x * 0.5
	var y0 := center.y - size.y * 0.5
	for ix in nx:
		for iy in ny:
			var cx := x0 + tile_x * (float(ix) + 0.5)
			var cy := y0 + tile_y * (float(iy) + 0.5)
			_place_prop(_KIT_WALL, Vector3(cx, cy, panel_z), Vector3(sx, sy, sz), 0.0, _WALL_POS, _WALL_SIZE, "center")


func _pave_rail(x: float, y: float, min_z: float, max_z: float, outward: float, height: float) -> void:
	var span := max_z - min_z
	var count := maxi(1, int(round(span / 4.0)))
	var tile := span / float(count)
	var yaw := outward * PI * 0.5
	var scale := _scale_for_foot(_RAIL_SIZE, 0.62, tile, yaw, height / _RAIL_SIZE.y)
	for i in count:
		var cz := min_z + tile * (float(i) + 0.5)
		_place_prop(_KIT_RAIL, Vector3(x, y, cz), scale, yaw, _RAIL_POS, _RAIL_SIZE, "center")


func _hint(text: String, pos: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 64
	label.modulate = Color(0.96, 0.96, 0.96)
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 10
	label.outline_modulate = Color(0.05, 0.05, 0.05)
	add_child(label)


func spawn_drone(at: Vector3, focus: Vector3, bob_phase: float = 0.0) -> Node3D:
	var packed := _packed_scene(_DRONE_PATH)
	if packed == null:
		packed = load(_DRONE_PATH) as PackedScene
	var drone := packed.instantiate() as Node3D
	drone.set_script(_DRONE_SCRIPT)
	drone.position = at
	drone.scale = Vector3(1.85, 1.85, 1.85)
	add_child(drone)
	if drone.has_method("arm"):
		drone.arm(focus, bob_phase)
	return drone


func place_opening_drones() -> void:
	var pack := Vector3(0.0, 1.35, 6.3)
	var spots: Array[Vector3] = [
		Vector3(2.5, 2.2, 0.8),
		Vector3(-2.7, 3.35, 0.2),
		Vector3(-4.5, 2.15, 5.5),
		Vector3(4.6, 2.55, 6.9),
		Vector3(0.6, 4.15, 11.4),
	]
	for i in spots.size():
		spawn_drone(spots[i], pack, float(i) * 1.3)


func _place_drones() -> void:
	var z := -18.0
	var n := 0
	while z > _solid_end + 18.0 and n < 80:
		var side := -1.0 if n % 2 == 0 else 1.0
		var deck_y := _deck_height_at(z)
		var at := Vector3(side * 6.2, deck_y + 3.15, z)
		var focus := Vector3(0.0, deck_y + 1.4, z)
		spawn_drone(at, focus, float(n) * 0.9)
		z -= 36.0
		n += 1


func _place_screens() -> void:
	if _preview:
		return
	_with_scene(_SCREEN_PATH, _spawn_screen_set)


func _spawn_screen_set(packed: PackedScene) -> void:
	var pack := Vector3(0.0, 1.8, 7.2)
	var staging: Array[Vector3] = [
		Vector3(-12.0, 5.5, 2.4),
		Vector3(-12.4, 6.3, 11.2),
		Vector3(12.0, 5.5, 2.4),
		Vector3(12.4, 6.3, 11.2),
	]
	for i in staging.size():
		_spawn_screen(packed, staging[i], pack, 4.7, float(i) * 0.8)
	var fz := _solid_end + 6.0
	var fy := _floor_y
	var finish_look := Vector3(0.0, fy + 2.0, fz + 14.0)
	_spawn_screen(packed, Vector3(-8.2, fy + 5.8, fz), finish_look, 5.0, 1.4)
	_spawn_screen(packed, Vector3(8.2, fy + 5.8, fz), finish_look, 5.0, 2.2)
	var span := -_solid_end
	var step := clampf(span / 5.0, 58.0, 100.0)
	var z := -36.0
	var n := 0
	while z > _solid_end + 28.0 and n < 4:
		var side := -1.0 if n % 2 == 0 else 1.0
		var deck_y := _deck_height_at(z)
		var at := Vector3(side * 9.4, deck_y + 6.2, z)
		var viewers := Vector3(side * 1.4, deck_y + 2.1, z + 8.0)
		_spawn_screen(packed, at, viewers, 3.9, float(n) * 1.1)
		z -= step
		n += 1


func _spawn_screen(packed: PackedScene, at: Vector3, viewers: Vector3, scale: float, bob: float) -> void:
	var screen := packed.instantiate() as Node3D
	screen.set_script(_SCREEN_SCRIPT)
	screen.position = at
	screen.scale = Vector3(scale, scale, scale)
	add_child(screen)
	if screen.has_method("arm"):
		screen.arm(viewers, bob)


func _note_deck() -> void:
	_deck_z.append(_solid_end)
	_deck_y.append(_floor_y)


func height_at(z: float) -> float:
	return _deck_height_at(z)


func item_marks() -> Array:
	var marks: Array = []
	var z := -24.0
	while z > -travel + 18.0:
		var spot := _roof_at(z)
		if not spot.is_empty():
			marks.append(Vector3(float(spot["x"]), float(spot["y"]) + 1.15, float(spot["z"])))
		z -= 64.0
	return marks


func _roof_at(z: float) -> Dictionary:
	var found := false
	var best_top := -9999.0
	var x := 0.0
	for slab in _slabs:
		if z < float(slab["min_z"]) + 1.4 or z > float(slab["max_z"]) - 1.4:
			continue
		var top := float(slab["top"])
		if found and top < best_top:
			continue
		found = true
		best_top = top
		var min_x := float(slab["min_x"])
		var max_x := float(slab["max_x"])
		x = clampf(0.0, min_x + 0.7, max_x - 0.7)
	if not found:
		return {}
	return {"x": x, "y": best_top, "z": z}


func _deck_height_at(z: float) -> float:
	if _deck_z.is_empty():
		return 0.0
	if z >= _deck_z[0]:
		return _deck_y[0]
	var last := _deck_z.size() - 1
	if z <= _deck_z[last]:
		return _deck_y[last]
	for i in last:
		var z0 := _deck_z[i]
		var z1 := _deck_z[i + 1]
		if z <= z0 and z >= z1:
			var span := maxf(0.001, z0 - z1)
			return lerpf(_deck_y[i], _deck_y[i + 1], (z0 - z) / span)
	return _deck_y[last]


func _character() -> void:
	_landmark()
	var z := -16.0
	var n := 0
	var cap := 5 if _preview else 64
	while z > _solid_end + 8.0 and n < cap:
		_motif(z, _deck_height_at(z), n)
		z -= _rng.randf_range(16.0, 22.0)
		n += 1
	if map_id == "overpass" or map_id == "clockwork":
		var dz := -4.0
		var count := 0
		var limit := 10 if _preview else 80
		while dz > _solid_end and count < limit:
			_dress(Vector3(0, _deck_height_at(dz) + 0.04, dz), Vector3(0.16, 0.04, 1.5), Color(0.95, 0.95, 0.92))
			dz -= 8.0
			count += 1


func _landmark() -> void:
	var z := -12.0
	var y := _deck_height_at(z)
	match map_id:
		"annex":
			var tower_s := Vector3(2.6 / _TOWER_SIZE.x, 6.4 / _TOWER_SIZE.y, 2.6 / _TOWER_SIZE.z)
			_place_prop(_KIT_TOWER, Vector3(6.4, y, z), tower_s, 0.0, _TOWER_POS, _TOWER_SIZE, "bottom")
			_clothesline(z + 4.0, y)
		"kiln":
			_cyl(Vector3(-6.2, y + 1.6, z), 1.5, 3.2, _dark)
			_cyl(Vector3(-6.2, y + 3.6, z), 1.15, 1.1, _concrete)
			_cyl(Vector3(-6.2, y + 4.4, z), 0.45, 0.7, _accent, true)
		"flue":
			_cyl(Vector3(-6.0, y + 3.4, z), 0.55, 6.8, _metal)
			_cyl(Vector3(-6.0, y + 6.6, z), 0.8, 0.3, _hazard)
		"culvert":
			_pipe(z, y, 2.35)
		"highline", "span", "gale":
			_dress(Vector3(7.2, y + 6.0, z), Vector3(0.55, 12.0, 0.55), _metal)
			_dress(Vector3(-7.2, y + 6.0, z - 14.0), Vector3(0.55, 12.0, 0.55), _metal)
			_beam(Vector3(7.2, y + 11.2, z), Vector3(-7.2, y + 11.2, z - 14.0), 0.12, _accent)
			_beam(Vector3(7.2, y + 8.0, z), Vector3(2.4, y + 0.4, z - 6.0), 0.08, _metal)
		"switchback", "razor":
			for step in 3:
				var sy := y + 1.2 + float(step) * 1.5
				_dress(Vector3(5.6, sy, z - float(step) * 1.2), Vector3(1.3, 0.08, 1.5), _metal)
				_dress(Vector3(6.1, sy - 0.7, z - float(step) * 1.2), Vector3(0.08, 1.4, 0.08), _dark)
		"overpass":
			_gantry(z, y, "LANE")
		"clockwork":
			_gear(Vector3(5.8, y + 1.5, z))
			_gantry(z - 8.0, _deck_height_at(z - 8.0), "")
		"gallery":
			_frame(z, y, 2.05, 3.15, true)
		"well":
			_frame(z, y, 1.7, 2.7, false)
		"spire", "spireline":
			_dress(Vector3(8.0, y + 11.0, z), Vector3(1.4, 22.0, 1.4), _dark)
			_dress(Vector3(8.0, y + 23.0, z), Vector3(0.45, 6.0, 0.45), _accent)
			_glow_dress(Vector3(8.0, y + 26.2, z), Vector3(0.16, 1.4, 0.16), _accent)
		"canal", "glaze":
			_dress(Vector3(0, y - 1.7, z - 6.0), Vector3(18.0, 0.2, 28.0), Color(0.8, 0.93, 0.98))
		"market":
			_lanterns(z, y, true)
		"blackout":
			_lanterns(z, y, false)
		"needle":
			for side in [-1.0, 1.0]:
				_dress(Vector3(side * 2.3, y + 3.2, z), Vector3(0.07, 6.4, 0.07), _concrete)


func _motif(z: float, y: float, n: int) -> void:
	var side := -1.0 if n % 2 == 0 else 1.0
	match map_id:
		"annex":
			var cap_s := Vector3(0.95 / _CAP_SIZE.x, 1.65 / _CAP_SIZE.y, 0.95 / _CAP_SIZE.z)
			_place_prop(_KIT_CAP, Vector3(side * 3.35, y, z), cap_s, 0.0, _CAP_POS, _CAP_SIZE, "bottom")
		"kiln":
			_arch(z, y, true)
		"flue":
			_arch(z, y, false)
		"culvert":
			_pipe(z, y, 2.05)
		"highline", "span", "gale":
			_dress(Vector3(side * 6.4, y + 4.5, z), Vector3(0.35, 9.0, 0.35), _metal)
			_beam(Vector3(side * 6.4, y + 8.6, z), Vector3(side * 2.3, y + 0.3, z - 5.0), 0.07, _dark)
		"switchback", "razor":
			_dress(Vector3(0, y + 0.04, z), Vector3(0.55, 0.04, 0.14), _hazard)
			_dress(Vector3(-0.28, y + 0.04, z + 0.2), Vector3(0.32, 0.04, 0.1), _hazard)
			_dress(Vector3(0.28, y + 0.04, z + 0.2), Vector3(0.32, 0.04, 0.1), _hazard)
			_dress(Vector3(side * 3.4, y + 1.3, z), Vector3(1.05, 0.08, 1.3), _metal)
		"overpass", "clockwork":
			_dress(Vector3(side * 3.15, y + 0.45, z), Vector3(0.12, 0.9, 0.12), _hazard)
			_dress(Vector3(side * 3.15, y + 0.95, z), Vector3(0.45, 0.08, 0.12), _metal)
		"gallery":
			_frame(z, y, 1.55, 2.55, true)
		"well":
			_frame(z, y, 1.4, 2.3, false)
		"spire", "spireline":
			_halo(z, y)
		"canal", "glaze":
			_dress(Vector3(0, y - 1.55, z), Vector3(16.0, 0.16, 10.0), Color(0.82, 0.94, 0.98))
			_dress(Vector3(side * 3.2, y + 0.55, z), Vector3(0.2, 1.1, 0.2), _dark)
			_dress(Vector3(side * 3.2, y + 1.15, z), Vector3(0.32, 0.1, 0.32), _accent)
		"market":
			_lanterns(z, y, true)
		"blackout":
			_lanterns(z, y, false)
		"needle":
			_dress(Vector3(side * 2.15, y + 2.4, z), Vector3(0.06, 4.8, 0.06), _concrete)


func _clothesline(z: float, y: float) -> void:
	if _kit_on():
		var line_s := Vector3(6.4 / _LINE_SIZE.x, 2.35 / _LINE_SIZE.y, 1.35)
		_place_prop(_KIT_LINE, Vector3(0, y + 2.05, z), line_s, 0.0, _LINE_POS, _LINE_SIZE, "bottom")
		return
	_dress(Vector3(0, y + 3.05, z), Vector3(5.2, 0.04, 0.04), _hazard)
	for i in 3:
		var sheet := Node3D.new()
		sheet.set_script(load("res://scripts/prop.gd"))
		sheet.position = Vector3(lerpf(-1.3, 1.3, float(i) / 2.0), y + 2.85, z)
		sheet.sway = 0.1
		sheet.phase = float(i) * 1.2
		var cloth := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.7, 0.85, 0.04)
		cloth.mesh = box
		cloth.position = Vector3(0, -0.45, 0)
		var tint := _concrete if i != 1 else _accent
		cloth.material_override = _mat(tint, 0.8, 0.0)
		sheet.add_child(cloth)
		add_child(sheet)


func _arch(z: float, y: float, coal: bool) -> void:
	_dress(Vector3(-2.45, y + 1.35, z), Vector3(0.32, 2.7, 0.32), _dark)
	_dress(Vector3(2.45, y + 1.35, z), Vector3(0.32, 2.7, 0.32), _dark)
	_dress(Vector3(0, y + 2.8, z), Vector3(5.2, 0.32, 0.36), _concrete)
	if coal:
		_glow_dress(Vector3(0, y + 0.05, z), Vector3(0.42, 0.05, 2.6), _accent)


func _pipe(z: float, y: float, radius: float) -> void:
	var center := Vector3(0, y + 1.7, z)
	for i in 8:
		var ang := float(i) * TAU / 8.0
		var pos := center + Vector3(cos(ang) * radius, sin(ang) * radius, 0)
		_dress(pos, Vector3(0.34, 0.62, 0.34), _metal)


func _gantry(z: float, y: float, word: String) -> void:
	_dress(Vector3(-3.3, y + 1.8, z), Vector3(0.28, 3.6, 0.28), _metal)
	_dress(Vector3(3.3, y + 1.8, z), Vector3(0.28, 3.6, 0.28), _metal)
	_dress(Vector3(0, y + 3.7, z), Vector3(7.0, 0.28, 0.34), _dark)
	_dress(Vector3(0, y + 3.15, z), Vector3(3.4, 0.9, 0.12), _accent)
	if word == "":
		return
	var label := Label3D.new()
	label.text = word
	label.font_size = 72
	label.pixel_size = 0.011
	label.position = Vector3(0, y + 3.15, z + 0.1)
	label.rotation.y = PI
	label.modulate = _hazard
	label.outline_size = 6
	add_child(label)


func _frame(z: float, y: float, half: float, tall: float, gilded: bool) -> void:
	var color := _accent if gilded else _dark
	_dress(Vector3(-half, y + tall * 0.5, z), Vector3(0.16, tall, 0.16), color)
	_dress(Vector3(half, y + tall * 0.5, z), Vector3(0.16, tall, 0.16), color)
	_dress(Vector3(0, y + tall, z), Vector3(half * 2.0 + 0.16, 0.16, 0.16), color)
	_dress(Vector3(0, y + 0.08, z), Vector3(half * 2.0 + 0.16, 0.08, 0.16), color)


func _halo(z: float, y: float) -> void:
	for i in 6:
		var ang := float(i) * TAU / 6.0
		var pos := Vector3(cos(ang) * 1.7, y + 3.35, z + sin(ang) * 1.7)
		_glow_dress(pos, Vector3(0.85, 0.08, 0.22), _accent)


func _lanterns(z: float, y: float, pink: bool) -> void:
	_dress(Vector3(0, y + 3.2, z), Vector3(5.4, 0.05, 0.05), _metal)
	var glow := _accent if pink else _hazard
	for i in 4:
		var lamp := Node3D.new()
		lamp.set_script(load("res://scripts/prop.gd"))
		lamp.position = Vector3(lerpf(-1.8, 1.8, float(i) / 3.0), y + 3.15, z)
		lamp.sway = 0.14
		lamp.phase = float(i) * 0.8
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.28, 0.4, 0.28)
		mesh.mesh = box
		mesh.position = Vector3(0, -0.32, 0)
		mesh.material_override = _glow(glow)
		lamp.add_child(mesh)
		add_child(lamp)


func _gear(center: Vector3) -> void:
	var rig := Node3D.new()
	rig.set_script(load("res://scripts/prop.gd"))
	rig.position = center
	rig.spin_y = 0.5
	var disc := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.25
	cyl.bottom_radius = 1.25
	cyl.height = 0.16
	disc.mesh = cyl
	disc.material_override = _mat(_accent, 0.4, 0.55)
	rig.add_child(disc)
	for i in 8:
		var tooth := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.26, 0.2, 0.34)
		tooth.mesh = box
		var ang := float(i) * TAU / 8.0
		tooth.position = Vector3(cos(ang) * 1.4, 0, sin(ang) * 1.4)
		tooth.rotation.y = -ang
		tooth.material_override = _mat(_metal, 0.45, 0.4)
		rig.add_child(tooth)
	add_child(rig)
	# The disc is a flat cylinder, so spinning it does not move the solid.
	_plant_cyl(center, 1.35, 0.24)


func _beam(a: Vector3, b: Vector3, thick: float, color: Color) -> void:
	var span := a.distance_to(b)
	if span < 0.2:
		return
	var dir := (b - a) / span
	var up := Vector3.UP
	if absf(dir.dot(up)) > 0.95:
		up = Vector3.RIGHT
	var side := up.cross(dir).normalized()
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(thick, thick, span)
	mesh.mesh = box
	mesh.material_override = _mat(color, 0.55, 0.25)
	# Thin braces kiss the deck. A solid one would clip the racing line.
	if thick < 0.1:
		mesh.position = (a + b) * 0.5
		mesh.basis = Basis(side, dir.cross(side).normalized(), dir)
		add_child(mesh)
		return
	var body := StaticBody3D.new()
	body.position = (a + b) * 0.5
	body.basis = Basis(side, dir.cross(side).normalized(), dir)
	body.collision_layer = 1
	body.collision_mask = 1
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(thick, thick, span)
	col.shape = shape
	body.add_child(mesh)
	body.add_child(col)
	add_child(body)


func _cyl(center: Vector3, radius: float, height: float, color: Color, glow: bool = false) -> void:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius * 0.92
	cyl.height = height
	mesh.mesh = cyl
	mesh.material_override = _glow(color) if glow else _mat(color, 0.75, 0.05)
	var hit_h := height if height >= 0.2 else 0.24
	var body := StaticBody3D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	mesh.position = Vector3.ZERO
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = hit_h
	col.shape = shape
	col.position = Vector3(0, (height - hit_h) * 0.5, 0)
	body.add_child(mesh)
	body.add_child(col)
	add_child(body)


func _glow_dress(center: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = center
	mesh.material_override = _glow(color)
	add_child(mesh)


func _sky_h() -> Vector2:
	match map_id:
		"highline", "span", "gale":
			return Vector2(48.0, 96.0)
		"spire", "spireline":
			return Vector2(36.0, 80.0)
		"overpass", "clockwork":
			return Vector2(6.0, 16.0)
		"culvert", "canal", "glaze":
			return Vector2(8.0, 18.0)
		"switchback", "razor":
			return Vector2(22.0, 40.0)
		"kiln", "flue":
			return Vector2(12.0, 26.0)
		"annex":
			return Vector2(9.0, 20.0)
		"gallery", "well":
			return Vector2(16.0, 30.0)
		"market", "blackout":
			return Vector2(8.0, 18.0)
		_:
			return Vector2(28.0, 62.0)


func _sky_x() -> Vector2:
	match map_id:
		"switchback", "razor", "market", "blackout":
			return Vector2(24.0, 38.0)
		"highline", "span", "gale":
			return Vector2(50.0, 82.0)
		"culvert", "canal", "glaze":
			return Vector2(30.0, 46.0)
		_:
			return Vector2(36.0, 64.0)


func _city_scale() -> float:
	match map_id:
		"overpass", "clockwork":
			return 0.38
		"culvert", "canal", "glaze":
			return 0.6
		"annex", "kiln", "flue":
			return 0.72
		"highline", "span", "spire", "spireline", "gale":
			return 1.4
		"switchback", "razor":
			return 1.15
		_:
			return 1.0


func _city_close() -> float:
	match map_id:
		"switchback", "razor", "market", "blackout":
			return 0.7
		"highline", "span", "gale":
			return 1.3
		_:
			return 1.0


func _skyline() -> void:
	if map_id == "annex":
		return
	var street_y := _min_floor - 28.0
	var z := 40.0
	var i := 0
	var cap := 3 if _preview else 100000
	var heights := _sky_h()
	var reach := _sky_x()
	while z > _solid_end - 36.0 and i < cap:
		var side := -1.0 if i % 2 == 0 else 1.0
		var w := _rng.randf_range(7.0, 13.0)
		var d := _rng.randf_range(7.0, 14.0)
		if map_id == "overpass" or map_id == "clockwork":
			w = _rng.randf_range(16.0, 26.0)
			d = _rng.randf_range(20.0, 34.0)
		elif map_id == "highline" or map_id == "span" or map_id == "spire" or map_id == "spireline":
			w = _rng.randf_range(3.6, 6.4)
		var h := _rng.randf_range(heights.x, heights.y)
		var x := side * _rng.randf_range(reach.x, reach.y)
		var color := _cloud_hi if i % 2 == 0 else _cloud
		_city_box(Vector3(x, street_y + h * 0.5, z), Vector3(w, h, d), color)
		_city_box(Vector3(x, street_y + h + 0.2, z), Vector3(w + 0.8, 0.35, d + 0.8), _sea)
		if _rng.randf() < 0.55:
			_city_box(Vector3(x, street_y + h + 2.4, z), Vector3(0.28, 4.6, 0.28), _win, true)
		_facade(Vector3(x, street_y + h * 0.5, z), Vector3(w, h, d), side, 4)
		z -= _rng.randf_range(34.0, 52.0)
		i += 1
	if map_id == "spire" or map_id == "spireline":
		_city_box(Vector3(20.0, street_y + 42.0, -18.0), Vector3(5.2, 84.0, 5.2), _cloud_hi)
		_city_box(Vector3(20.0, street_y + 88.0, -18.0), Vector3(1.6, 12.0, 1.6), _accent)
		_city_box(Vector3(20.0, street_y + 96.0, -18.0), Vector3(0.22, 8.0, 0.22), _win, true)


func _void_floor() -> void:
	var depth := maxf(140.0, travel + 90.0)
	var width := 320.0
	var street_y := _min_floor - 28.0
	var center_z := -travel * 0.5 + 8.0
	var mesh_node := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(width, depth)
	mesh_node.mesh = mesh
	mesh_node.position = Vector3(0, street_y, center_z)
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_node.material_override = _flat(_sea)
	add_child(mesh_node)
	_city_begin(street_y)


func _city_begin(street_y: float) -> void:
	_city_y = street_y
	var depth := maxf(140.0, travel + 90.0)
	var center_z := -travel * 0.5 + 8.0
	_city_box(Vector3(0.0, street_y + 0.04, center_z), Vector3(8.4, 0.08, depth * 0.96), _road)
	for side_n in [-1.0, 1.0]:
		var side := float(side_n)
		_city_box(Vector3(side * 24.0, street_y + 0.04, center_z), Vector3(5.5, 0.08, depth * 0.94), _road)
	_lane_dashes(street_y)
	_city_z = 26.0
	_city_i = 0
	_city_cap = 4 if _preview else 100000
	_city_span = maxf(1.0, _city_z - (_solid_end - 16.0))
	_city_on = true


func _lane_dashes(street_y: float) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.28, 0.06, 2.4)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	var spots: Array[Transform3D] = []
	var dash := 18.0
	while dash > _solid_end - 12.0:
		spots.append(Transform3D(Basis(), Vector3(0.0, street_y + 0.12, dash)))
		dash -= 8.0
	multi.instance_count = spots.size()
	for i in spots.size():
		multi.set_instance_transform(i, spots[i])
	var node := MultiMeshInstance3D.new()
	node.multimesh = multi
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.material_override = _flat(_lane)
	add_child(node)


func _city_frac() -> float:
	return clampf((_city_span - (_city_z - (_solid_end - 16.0))) / _city_span, 0.0, 1.0)


func _city_more() -> bool:
	if not _city_on:
		return false
	if _city_z <= _solid_end - 16.0 or _city_i >= _city_cap:
		_city_on = false
		return false
	var street_y := _city_y
	var z := _city_z
	var i := _city_i
	var bd := _rng.randf_range(5.6, 8.2)
	if i % 4 == 0:
		_city_box(Vector3(0.0, street_y + 0.05, z), Vector3(78.0, 0.06, 5.4), _road)
	if map_id == "annex":
		var span := _booston_pair(z, street_y, i)
		if i % 2 == 0:
			_lamp(-7.4 if i % 4 == 0 else 7.4, z, street_y)
		_city_z = z - span
		_city_i = i + 1
		return true
	var tower_side := -1.0 if i % 2 == 0 else 1.0
	for side_n in [-1.0, 1.0]:
		var side := float(side_n)
		var deck_y := _deck_height_at(z)
		var bw := _rng.randf_range(4.4, 7.4)
		var tower := is_equal_approx(side, tower_side)
		var inner := 12.4 + _rng.randf_range(0.0, 1.6) if tower else 9.5 + _rng.randf_range(0.0, 1.1)
		inner *= _city_close()
		var top := deck_y + _rng.randf_range(6.0, 15.0) if tower else deck_y - _rng.randf_range(7.2, 10.5)
		var height := maxf(10.0, top - street_y) * _city_scale()
		height = maxf(8.0, height)
		top = street_y + height
		var x := side * (inner + bw * 0.5)
		var color := _cloud_hi if tower else _cloud
		_block(Vector3(x, street_y + height * 0.5, z), Vector3(bw, height, bd), color, side, tower)
		if tower and _rng.randf() < 0.45:
			_city_box(Vector3(x, top + 1.15, z), Vector3(1.15, 2.1, 1.15), _metal)
			_city_box(Vector3(x, top + 2.3, z), Vector3(1.4, 0.16, 1.4), _sea)
		elif tower and _rng.randf() < 0.7:
			_city_box(Vector3(x, top + 2.3, z), Vector3(0.22, 4.4, 0.22), _win, true)
	if i % 2 == 0:
		_lamp(-7.4 if i % 4 == 0 else 7.4, z, street_y)
	if _rng.randf() < 0.7:
		var lx := _rng.randf_range(3.4, 6.2) * (-1.0 if _rng.randf() < 0.5 else 1.0)
		var lh := _rng.randf_range(2.4, 5.2)
		_city_box(Vector3(lx, street_y + lh * 0.5, z + bd * 0.35), Vector3(_rng.randf_range(2.4, 4.2), lh, _rng.randf_range(2.4, 4.4)), _cloud)
	z -= bd + _rng.randf_range(6.4, 9.6)
	_city_z = z
	_city_i = i + 1
	return true


func _booston_ready() -> bool:
	return _booston_load_i >= _BOOSTON_FILES.size()


func _booston_load_frac() -> float:
	var count := maxi(_BOOSTON_FILES.size(), 1)
	return clampf((float(_booston_load_i) + _booston_file_prog) / float(count), 0.0, 1.0)


func _booston_load_one() -> void:
	if _booston_ready():
		return
	var path := _BOOSTON_FILES[_booston_load_i]
	if _build_sync or ResourceLoader.has_cached(path):
		_booston_take(load(path))
		_booston_load_i += 1
		_booston_file_prog = 0.0
		_booston_wait = ""
		return
	if _booston_wait != path:
		_booston_wait = path
		_booston_file_prog = 0.0
		if ResourceLoader.load_threaded_request(path) != OK:
			_booston_take(load(path))
			_booston_load_i += 1
			_booston_wait = ""
		return
	var prog: Array = []
	var status := ResourceLoader.load_threaded_get_status(path, prog)
	_booston_file_prog = float(prog[0]) if not prog.is_empty() else 0.0
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return
	var packed: PackedScene = null
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		packed = ResourceLoader.load_threaded_get(path) as PackedScene
	_booston_take(packed)
	_booston_load_i += 1
	_booston_wait = ""
	_booston_file_prog = 0.0


func _booston_take(packed: PackedScene) -> void:
	if packed == null:
		return
	_booston_packed.append(packed)
	var probe := packed.instantiate() as Node3D
	_booston_bounds.append(_booston_bounds_of(probe))
	probe.free()


func _booston_bounds_of(root: Node3D) -> AABB:
	var found := false
	var box := AABB()
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := child as MeshInstance3D
		var xf := Transform3D.IDENTITY
		var current: Node = mesh_node
		while current != null and current != root:
			if current is Node3D:
				xf = (current as Node3D).transform * xf
			current = current.get_parent()
		var piece: AABB = xf * mesh_node.get_aabb()
		if not found:
			box = piece
			found = true
		else:
			box = box.merge(piece)
	return box


func _booston_pair(z: float, street_y: float, index: int) -> float:
	var count := _booston_packed.size()
	if count == 0:
		return 16.0
	var tall := _booston_tall(z, street_y)
	var left := posmod(index, count)
	var right := posmod(index + 3, count)
	var span_l := _booston_place(left, -1.0, z, street_y, tall)
	var span_r := _booston_place(right, 1.0, z, street_y, tall)
	var span := maxf(span_l, span_r)
	var next_tall := _booston_tall(z - span, street_y)
	var next_w := maxf(_booston_width(posmod(index + 1, count), next_tall), _booston_width(posmod(index + 4, count), next_tall))
	return span * 0.5 + next_w * 0.5 + _BOOSTON_GAP


func _booston_tall(z: float, street_y: float) -> float:
	return maxf(20.0, _deck_height_at(z) - street_y + _BOOSTON_RISE)


func _booston_width(index: int, tall: float) -> float:
	var box: AABB = _booston_bounds[index]
	if box.size.y <= 0.01:
		return 8.0
	return box.size.x * tall / box.size.y


func _booston_place(index: int, side: float, z: float, street_y: float, tall: float) -> float:
	var box: AABB = _booston_bounds[index]
	var scale := tall / box.size.y if box.size.y > 0.01 else 1.0
	var min_corner := box.position * scale
	var size := box.size * scale
	var max_z := min_corner.z + size.z
	var mid_x := min_corner.x + size.x * 0.5
	var yaw := PI * 0.5 if side < 0.0 else -PI * 0.5
	var placed := {
		"index": index,
		"side": side,
		"z": z,
		"street_y": street_y,
		"tall": tall,
		"yaw": yaw,
		"scale": scale,
		"min_y": min_corner.y,
		"max_z": max_z,
		"mid_x": mid_x,
	}
	if _preview:
		_booston_show(placed)
	else:
		_booston_slots.append(placed)
	var depth := size.z
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 1
	var center_x := -_BOOSTON_INNER - depth * 0.5 if side < 0.0 else _BOOSTON_INNER + depth * 0.5
	body.position = Vector3(center_x, street_y + size.y * 0.5, z)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(depth, size.y, size.x)
	col.shape = shape
	body.add_child(col)
	add_child(body)
	return size.x


func _booston_show(slot: Dictionary) -> Node3D:
	var index := int(slot["index"])
	var side := float(slot["side"])
	var visual := _booston_packed[index].instantiate() as Node3D
	_booston_serial += 1
	visual.name = "BoostonBuilding_%d" % _booston_serial
	visual.scale = Vector3.ONE * float(slot["scale"])
	visual.rotation.y = float(slot["yaw"])
	var max_z := float(slot["max_z"])
	var mid_x := float(slot["mid_x"])
	var street_y := float(slot["street_y"])
	var z := float(slot["z"])
	if side < 0.0:
		visual.position = Vector3(-_BOOSTON_INNER - max_z, street_y - float(slot["min_y"]), z + mid_x)
	else:
		visual.position = Vector3(_BOOSTON_INNER + max_z, street_y - float(slot["min_y"]), z - mid_x)
	for child in visual.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as GeometryInstance3D
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.visibility_range_end = 180.0
		mesh.visibility_range_end_margin = 28.0
		mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	add_child(visual)
	return visual


func focus_city(z: float) -> void:
	if map_id != "annex" or _preview or _booston_slots.is_empty():
		return
	var behind := z + _BOOSTON_BEHIND
	var ahead := z - _BOOSTON_AHEAD
	var drop: Array[int] = []
	for key in _booston_live.keys():
		var slot_i := int(key)
		if slot_i < 0 or slot_i >= _booston_slots.size():
			drop.append(slot_i)
			continue
		var sz := float(_booston_slots[slot_i]["z"])
		if sz > behind or sz < ahead:
			drop.append(slot_i)
	for slot_i in drop:
		var node: Node = _booston_live[slot_i]
		_booston_live.erase(slot_i)
		if is_instance_valid(node):
			node.queue_free()
	var spawned := 0
	for i in _booston_slots.size():
		if spawned >= 1:
			break
		if _booston_live.has(i):
			continue
		var sz := float(_booston_slots[i]["z"])
		if sz > behind or sz < ahead:
			continue
		_booston_live[i] = _booston_show(_booston_slots[i])
		spawned += 1


func city_settled(z: float) -> bool:
	if map_id != "annex" or _preview:
		return true
	focus_city(z)
	var behind := z + _BOOSTON_BEHIND
	var ahead := z - _BOOSTON_AHEAD
	for i in _booston_slots.size():
		var sz := float(_booston_slots[i]["z"])
		if sz <= behind and sz >= ahead and not _booston_live.has(i):
			return false
	return true


func _lamp(x: float, z: float, street_y: float) -> void:
	_city_box(Vector3(x, street_y + 1.7, z), Vector3(0.1, 3.4, 0.1), _metal)
	var bulb := Color(1.0, 0.78, 0.42) if _abyss_dark else Color(0.95, 0.9, 0.78)
	_city_box(Vector3(x, street_y + 3.5, z), Vector3(0.38, 0.1, 0.38), bulb, true)
	_city_box(Vector3(x + 0.22, street_y + 3.35, z), Vector3(0.28, 0.06, 0.1), _metal)


func _block(center: Vector3, size: Vector3, color: Color, side: float, tower: bool) -> void:
	if tower:
		var lower_h := size.y * 0.62
		var upper_h := size.y - lower_h
		var lower_c := Vector3(center.x, center.y - size.y * 0.5 + lower_h * 0.5, center.z)
		var upper_size := Vector3(size.x * 0.72, upper_h, size.z * 0.72)
		var upper_c := Vector3(center.x, center.y + size.y * 0.5 - upper_h * 0.5, center.z)
		_city_box(lower_c, Vector3(size.x, lower_h, size.z), color)
		_city_box(upper_c, upper_size, _cloud if color == _cloud_hi else _cloud_hi)
		_city_box(Vector3(center.x, center.y + size.y * 0.5 + 0.16, center.z), Vector3(upper_size.x + 0.4, 0.28, upper_size.z + 0.4), _sea)
		_facade(lower_c, Vector3(size.x, lower_h, size.z), side, 3)
		_facade(upper_c, upper_size, side, 3)
	else:
		_city_box(center, size, color)
		_city_box(Vector3(center.x, center.y + size.y * 0.5 + 0.16, center.z), Vector3(size.x + 0.5, 0.28, size.z + 0.5), _sea)
		_facade(center, size, side, 4)


func _facade(center: Vector3, size: Vector3, side: float, rows: int) -> void:
	var top := center.y + size.y * 0.5 - 1.6
	var floor_y := center.y - size.y * 0.5 + 2.2
	var face_z := center.z + size.z * 0.5 + 0.07
	var face_x := center.x - side * (size.x * 0.5 + 0.07)
	var cols := 3 if size.x > 5.4 else 2
	var pane_w := minf(1.15, size.x * 0.2)
	var pane_h := 1.15
	var row := 0
	var y := top
	while y > floor_y and row < rows:
		var span := size.x * 0.7
		for c in cols:
			var t := (float(c) + 0.5) / float(cols) - 0.5
			_city_box(Vector3(center.x + t * span, y, face_z), Vector3(pane_w, pane_h, 0.1), _win, true)
		var span_z := size.z * 0.55
		for c in 2:
			var tz := (float(c) + 0.5) / 2.0 - 0.5
			_city_box(Vector3(face_x, y, center.z + tz * span_z), Vector3(0.1, pane_h, pane_w * 0.9), _win, true)
		y -= 2.85
		row += 1


func _city_box(center: Vector3, size: Vector3, color: Color, flat: bool = false) -> void:
	if flat and color.is_equal_approx(_win) and maxf(size.x, maxf(size.y, size.z)) < 4.0:
		_win_add(center, size)
		return
	var mesh_node := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_node.mesh = box_mesh
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var reach := maxf(size.x, maxf(size.y, size.z))
	if reach < 42.0:
		mesh_node.visibility_range_end = 160.0
		mesh_node.visibility_range_end_margin = 24.0
		mesh_node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	mesh_node.material_override = _flat(color) if flat else _mat(color, 0.88, 0.0)
	if _city_touchable(size):
		_plant_mesh(center, mesh_node, Vector3.ZERO, size)
	else:
		mesh_node.position = center
		add_child(mesh_node)


func _win_add(center: Vector3, size: Vector3) -> void:
	var chunk := int(floor(center.z / 48.0))
	if not _win_chunks.has(chunk):
		_win_chunks[chunk] = []
	(_win_chunks[chunk] as Array).append(Transform3D(Basis.from_scale(size), center))


func _flush_windows() -> void:
	if _win_chunks.is_empty():
		return
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	var mat := _flat(_win)
	for chunk in _win_chunks.keys():
		var spots: Array = _win_chunks[chunk]
		if spots.is_empty():
			continue
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = box
		multi.instance_count = spots.size()
		for i in spots.size():
			multi.set_instance_transform(i, spots[i])
		var node := MultiMeshInstance3D.new()
		node.multimesh = multi
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.material_override = mat
		node.visibility_range_end = 160.0
		node.visibility_range_end_margin = 24.0
		node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		add_child(node)
	_win_chunks.clear()


func _slab(min_x: float, max_x: float, min_z: float, max_z: float, top: float, color: Color, icy: bool = false, push: float = 0.0, group: String = "", skin: String = "") -> void:
	var size := Vector3(max_x - min_x, 1.0, absf(max_z - min_z))
	if size.x < 0.4 or size.z < 0.4:
		return
	var center := Vector3((min_x + max_x) * 0.5, top - 0.5, (min_z + max_z) * 0.5)
	_slabs.append({
		"min_x": minf(min_x, max_x),
		"max_x": maxf(min_x, max_x),
		"min_z": minf(min_z, max_z),
		"max_z": maxf(min_z, max_z),
		"top": top,
	})
	var bare := _kit_on() and not icy
	_box(center, size, color, icy, push, group, bare)
	if not bare:
		return
	var lo_x := minf(min_x, max_x)
	var hi_x := maxf(min_x, max_x)
	var lo_z := minf(min_z, max_z)
	var hi_z := maxf(min_z, max_z)
	if group == "belt":
		_pave_belt(lo_x, hi_x, lo_z, hi_z, top, push)
	elif skin == "plank":
		_pave_plank(lo_x, hi_x, lo_z, hi_z, top)
	elif skin == "duct":
		_pave_duct(lo_x, hi_x, lo_z, hi_z, top)
	else:
		_pave_deck(lo_x, hi_x, lo_z, hi_z, top)
		_pave_edges(lo_x, hi_x, lo_z, hi_z, top)


func _checkpoint_feet() -> Vector3:
	var y := _floor_y + 0.08
	var slab := _slab_at_end()
	if slab.is_empty():
		return Vector3(0.0, y, _solid_end + 2.0)
	var min_x := float(slab["min_x"])
	var max_x := float(slab["max_x"])
	var min_z := float(slab["min_z"])
	var max_z := float(slab["max_z"])
	# The seat rows stand up to 4.2m behind the mark. Keep that on the roof.
	var z := max_z - 4.9
	if z < min_z + 0.8:
		z = (min_z + max_z) * 0.5
	var x := clampf(0.0, min_x + 0.8, max_x - 0.8)
	return Vector3(x, y, z)


func _slab_at_end() -> Dictionary:
	var best: Dictionary = {}
	var best_score := -1.0
	for slab in _slabs:
		if absf(float(slab["top"]) - _floor_y) > 0.2:
			continue
		var min_z := float(slab["min_z"])
		var max_z := float(slab["max_z"])
		if _solid_end < min_z - 0.15 or _solid_end > max_z + 0.15:
			continue
		var score := (max_z - min_z) + (float(slab["max_x"]) - float(slab["min_x"]))
		if absf(min_z - _solid_end) < 0.2:
			score += 50.0
		if score > best_score:
			best_score = score
			best = slab
	return best


func _point_on_slab(feet: Vector3, margin: float) -> bool:
	for slab in _slabs:
		if absf(float(slab["top"]) - (feet.y - 0.08)) > 0.25:
			continue
		if feet.x < float(slab["min_x"]) + margin or feet.x > float(slab["max_x"]) - margin:
			continue
		if feet.z < float(slab["min_z"]) + margin or feet.z > float(slab["max_z"]) - margin:
			continue
		return true
	return false


func _box(center: Vector3, size: Vector3, color: Color, icy: bool = false, push: float = 0.0, group: String = "", bare: bool = false) -> void:
	var body := StaticBody3D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	if icy:
		body.add_to_group("ice")
		body.set_meta("push", push)
	if group != "":
		body.add_to_group(group)
		body.set_meta("push", push)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	if not bare:
		var mesh_node := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = size
		mesh_node.mesh = box_mesh
		mesh_node.material_override = _deck_mat(color, 0.42 if icy else 0.9, 0.4 if icy else 0.0)
		body.add_child(mesh_node)
	body.add_child(col)
	add_child(body)


func _top_stripe(body: Node3D, size: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x * 0.55, 0.04, size.z * 0.22)
	mesh.mesh = box
	mesh.position = Vector3(0, size.y * 0.5 + 0.02, 0)
	mesh.material_override = _glow(Color(0.96, 0.92, 0.78))
	body.add_child(mesh)


func _glow_box(center: Vector3, size: Vector3, color: Color) -> void:
	var mesh_node := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_node.mesh = box_mesh
	mesh_node.position = center
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_node.material_override = _glow(color)
	add_child(mesh_node)


func _glow(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.8
	mat.roughness = 0.35
	return mat


func _flat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	return mat


func _dress(center: Vector3, size: Vector3, color: Color) -> void:
	var mesh_node := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_node.mesh = box_mesh
	mesh_node.material_override = _mat(color)
	if _touchable(center, size):
		var hit := size
		var shift := Vector3.ZERO
		# A tread is only a few centimeters thick. Drop the solid so the top
		# stays where it looks, and the feet still catch it.
		if size.y < 0.24 and size.x > 0.5 and size.z > 0.5:
			hit.y = 0.28
			shift.y = (size.y - hit.y) * 0.5
		_plant_mesh(center, mesh_node, shift, hit)
	else:
		mesh_node.position = center
		add_child(mesh_node)


func _touchable(center: Vector3, size: Vector3) -> bool:
	var deck := _deck_height_at(center.z)
	var top := center.y + size.y * 0.5
	var platform := size.x >= 0.5 and size.z >= 0.5
	if platform:
		# Paint and hazard dashes lie on the deck. A tread sits up in the air.
		if size.y <= 0.09 and (absf(top - deck) < 0.28 or absf(top - _floor_y) < 0.22):
			return false
		# Canal sheets sit under the roof. They read as water, not a floor.
		if size.y < 0.26 and size.x > 8.0 and center.y < deck - 0.4:
			return false
		return true
	# Posts and headers. The needle poles are a few centimeters wide and sit
	# on the racing line, so those stay visual.
	return minf(size.x, size.z) >= 0.12 and size.y >= 0.12


func _city_touchable(size: Vector3) -> bool:
	var thin := minf(size.x, minf(size.y, size.z))
	if thin < 0.15:
		return false
	# Street paint and the long road ribbons stay visual.
	if size.y < 0.2 and (size.x > 6.0 or size.z > 12.0):
		return false
	return true


func _plant_mesh(center: Vector3, mesh_node: MeshInstance3D, shift: Vector3, hit: Vector3 = Vector3.ZERO) -> void:
	var body := StaticBody3D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	mesh_node.position = Vector3.ZERO
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = hit if hit != Vector3.ZERO else Vector3(0.2, 0.2, 0.2)
	col.shape = shape
	col.position = shift
	body.add_child(mesh_node)
	body.add_child(col)
	add_child(body)


func _plant_cyl(center: Vector3, radius: float, height: float) -> void:
	var body := StaticBody3D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	col.shape = shape
	body.add_child(col)
	add_child(body)


func _deck_mat(color: Color, roughness: float, metallic: float) -> ShaderMaterial:
	if _deck_shader == null:
		_deck_shader = load("res://shaders/deck.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = _deck_shader
	mat.set_shader_parameter("albedo", color)
	mat.set_shader_parameter("roughness_amt", roughness)
	mat.set_shader_parameter("metal", metallic)
	mat.set_shader_parameter("rim", 0.1 if metallic > 0.2 else 0.12)
	return mat


func _mat(color: Color, roughness: float = 0.94, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat
