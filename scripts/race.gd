extends Node3D

const PlayerScript := preload("res://scripts/player.gd")
const CourseScript := preload("res://scripts/course.gd")
const Catalog := preload("res://scripts/catalog.gd")
const GhostStore := preload("res://scripts/ghosts.gd")
const Styles := preload("res://scripts/styles.gd")
const Trails := preload("res://scripts/trails.gd")
const GhostScript := preload("res://scripts/ghost.gd")
const Emotes := preload("res://scripts/emotes.gd")
const Names := preload("res://scripts/names.gd")

const COLORS: Array[Color] = [
	Color("e23b2f"),
	Color("1f8a70"),
	Color("e0a106"),
	Color("2f5be7"),
	Color("7a4ea3"),
	Color("d4552f"),
	Color("3d6b74"),
	Color("c4473a"),
	Color("2a9d8f"),
	Color("8a5a3a"),
]
const LANES: Array[float] = [-3.0, -1.5, 0.0, 1.5, 3.0, -3.0, -1.5, 0.0, 1.5, 3.0]

var players: Node3D
var spawn_points: Array[Vector3] = [
	Vector3(-3.0, 0.2, 5.4),
	Vector3(-1.5, 0.2, 5.4),
	Vector3(0.0, 0.2, 5.4),
	Vector3(1.5, 0.2, 5.4),
	Vector3(3.0, 0.2, 5.4),
	Vector3(-3.0, 0.2, 7.2),
	Vector3(-1.5, 0.2, 7.2),
	Vector3(0.0, 0.2, 7.2),
	Vector3(1.5, 0.2, 7.2),
	Vector3(3.0, 0.2, 7.2),
	Vector3(-3.0, 0.2, 9.0),
	Vector3(-1.5, 0.2, 9.0),
	Vector3(0.0, 0.2, 9.0),
	Vector3(1.5, 0.2, 9.0),
	Vector3(3.0, 0.2, 9.0),
	Vector3(-3.0, 0.2, 10.8),
	Vector3(-1.5, 0.2, 10.8),
	Vector3(0.0, 0.2, 10.8),
	Vector3(1.5, 0.2, 10.8),
	Vector3(3.0, 0.2, 10.8),
]

var time_label: Label
var pb_label: Label
var deaths_label: Label
var speed_label: Label
var place_label: Label
var message_label: Label
var wrong_label: Label
var help_label: Label
var menu_button: Button
var spectate_button: Button
var emote_row: HBoxContainer
var board_list: VBoxContainer
var spectate_cam: Camera3D
var spectate_i := -1
var crosshair: Label
var ink := Color("1c1915")
var map_minutes := 3.0
const SHOW_COUNT := 5.0
var countdown := 5.0
var _field_watch := -1.0
var count_label: Label
var _count_shown := ""
var _count_age := 0.0
var intro_cam: Camera3D
var intro_on := false
var run_left := 0.0
var wrong_for := 0.0
var tape := PackedFloat32Array()
var pb_committed := false
var ghost
var race_clock := 0.0
var settle := -1.0
var ended := false
var finishes: Array = []
var first_finish_clock := -1.0
var _cut_done := false
var _cut_age := -1.0
var _cut_sent := false
var bot_time := 0.0
var cp_hold := 0.0
var held_cp := -1
var heartbeat := 0.0
var _held_slots: Array[int] = []
var was_captured := false
var _course
var _booting := false
var _course_ready := false
var _queued: Array = []
var _feed: SubViewport
var _feed_cam: Camera3D
var _feed_card: Control
var _feed_label: Label
var _feed_name: Label
var _feed_mat: StandardMaterial3D
var _feed_snap := true


func _ready() -> void:
	if OS.get_environment("ROOFLINE_FIELD") == "1":
		print("FIELD race ", Match.map_id)
	PlayerScript.ensure_actions()
	add_to_group("race")
	Curtain.keep()
	_course = CourseScript.new()
	add_child(_course)
	_course.begin(Match.map_id)
	players = Node3D.new()
	players.name = "Players"
	add_child(players)
	_booting = true
	_course_ready = false


func _boot_frame() -> void:
	if not _course_ready:
		if _course.step():
			_course_ready = true
		Curtain.set_progress(lerpf(0.04, 0.9, _course.fraction()), "Raising the roof.")
		return
	if not _course.city_settled(6.0):
		Curtain.set_progress(0.96, "Raising the roof.")
		return
	_open_race()


func _open_race() -> void:
	_booting = false
	_world(_course)
	if Match.battle:
		_place_items(_course)
	if Match.speedrun:
		var prior := GhostStore.load_run(Match.map_id)
		Match.beat_pb = false
		if prior.is_empty():
			Match.previous_pb = -1.0
			Match.pb_time = -1.0
		else:
			Match.previous_pb = float(prior["time"])
			Match.pb_time = Match.previous_pb
			_spawn_ghost(prior["samples"])
	_hud()
	spectate_cam = Camera3D.new()
	spectate_cam.current = false
	spectate_cam.fov = 72.0
	add_child(spectate_cam)
	var info := Catalog.get_map(Match.map_id)
	map_minutes = float(info["minutes"])
	var queued := _queued.duplicate()
	_queued.clear()
	for row in queued:
		spawn_runner(str(row[0]), int(row[1]), bool(row[2]), str(row[3]), row[4], str(row[5]), str(row[6]), str(row[7]))
	if Match.series and Match.round_index > 0 and not Match.qualifiers.is_empty():
		Match.started = false
		if not Network.is_online() or multiplayer.is_server():
			if Network.is_online() and not multiplayer.peer_disconnected.is_connected(_on_peer_left):
				multiplayer.peer_disconnected.connect(_on_peer_left)
			_spawn_qualifiers()
		elif not multiplayer.server_disconnected.is_connected(_leave):
			multiplayer.server_disconnected.connect(_leave)
		if _view_player() == null:
			spectate_i = 0
	elif _view_player() == null:
		if Match.audit or OS.get_environment("ROOFLINE_BOT") == "1":
			Match.audit = true
			Match.started = true
			var as_rival := OS.get_environment("ROOFLINE_RIVAL") == "1"
			_add_runner("1", 0, true, true, as_rival, "P1", Color("e23b2f"))
		else:
			Match.started = false
			if not Network.is_online():
				_add_runner("you", 0, false, true, false, Profile.screen_name(), Profile.player_color(), Profile.hat_id(), Profile.style_id(), Profile.trail_id())
				if not Match.practice or Match.fill_bots:
					_fill_bots()
			elif multiplayer.is_server():
				if not multiplayer.peer_disconnected.is_connected(_on_peer_left):
					multiplayer.peer_disconnected.connect(_on_peer_left)
				spawn_runner.rpc("1", _take_slot(), false, Profile.screen_name(), Profile.player_color(), Profile.hat_id(), Profile.style_id(), Profile.trail_id())
				if Match.fill_bots:
					_fill_bots()
			else:
				if not multiplayer.server_disconnected.is_connected(_leave):
					multiplayer.server_disconnected.connect(_leave)
				if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
					request_spawn.rpc_id(1, Profile.screen_name(), Profile.hue, Profile.hat_id(), Profile.style_id(), Profile.trail_id())
				else:
					multiplayer.connected_to_server.connect(func() -> void: request_spawn.rpc_id(1, Profile.screen_name(), Profile.hue, Profile.hat_id(), Profile.style_id(), Profile.trail_id()))
	_begin_show()
	_mount_feed()
	Curtain.finish()
	if OS.get_environment("ROOFLINE_FIELD") == "1":
		_field_watch = 0.0


func _begin_show() -> void:
	if _course != null and _course.has_method("place_opening_drones"):
		_course.place_opening_drones()
	if Match.started:
		return
	var runner = _view_player()
	if runner == null:
		return
	runner.cinematic = true
	if runner.camera != null:
		runner.camera.current = false
	intro_cam = Camera3D.new()
	intro_cam.fov = 50.0
	intro_cam.near = 0.08
	intro_cam.current = true
	add_child(intro_cam)
	intro_on = true
	_fly_intro()


func _fly_intro() -> void:
	var runner = _view_player()
	if runner == null or intro_cam == null or runner.head == null:
		return
	var u := 1.0 - clampf(countdown / SHOW_COUNT, 0.0, 1.0)
	var head_xf: Transform3D = runner.head.global_transform
	var eyes := head_xf.origin + head_xf.basis * Vector3(0.0, 0.02, -0.04)
	var head_pos := eyes
	var seated := head_xf.basis
	if runner.third_person:
		var back := head_xf.basis.z
		if back.length() < 0.01:
			back = Vector3(0, 0, 1)
		back = back.normalized()
		head_pos = head_xf.origin + back * 3.55 + Vector3.UP * 0.22
	var pack := Vector3(0.0, 1.4, 6.3)
	var above := Vector3(0.4, 13.0, 15.5)
	var swung := Vector3(-8.6, 5.4, 7.2)
	var front := Vector3(1.6, 3.1, -2.8)
	var pos := above
	if u < 0.34:
		pos = above.lerp(swung, _smooth(u / 0.34))
	elif u < 0.66:
		pos = swung.lerp(front, _smooth((u - 0.34) / 0.32))
	else:
		pos = front.lerp(head_pos, _ease_in((u - 0.66) / 0.34))
	var look := pack
	if u > 0.62:
		var ahead := head_pos + head_xf.basis * Vector3(0, 0, -6.0)
		look = pack.lerp(ahead, _smooth((u - 0.62) / 0.38))
	var blend := 0.0
	if u > 0.9:
		blend = _smooth((u - 0.9) / 0.1)
		pos = pos.lerp(head_pos, blend)
	intro_cam.global_position = pos
	if pos.distance_to(look) > 0.2:
		intro_cam.look_at(look, Vector3.UP)
	if blend > 0.0:
		intro_cam.global_transform.basis = intro_cam.global_transform.basis.slerp(seated, blend)
	var fov := lerpf(50.0, 64.0, _smooth(u))
	if u > 0.72:
		fov = lerpf(fov, Settings.fov, _smooth((u - 0.72) / 0.28))
	var punch := (1.0 - clampf(_count_age / 0.32, 0.0, 1.0)) * 7.0
	intro_cam.fov = fov + punch


func _clear_marks() -> void:
	for node in get_tree().get_nodes_in_group("runners"):
		node.set("on_marks", false)


func _end_intro() -> void:
	if not intro_on and intro_cam == null:
		return
	intro_on = false
	if intro_cam != null:
		intro_cam.current = false
		intro_cam.queue_free()
		intro_cam = null
	var runner = _view_player()
	if runner == null:
		return
	runner.cinematic = false
	_clear_marks()
	if runner.camera != null:
		runner.camera.top_level = false
		runner.camera.position = Vector3.ZERO
		runner.camera.rotation = Vector3.ZERO
	if runner.has_method("_apply_view"):
		runner._apply_view()
	if runner.camera != null:
		runner.camera.current = true


func _paint_countdown(text: String) -> void:
	_show_on_screens(text)
	if count_label == null:
		return
	if text == "":
		count_label.visible = false
		count_label.text = ""
		_count_shown = ""
		return
	if text != _count_shown:
		_count_shown = text
		_count_age = 0.0
		count_label.text = text
		if text == "1" or text == "RUN!":
			Sfx.play("horn", -16.0, 1.0 if text == "1" else 1.12)
		elif text != "":
			Sfx.play("tick", -24.0, 0.96)
	_count_age += get_process_delta_time()
	var view := get_viewport().get_visible_rect().size
	var t := clampf(_count_age / 0.48, 0.0, 1.0)
	var settle := _back_out(t)
	var start := 4.1 if text == "RUN!" else 3.25
	count_label.scale = Vector2.ONE * lerpf(start, 1.0, settle)
	var lift := lerpf(-210.0, 0.0, _smooth(minf(t * 1.25, 1.0)))
	count_label.position = Vector2(0.0, view.y * 0.16 + lift)
	count_label.size = Vector2(view.x, view.y * 0.5)
	count_label.pivot_offset = count_label.size * 0.5
	count_label.visible = true


func feed_material() -> Material:
	return _feed_mat


func _mount_feed() -> void:
	_feed = SubViewport.new()
	_feed.name = "Feed"
	_feed.own_world_3d = false
	_feed.size = Vector2i(640, 360)
	_feed.transparent_bg = false
	_feed.handle_input_locally = false
	_feed.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_feed.msaa_3d = Viewport.MSAA_DISABLED
	_feed.positional_shadow_atlas_size = 0
	add_child(_feed)
	_feed_cam = Camera3D.new()
	_feed_cam.fov = 40.0
	_feed_cam.near = 0.12
	_feed_cam.far = 80.0
	_feed_cam.cull_mask = 1
	_feed_cam.current = false
	_feed.add_child(_feed_cam)
	_feed_card = Control.new()
	_feed_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	_feed_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feed.add_child(_feed_card)
	var bg := ColorRect.new()
	bg.color = Color("12161c")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feed_card.add_child(bg)
	_feed_label = Label.new()
	_feed_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_feed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_feed_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var slate := LabelSettings.new()
	slate.font_size = 168
	slate.font_color = Color("efe8dc")
	slate.outline_size = 18
	slate.outline_color = Color(0.04, 0.03, 0.02, 0.95)
	_feed_label.label_settings = slate
	_feed_card.add_child(_feed_label)
	var bar := ColorRect.new()
	bar.color = Color(0.05, 0.05, 0.06, 0.72)
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -48
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feed.add_child(bar)
	_feed_name = Label.new()
	_feed_name.set_anchors_preset(Control.PRESET_FULL_RECT)
	_feed_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feed_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_feed_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caption := LabelSettings.new()
	caption.font_size = 28
	caption.font_color = Color("efe8dc")
	caption.outline_size = 8
	caption.outline_color = Color(0.04, 0.03, 0.02, 0.9)
	_feed_name.label_settings = caption
	bar.add_child(_feed_name)
	bar.visible = false
	_feed_name.set_meta("bar", bar)
	_feed_mat = StandardMaterial3D.new()
	_feed_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_feed_mat.albedo_texture = _feed.get_texture()
	_feed_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_show_on_screens("5")


func _show_on_screens(text: String) -> void:
	if _feed_label == null or _feed_card == null:
		return
	var live := text == ""
	_feed_card.visible = not live
	_feed_label.text = text
	var slate := _feed_label.label_settings
	if slate != null:
		if text == "ELIMINATED":
			slate.font_size = 64
			slate.font_color = Color("e23b2f")
		elif text == "RUN!":
			slate.font_size = 112
			slate.font_color = Color("e23b2f")
		else:
			slate.font_size = 168
			slate.font_color = Color("efe8dc")
	if _feed_cam != null:
		_feed_cam.current = live
	var bar: CanvasItem = _feed_name.get_meta("bar") if _feed_name != null else null
	if bar != null:
		bar.visible = live


func _drive_feed(delta: float) -> void:
	if _feed_cam == null or not _feed_cam.current:
		return
	var lead := _broadcast_leader()
	if lead == null:
		return
	var basis := lead.global_transform.basis
	var behind := lead.global_position + basis.z * 6.8 + basis.x * 1.7 + Vector3.UP * 2.6
	var look := lead.global_position + Vector3.UP * 1.35 - basis.z * 1.4
	if _feed_snap:
		_feed_cam.global_position = behind
		_feed_snap = false
	else:
		_feed_cam.global_position = _feed_cam.global_position.lerp(behind, 1.0 - exp(-2.6 * delta))
	if _feed_cam.global_position.distance_to(look) > 0.35:
		_feed_cam.look_at(look, Vector3.UP)
	if _feed_name != null:
		_feed_name.text = "1st  %s" % str(lead.get("display_name"))


func _broadcast_leader() -> Node3D:
	var best: Node3D = null
	if players == null:
		return null
	for node in players.get_children():
		var runner := node as Node3D
		if runner == null:
			continue
		if best == null or _ahead_of(runner, best):
			best = runner
	return best


func _smooth(t: float) -> float:
	var x := clampf(t, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)


func _ease_in(t: float) -> float:
	var x := clampf(t, 0.0, 1.0)
	return x * x


func _back_out(t: float) -> float:
	var x := clampf(t, 0.0, 1.0)
	var c1 := 1.70158
	var c3 := c1 + 1.0
	var p := x - 1.0
	return 1.0 + c3 * p * p * p + c1 * p * p


func _world(course) -> void:
	var sky: Color = course.sky
	var luma := sky.r * 0.3 + sky.g * 0.59 + sky.b * 0.11
	var night := luma < 0.42
	ink = Color("f4efe6") if night else Color("1c1915")
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	if night:
		sky_mat.sky_top_color = sky.darkened(0.55)
		sky_mat.sky_horizon_color = sky.lightened(0.08)
		sky_mat.ground_horizon_color = sky.darkened(0.45)
		sky_mat.ground_bottom_color = sky.darkened(0.75)
		sky_mat.sky_energy_multiplier = 0.4
	else:
		sky_mat.sky_top_color = sky.darkened(0.16)
		sky_mat.sky_horizon_color = sky.lightened(0.16)
		sky_mat.ground_horizon_color = sky.darkened(0.4)
		sky_mat.ground_bottom_color = sky.darkened(0.68)
		sky_mat.sky_energy_multiplier = 1.05
	sky_mat.sky_curve = 0.1
	sky_mat.sun_angle_max = 24.0
	var canvas := Sky.new()
	canvas.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = canvas
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55 if night else 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.12 if night else 1.0
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_light_color = sky_mat.sky_horizon_color
	env.fog_density = 0.008 if night else 0.0042
	env.fog_aerial_perspective = 0.35
	env.glow_enabled = true
	env.glow_intensity = 0.45 if night else 0.18
	env.glow_bloom = 0.08
	env.glow_hdr_threshold = 0.75
	Settings.dress_env(env, 1.12 if night else 1.0)
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 36, 0)
	sun.light_color = (Color(0.72, 0.8, 1.0) if night else Color(1.0, 0.96, 0.9)).lerp(sky, 0.62)
	sun.light_energy = 0.7 if night else 1.15
	sun.shadow_enabled = true
	sun.shadow_bias = 0.03
	sun.shadow_normal_bias = 0.8
	sun.directional_shadow_max_distance = 90.0
	sun.directional_shadow_blend_splits = true
	sun.light_specular = 0.35
	Settings.dress_sun(sun)
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-18, -148, 0)
	fill.light_color = Color(0.45, 0.55, 0.8) if night else Color(0.7, 0.78, 0.9)
	fill.light_energy = 0.22
	fill.shadow_enabled = false
	add_child(fill)


func _hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	place_label = _label(layer, 46, Vector2(24, 10))
	time_label = _label(layer, 26, Vector2(24, 62))
	var pb_y := 128.0 if Match.challenge else 94.0
	pb_label = _label(layer, 20, Vector2(24, pb_y))
	pb_label.visible = Match.speedrun
	pb_label.text = _pb_text()
	deaths_label = _label(layer, 22, Vector2(24, 96))
	deaths_label.visible = Match.challenge
	deaths_label.text = "Deaths  0"
	speed_label = _label(layer, 28, Vector2(1040, 18))
	board_list = VBoxContainer.new()
	board_list.position = Vector2(860, 58)
	board_list.custom_minimum_size = Vector2(400, 0)
	board_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_list.add_theme_constant_override("separation", 0)
	layer.add_child(board_list)
	message_label = _label(layer, 42, Vector2(340, 150))
	message_label.size = Vector2(600, 120)
	message_label.custom_minimum_size = Vector2(600, 120)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wrong_label = _label(layer, 78, Vector2(40, 250))
	wrong_label.size = Vector2(1200, 200)
	wrong_label.custom_minimum_size = Vector2(1200, 200)
	wrong_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wrong_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wrong_label.text = "You are going\nthe wrong way"
	wrong_label.visible = false
	if wrong_label.label_settings:
		wrong_label.label_settings.font_color = Color("e23b2f")
		wrong_label.label_settings.outline_size = 18
	help_label = _label(layer, 18, Vector2(24, 670))
	help_label.text = _help_line(false)
	menu_button = _hud_button("Back", Vector2(24, 624), _back)
	menu_button.visible = not Match.audit
	layer.add_child(menu_button)
	spectate_button = _hud_button("Spectate", Vector2(130, 624), _spectate)
	spectate_button.visible = false
	layer.add_child(spectate_button)
	emote_row = HBoxContainer.new()
	emote_row.position = Vector2(280, 620)
	emote_row.add_theme_constant_override("separation", 8)
	emote_row.visible = false
	var key_n := 1
	for item in Emotes.all():
		var id := str(item["id"])
		var button := _hud_button("%d %s" % [key_n, str(item["name"])], Vector2.ZERO, _play_emote.bind(id))
		button.set_meta("emote_id", id)
		button.set_meta("emote_level", int(item["level"]))
		emote_row.add_child(button)
		key_n += 1
	layer.add_child(emote_row)
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.position = Vector2(632, 338)
	crosshair.add_theme_font_size_override("font_size", 28)
	crosshair.add_theme_color_override("font_color", ink)
	crosshair.visible = false
	layer.add_child(crosshair)
	count_label = _label(layer, 188, Vector2.ZERO)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count_label.clip_text = false
	count_label.visible = false
	if count_label.label_settings:
		count_label.label_settings.font_color = Color("e23b2f")
		count_label.label_settings.outline_size = 28
		count_label.label_settings.outline_color = Color(0.04, 0.03, 0.02, 0.94)


func _hud_button(text: String, pos: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	button.pressed.connect(callback)
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("1c1915")
	button_style.content_margin_left = 14
	button_style.content_margin_right = 14
	button_style.content_margin_top = 6
	button_style.content_margin_bottom = 6
	var focus_style := button_style.duplicate()
	focus_style.bg_color = Color("e23b2f")
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_stylebox_override("hover", button_style)
	button.add_theme_stylebox_override("pressed", button_style)
	button.add_theme_stylebox_override("focus", focus_style)
	button.add_theme_color_override("font_color", Color("efe8dc"))
	button.add_theme_color_override("font_hover_color", Color("efe8dc"))
	return button


func _label(parent: Node, size: int, pos: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings := LabelSettings.new()
	settings.font_size = size
	settings.font_color = ink
	settings.outline_size = 12 if size >= 32 else 7
	settings.outline_color = Color(0.04, 0.03, 0.02, 0.88)
	label.label_settings = settings
	parent.add_child(label)
	return label


func _process(delta: float) -> void:
	if _field_watch >= 0.0:
		_field_watch += delta
		if _field_watch > 2.5 and not _booting:
			print("FIELD runners=", players.get_child_count())
			for child in players.get_children():
				var mascot := "none"
				if child.mannequin != null and child.mannequin.get_node_or_null("Mascot") != null:
					mascot = "yes"
				var rig_on := false
				if child.mannequin != null and child.mannequin.rig != null:
					rig_on = child.mannequin.rig.visible
				print("  ", child.name, " bot=", child.is_bot, " style=", child.worn_style, " mascot=", mascot, " rig=", rig_on, " pos=", child.global_position)
			get_tree().quit()
			return
	if _booting:
		_boot_frame()
		return
	_drive_feed(delta)
	if ended:
		return
	_tick_cut(delta)
	if ended:
		return
	if _course != null:
		_course.focus_city(_focus_z())
	var runner = _view_player()
	if runner == null:
		if players != null and players.get_child_count() > 0:
			_watch_field(delta)
		return
	if ghost != null:
		ghost.time = 0.0 if not Match.started else float(runner.race_time)
	if Match.speedrun and Match.started and not pb_committed:
		_record(runner, runner.finished)
		if runner.finished:
			_commit_pb(runner)
	if not Match.started:
		countdown = maxf(0.0, countdown - delta)
		time_label.text = "0:00.00" if Match.speedrun else str(Catalog.get_map(Match.map_id)["name"])
		speed_label.text = ""
		if Match.speedrun:
			pb_label.text = _pb_text()
			place_label.text = str(Catalog.get_map(Match.map_id)["name"])
		else:
			place_label.text = "Press A or click to run" if _pad_connected() else "Click to run"
		message_label.text = ""
		if countdown > 0.0:
			var digit := clampi(int(ceil(countdown - 0.0001)), 1, int(SHOW_COUNT))
			_paint_countdown(str(digit))
			if intro_on:
				_fly_intro()
		else:
			_clear_marks()
			_end_intro()
			Match.started = true
			run_left = 0.85
			_paint_countdown("RUN!")
			_record(runner, true)
		help_label.text = "Press A or click to run" if _pad_connected() else "Click to run"
		menu_button.visible = not Match.audit
		_paint_deaths(runner)
		return

	time_label.text = runner.format_time()
	_paint_deaths(runner)
	if Match.speedrun:
		pb_label.text = _pb_text()
	speed_label.text = "%d m/s" % int(runner.horizontal_speed())
	if Match.practice and not Match.fill_bots:
		var kind := "Practice"
		if Match.speedrun:
			kind = "Speedrun"
		elif Match.challenge:
			kind = "Challenge"
		place_label.text = kind
	else:
		place_label.text = _ordinal(_live_place(runner))
	_paint_board()
	_follow_spectate(delta)
	var done := bool(runner.finished)
	var out := bool(runner.get("eliminated"))
	spectate_button.visible = done and _spectate_targets().size() > 0 and not Match.audit
	_refresh_emotes(done)
	if out:
		_paint_countdown("")
		message_label.add_theme_font_size_override("font_size", 92)
		if message_label.label_settings:
			message_label.label_settings.font_size = 92
			message_label.label_settings.font_color = Color("e23b2f")
		message_label.text = "Eliminated"
	elif runner.message_time > 0.0 or done:
		_paint_countdown("")
		message_label.add_theme_font_size_override("font_size", 42)
		if message_label.label_settings:
			message_label.label_settings.font_size = 42
			message_label.label_settings.font_color = ink
		message_label.text = runner.message
		run_left = 0.0
	elif run_left > 0.0:
		message_label.text = ""
		_paint_countdown("RUN!")
		run_left = maxf(0.0, run_left - delta)
	else:
		message_label.text = ""
		_paint_countdown("")
	_paint_wrong(runner, delta)
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var show_mouse := not captured or done
	menu_button.visible = show_mouse and not Match.audit
	crosshair.visible = captured and not done
	if out:
		help_label.text = ""
		crosshair.visible = false
	elif done:
		help_label.text = "1-7 for an emote. Spectate watches the rest."
	elif show_mouse and not done:
		help_label.text = "Press A or click to run" if _pad_connected() else "Click to run"
	elif _pad_connected():
		help_label.text = _help_line(true)
	else:
		help_label.text = _help_line(false)
	if captured and not done:
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
	elif was_captured and menu_button.visible and not done:
		menu_button.call_deferred("grab_focus")
	was_captured = captured

	if Match.audit:
		_audit(delta, runner)
		return

	race_clock += delta
	if done and settle < 0.0:
		settle = 0.0
	if settle >= 0.0:
		settle += delta
	_maybe_end(runner)


func _audit(delta: float, runner) -> void:
	bot_time += delta
	heartbeat += delta
	if runner.checkpoint_index != held_cp:
		held_cp = runner.checkpoint_index
		cp_hold = 0.0
	else:
		cp_hold += delta
	if heartbeat >= 10.0:
		heartbeat = 0.0
		print("BOT t=", runner.format_time(), " cp=", runner.checkpoint_index, " z=", snappedf(runner.global_position.z, 1.0), " y=", snappedf(runner.global_position.y, 1.0), " wall=", runner.wall_running)
	if runner.finished:
		print("BOT finished in ", runner.format_time(), " cp ", runner.checkpoint_index)
		get_tree().quit(0)
	elif cp_hold > 22.0 or bot_time > map_minutes * 60.0 * 1.8 + 30.0:
		print("BOT stalled cp=", runner.checkpoint_index, " pos=", runner.global_position, " wall=", runner.wall_running, " slide=", runner.sliding)
		get_tree().quit(1)


func _help_line(pad: bool) -> String:
	if pad:
		if Match.battle:
			return "Left stick run    Right stick look    A jump    LB slide    B item    R3 camera"
		return "Left stick run    Right stick look    A jump    LB slide    R3 camera"
	if Match.battle:
		return "WASD run    Mouse look    Space jump    Shift slide    F item    V camera    Esc back"
	return "WASD run    Mouse look    Space jump    Shift slide    V camera    Esc back"


func _place_items(course) -> void:
	var CrateScript = load("res://scripts/crate.gd")
	for spot in course.item_marks():
		var crate = CrateScript.new()
		crate.position = spot
		add_child(crate)


func _paint_wrong(runner, delta: float) -> void:
	if wrong_label == null:
		return
	var back := false
	if not bool(runner.finished) and runner.has_method("turned_around"):
		back = bool(runner.turned_around())
	if back:
		wrong_for += delta
	else:
		wrong_for = 0.0
	wrong_label.visible = wrong_for > 0.2


func _paint_deaths(runner) -> void:
	if deaths_label == null:
		return
	deaths_label.visible = Match.challenge
	if Match.challenge:
		deaths_label.text = "Deaths  %d" % int(runner.falls)


func _focus_z() -> float:
	if spectate_i >= 0:
		var targets := _spectate_targets()
		if spectate_i < targets.size():
			return float(targets[spectate_i].global_position.z)
	var runner = _view_player()
	if runner != null:
		return float(runner.global_position.z)
	return 6.0


func _view_player():
	for node in get_tree().get_nodes_in_group("runners"):
		if node.get("view_player"):
			return node
	return null


func _live_place(runner) -> int:
	var place := 1
	for node in players.get_children():
		if node == runner:
			continue
		if _ahead_of(node, runner):
			place += 1
	return place


func _ahead_of(a, b) -> bool:
	var a_done := bool(a.finished)
	var b_done := bool(b.finished)
	if a_done != b_done:
		return a_done
	if a_done:
		return float(a.race_time) < float(b.race_time)
	if int(a.checkpoint_index) != int(b.checkpoint_index):
		return int(a.checkpoint_index) > int(b.checkpoint_index)
	return float(a.global_position.z) < float(b.global_position.z)


func _ordinal(n: int) -> String:
	if n == 1:
		return "1st"
	if n == 2:
		return "2nd"
	if n == 3:
		return "3rd"
	return "%dth" % n


func _everyone_finished() -> bool:
	var count := 0
	for node in players.get_children():
		count += 1
		if not node.finished:
			return false
	return count > 0


func _watch_field(delta: float) -> void:
	if spectate_i < 0:
		spectate_i = 0
	var lead = players.get_child(0)
	if not Match.started:
		countdown = maxf(0.0, countdown - delta)
		time_label.text = str(Catalog.get_map(Match.map_id)["name"])
		place_label.text = "Watching"
		if countdown > 0.0:
			var digit := clampi(int(ceil(countdown - 0.0001)), 1, int(SHOW_COUNT))
			_paint_countdown(str(digit))
		else:
			_clear_marks()
			Match.started = true
			run_left = 0.85
			_paint_countdown("RUN!")
		_follow_spectate(delta)
		return
	_paint_board()
	_follow_spectate(delta)
	race_clock += delta
	if settle >= 0.0:
		settle += delta
	elif _everyone_finished() or (first_finish_clock >= 0.0 and race_clock >= first_finish_clock + 60.0):
		settle = 0.0
	_maybe_end(lead)


func _maybe_end(runner) -> void:
	var limit := map_minutes * 60.0 * 1.5 + 25.0
	var solo := Match.practice and not Match.fill_bots
	if solo:
		if (runner.finished and settle > 1.4) or race_clock > limit:
			_show_results()
		return
	var all := _everyone_finished() and settle > 1.2
	var minute := first_finish_clock >= 0.0 and race_clock >= first_finish_clock + 60.0
	var abandoned := first_finish_clock < 0.0 and race_clock > limit
	if not all and not minute and not abandoned:
		return
	if Network.is_online() and multiplayer.is_server():
		close_race.rpc(_qualifier_pack())
		return
	if Network.is_online() and not minute and not abandoned and settle < 3.0:
		return
	_show_results()


func _clock_text(seconds: float) -> String:
	var t := maxf(0.0, seconds)
	var m := int(t) / 60
	return "%d:%05.2f" % [m, t - float(m * 60)]


func _paint_board() -> void:
	if board_list == null:
		return
	var rows := _board_rows()
	var notes: PackedStringArray = PackedStringArray()
	if _cut_done:
		notes.append("Eliminated")
	elif first_finish_clock >= 0.0 and not _everyone_finished():
		var left := 60.0 - (race_clock - first_finish_clock)
		if left > 0.0:
			notes.append("DNF in %d" % int(ceil(left)))
	var count := rows.size() + notes.size()
	while board_list.get_child_count() < count:
		board_list.add_child(_board_line())
	var i := 0
	for row in rows:
		var line := board_list.get_child(i) as Label
		line.visible = true
		line.text = "%s   %s" % [_ordinal(i + 1), str(row["name"])]
		line.label_settings.font_color = Color("8dffc4") if bool(row["finished"]) else ink
		i += 1
	for note in notes:
		var line := board_list.get_child(i) as Label
		line.visible = true
		line.text = note
		line.label_settings.font_color = ink
		i += 1
	while i < board_list.get_child_count():
		board_list.get_child(i).visible = false
		i += 1


func _board_line() -> Label:
	var line := Label.new()
	line.custom_minimum_size = Vector2(400, 0)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings := LabelSettings.new()
	settings.font_size = 18
	settings.font_color = ink
	settings.outline_size = 7
	settings.outline_color = Color(0.04, 0.03, 0.02, 0.88)
	line.label_settings = settings
	return line


func _board_rows() -> Array:
	var rows: Array = []
	for node in players.get_children():
		var stamp := float(node.race_time)
		var done := bool(node.finished)
		for row in finishes:
			if str(row["id"]) != str(node.name):
				continue
			done = true
			stamp = float(row["time"])
			break
		rows.append({
			"name": str(node.display_name),
			"time": stamp,
			"finished": done,
			"cp": int(node.checkpoint_index),
			"z": float(node.global_position.z),
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if bool(a["finished"]) != bool(b["finished"]):
			return bool(a["finished"])
		if bool(a["finished"]):
			return float(a["time"]) < float(b["time"])
		if int(a["cp"]) != int(b["cp"]):
			return int(a["cp"]) > int(b["cp"])
		return float(a["z"]) < float(b["z"])
	)
	return rows


func _spectate_targets() -> Array:
	var racing: Array = []
	var done: Array = []
	for node in players.get_children():
		if node.view_player:
			continue
		if node.finished:
			done.append(node)
		else:
			racing.append(node)
	if not racing.is_empty():
		return racing
	return done


func _spectate() -> void:
	var targets := _spectate_targets()
	if targets.is_empty():
		spectate_i = -1
		return
	spectate_i += 1
	if spectate_i >= targets.size():
		spectate_i = -1
		spectate_button.text = "Spectate"
		return
	spectate_button.text = "Next"


func _follow_spectate(delta: float) -> void:
	if spectate_cam == null:
		return
	var local = _view_player()
	var target = null
	if spectate_i >= 0:
		var targets := _spectate_targets()
		if targets.is_empty():
			spectate_i = -1
		else:
			if spectate_i >= targets.size():
				spectate_i = 0
			target = targets[spectate_i]
	elif local != null and bool(local.finished):
		target = local
	if target == null:
		spectate_cam.current = false
		return
	var behind: Vector3 = target.global_position + target.global_transform.basis.z * 4.2 + Vector3(0, 2.15, 0)
	var aim: Vector3 = target.global_position + Vector3(0, 1.15, 0)
	if spectate_cam.global_position.distance_to(behind) > 40.0:
		spectate_cam.global_position = behind
	else:
		spectate_cam.global_position = spectate_cam.global_position.lerp(behind, 1.0 - exp(-7.0 * delta))
	spectate_cam.look_at(aim)
	spectate_cam.current = true
	if local != null and local.camera != null:
		local.camera.current = false


func _refresh_emotes(done: bool) -> void:
	if emote_row == null:
		return
	emote_row.visible = done and not Match.audit
	if not done:
		return
	var lv := Profile.reward_level()
	for button in emote_row.get_children():
		var need := int(button.get_meta("emote_level"))
		var open := need <= lv
		button.visible = true
		button.disabled = not open
		if open:
			button.text = str(button.get_meta("emote_id")).capitalize()
		else:
			button.text = "Lv %d" % need


func _play_emote(id: String) -> void:
	var runner = _view_player()
	if runner != null and runner.has_method("play_emote"):
		runner.play_emote(id)


@rpc("authority", "call_local", "reliable")
func close_race(pack: Array = []) -> void:
	if not pack.is_empty():
		Match.keep(pack, true)
	_show_results()


func runner_finished(runner) -> void:
	var id := str(runner.name)
	var dname := str(runner.display_name)
	var stamp := float(runner.race_time)
	if _known(id):
		return
	_remember(id, dname, stamp)
	if not Network.is_online():
		return
	if multiplayer.is_server():
		note_finish.rpc(id, dname, stamp)
	else:
		submit_finish.rpc_id(1, id, dname, stamp)


func _check_cut() -> void:
	if _cut_done or ended:
		return
	if not Match.series or Match.on_final():
		return
	if finishes.size() < Match.cut_line():
		return
	if Network.is_online():
		if multiplayer.is_server():
			cut_field.rpc()
		return
	cut_field()


@rpc("authority", "call_local", "reliable")
func cut_field() -> void:
	if _cut_age >= 0.0:
		return
	_cut_done = true
	_cut_age = 0.0
	_show_on_screens("ELIMINATED")
	if players == null:
		return
	for node in players.get_children():
		if bool(node.finished):
			continue
		if node.has_method("eliminate"):
			node.eliminate()


func _tick_cut(delta: float) -> void:
	if _cut_age < 0.0 or _cut_sent or ended:
		return
	_cut_age += delta
	if _cut_age < 2.6:
		return
	_cut_sent = true
	if Network.is_online():
		if multiplayer.is_server():
			close_race.rpc(_qualifier_pack())
		return
	_show_results()


func _known(id: String) -> bool:
	for row in finishes:
		if str(row["id"]) == id:
			return true
	return false


func _remember(id: String, dname: String, stamp: float) -> void:
	if _known(id):
		return
	var first := finishes.is_empty()
	finishes.append({"id": id, "name": dname, "time": stamp})
	if first_finish_clock < 0.0:
		first_finish_clock = race_clock
	if first:
		var winner := players.get_node_or_null(id)
		if winner != null:
			winner.won = true
	var runner := players.get_node_or_null(id)
	if runner != null and bool(runner.is_bot) and not bool(runner.won) and runner.has_method("queue_cheer"):
		runner.queue_cheer()
	_check_cut()


func _show_results() -> void:
	if ended:
		return
	ended = true
	var rows: Array = []
	for node in players.get_children():
		var found := {}
		for row in finishes:
			if str(row["id"]) == str(node.name):
				found = row
				break
		var did := bool(node.finished) or not found.is_empty()
		var stamp := float(node.race_time)
		if not found.is_empty():
			stamp = float(found["time"])
		rows.append({
			"id": str(node.name),
			"name": str(node.display_name),
			"time": stamp,
			"finished": did,
			"progress": float(node.checkpoint_index) * 100000.0 - node.global_position.z,
			"bot": bool(node.is_bot),
			"color": node.player_color.to_html(false),
			"hat": str(node.worn_hat),
			"style": str(node.worn_style),
			"trail": str(node.worn_trail),
			"seed": (int(node.get_meta("bot_seed")) if node.has_meta("bot_seed") else int(node.spawn_slot)),
		})
	rows.sort_custom(func(a, b):
		if bool(a["finished"]) != bool(b["finished"]):
			return bool(a["finished"])
		if bool(a["finished"]):
			return float(a["time"]) < float(b["time"])
		return float(a["progress"]) > float(b["progress"])
	)
	if Match.series:
		Match.keep(rows)
	Match.results = []
	var place := 1
	for row in rows:
		var you := false
		var node := players.get_node_or_null(str(row["id"]))
		if node != null and node.view_player:
			you = true
			Match.your_place = place
			Match.your_finished = bool(row["finished"])
			Match.your_falls = int(node.falls)
			Match.your_time = float(row["time"])
			Match.field_size = rows.size()
			Match.ran = true
		var clock := _clock_text(float(row["time"]))
		if not bool(row["finished"]):
			if Match.series and not Match.on_final():
				clock = "Eliminated"
			else:
				clock += " DNF"
		Match.results.append({
			"place": place,
			"name": str(row["name"]),
			"clock": clock,
			"you": you,
			"style": str(row["style"]),
			"color": str(row["color"]),
			"finished": bool(row["finished"]),
		})
		place += 1
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var scene := "res://scenes/podium.tscn" if _podium_now() else "res://scenes/results.tscn"
	get_tree().change_scene_to_file(scene)


func _podium_now() -> bool:
	if Match.practice or Match.battle or Match.challenge or Match.audit:
		return false
	if Match.series and not Match.on_final():
		return false
	for row in Match.results:
		if int(row["place"]) != 1:
			continue
		return bool(row.get("finished", false))
	return false


func _pad_connected() -> bool:
	return Input.get_connected_joypads().size() > 0


func _pb_text() -> String:
	if Match.previous_pb < 0.0:
		return "PB none"
	return "PB %s" % GhostStore.format_clock(Match.previous_pb)


func _spawn_ghost(samples: PackedFloat32Array) -> void:
	ghost = GhostScript.new()
	ghost.name = "Ghost"
	add_child(ghost)
	ghost.setup(samples, Profile.player_color())


func _record(runner, force: bool) -> void:
	if not Match.speedrun or runner == null:
		return
	var t := float(runner.race_time)
	var pos: Vector3 = runner.global_position
	var yaw := float(runner.rotation.y)
	var n := tape.size() / GhostStore.STRIDE
	if n > 0:
		var last_t := tape[(n - 1) * GhostStore.STRIDE]
		var last_pos := Vector3(
			tape[(n - 1) * GhostStore.STRIDE + 1],
			tape[(n - 1) * GhostStore.STRIDE + 2],
			tape[(n - 1) * GhostStore.STRIDE + 3]
		)
		var jumped := last_pos.distance_to(pos) > 6.0
		if is_equal_approx(t, last_t):
			return
		if not force and not jumped and t - last_t < 1.0 / 30.0:
			return
	tape.append(t)
	tape.append(pos.x)
	tape.append(pos.y)
	tape.append(pos.z)
	tape.append(yaw)


func _commit_pb(runner) -> void:
	if pb_committed or not Match.speedrun or not runner.finished:
		return
	pb_committed = true
	var time := float(runner.race_time)
	if Match.previous_pb < 0.0 or time < Match.previous_pb:
		if GhostStore.save_run(Match.map_id, time, tape):
			Match.beat_pb = true
			Match.pb_time = time
			return
	Match.beat_pb = false
	Match.pb_time = Match.previous_pb


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not ended:
		var runner = _view_player()
		if runner != null and runner.finished:
			var keys: Array[int] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7]
			var idx := keys.find(int(event.physical_keycode))
			if idx >= 0 and idx < Emotes.all().size():
				get_viewport().set_input_as_handled()
				_play_emote(str(Emotes.all()[idx]["id"]))
				return
	if event.is_action_pressed("ui_cancel") and not ended and not Match.audit:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			get_viewport().set_input_as_handled()
			_back()
			return
	if Network.is_online() or ended:
		return
	if event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		Curtain.again("Loading the roof.")


func _back() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Match.challenge and not Network.is_online():
		get_tree().change_scene_to_file("res://scenes/challenge.tscn")
		return
	if Match.battle and not Network.is_online():
		Match.picking_battle = true
		get_tree().change_scene_to_file("res://scenes/practice.tscn")
		return
	if Match.practice and not Network.is_online():
		get_tree().change_scene_to_file("res://scenes/practice.tscn")
		return
	_leave()


func _leave() -> void:
	if multiplayer.server_disconnected.is_connected(_leave):
		multiplayer.server_disconnected.disconnect(_leave)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Network.offline()
	Curtain.go("res://scenes/menu.tscn", "Loading.")


func _on_peer_left(id: int) -> void:
	drop_runner.rpc(str(id))
	if Match.fill_bots:
		call_deferred("_fill_bots")


func _qualifier_pack() -> Array:
	var pack: Array = []
	for node in players.get_children():
		var found := {}
		for row in finishes:
			if str(row["id"]) == str(node.name):
				found = row
				break
		var did := bool(node.finished) or not found.is_empty()
		var stamp := float(node.race_time)
		if not found.is_empty():
			stamp = float(found["time"])
		pack.append({
			"id": str(node.name),
			"name": str(node.display_name),
			"time": stamp,
			"finished": did,
			"progress": float(node.checkpoint_index) * 100000.0 - node.global_position.z,
			"bot": bool(node.is_bot),
			"color": node.player_color.to_html(false),
			"hat": str(node.worn_hat),
			"style": str(node.worn_style),
			"trail": str(node.worn_trail),
			"seed": (int(node.get_meta("bot_seed")) if node.has_meta("bot_seed") else int(node.spawn_slot)),
		})
	pack.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if bool(a["finished"]) != bool(b["finished"]):
			return bool(a["finished"])
		if bool(a["finished"]):
			return float(a["time"]) < float(b["time"])
		return float(a["progress"]) > float(b["progress"])
	)
	return pack


func _field_cap() -> int:
	if Match.series:
		return Match.round_size()
	return Network.LOBBY


func _spawn_qualifiers() -> void:
	var slot := 0
	for row in Match.qualifiers:
		var bot := bool(row["bot"])
		var mine := Match.is_me(row)
		var id := str(row["id"])
		var dname := str(row["name"])
		var tint := Color.html(str(row["color"]))
		var hat := str(row["hat"])
		var style := str(row["style"])
		var trail := str(row["trail"])
		if mine:
			id = "you" if not Network.is_online() else str(multiplayer.get_unique_id())
			bot = false
			dname = Profile.screen_name()
			tint = Profile.player_color()
			hat = Profile.hat_id()
			style = Profile.style_id()
			trail = Profile.trail_id()
		if Network.is_online():
			spawn_runner.rpc(id, slot, bot, dname, tint, hat, style, trail)
		else:
			_add_runner(id, slot, bot, mine, bot, dname, tint, hat, style, trail)
		var body: Node = players.get_node_or_null(id)
		if body != null:
			body.set_meta("bot_seed", int(row["seed"]))
		slot += 1


func _fill_bots() -> void:
	if Network.is_online() and not multiplayer.is_server():
		return
	var cap := _field_cap()
	var guard := 0
	while _roster() < cap and guard < cap + 2:
		guard += 1
		var n := 2
		while players.has_node("bot%d" % n):
			n += 1
		var slot := _take_slot()
		var dname := _bot_name()
		var tint: Color = COLORS[slot % COLORS.size()]
		var hat := "cap"
		var style := Styles.random_id()
		var trail := Trails.for_slot(slot)
		if Network.is_online():
			spawn_runner.rpc("bot%d" % n, slot, true, dname, tint, hat, style, trail)
		else:
			_add_runner("bot%d" % n, slot, true, false, true, dname, tint, hat, style, trail)


func _bot_name() -> String:
	var used := {}
	for child in players.get_children():
		if bool(child.get("is_bot")):
			used[str(child.display_name)] = true
	return Names.take(used)


func _a_bot():
	for child in players.get_children():
		if str(child.name).begins_with("bot"):
			return child
	return null


@rpc("any_peer", "reliable")
func request_spawn(dname: String, hue: float, hat: String, style: String, trail: String) -> void:
	if not multiplayer.is_server():
		return
	var id := multiplayer.get_remote_sender_id()
	var sid := str(id)
	if players.has_node(sid):
		for child in players.get_children():
			spawn_runner.rpc_id(id, str(child.name), int(child.spawn_slot), bool(child.is_bot), str(child.display_name), child.player_color, str(child.worn_hat), str(child.worn_style), str(child.worn_trail))
		return
	if Match.series and Match.round_index > 0:
		for child in players.get_children():
			spawn_runner.rpc_id(id, str(child.name), int(child.spawn_slot), bool(child.is_bot), str(child.display_name), child.player_color, str(child.worn_hat), str(child.worn_style), str(child.worn_trail))
		return
	if players.get_child_count() >= _field_cap():
		var bot = _a_bot()
		if bot != null:
			drop_runner.rpc(str(bot.name))
	for child in players.get_children():
		spawn_runner.rpc_id(id, str(child.name), int(child.spawn_slot), bool(child.is_bot), str(child.display_name), child.player_color, str(child.worn_hat), str(child.worn_style), str(child.worn_trail))
	var slot := _take_slot()
	spawn_runner.rpc(str(id), slot, false, Profile.sanitize_name(dname), Profile.color_from_hue(hue), hat, style, trail)


@rpc("authority", "call_local", "reliable")
func spawn_runner(id: String, slot: int, bot: bool, dname: String, tint: Color, hat: String, style: String, trail: String) -> void:
	if _booting:
		_queued.append([id, slot, bot, dname, tint, hat, style, trail])
		return
	var view := false
	if Network.is_online():
		view = (not bot) and id.is_valid_int() and int(id) == multiplayer.get_unique_id()
	else:
		view = slot == 0 and not bot
	_add_runner(id, slot, bot, view, bot and not Match.audit, dname, tint, hat, style, trail)


@rpc("authority", "call_local", "reliable")
func drop_runner(id: String) -> void:
	var node := players.get_node_or_null(id)
	if node == null:
		return
	players.remove_child(node)
	node.queue_free()


@rpc("any_peer", "reliable")
func submit_finish(id: String, dname: String, stamp: float) -> void:
	if not multiplayer.is_server():
		return
	note_finish.rpc(id, dname, stamp)


@rpc("authority", "call_local", "reliable")
func note_finish(id: String, dname: String, stamp: float) -> void:
	_remember(id, dname, stamp)
	var node := players.get_node_or_null(id)
	if node == null:
		return
	node.race_time = stamp
	if not node.finished:
		node.finished = true


func _add_runner(id: String, slot: int, bot: bool, view: bool, rival: bool, dname: String, tint: Color, hat := "cap", style := "bulbous", trail := "off") -> void:
	if players.has_node(id) or players.get_child_count() >= _field_cap():
		_held_slots.erase(slot)
		return
	var runner = PlayerScript.new()
	runner.name = id
	runner.spawn_slot = slot
	runner.player_color = tint
	runner.worn_hat = hat if hat != "" else "cap"
	runner.worn_style = style if style != "" else "bulbous"
	runner.worn_trail = trail if trail != "" else "off"
	runner.display_name = dname
	runner.is_bot = bot
	runner.rival = rival
	runner.view_player = view
	runner.lane_bias = LANES[slot % LANES.size()]
	var feet := _open_start(slot)
	runner.checkpoint_pos = feet
	runner.position = feet
	if Network.is_online():
		var auth := 1 if bot or not id.is_valid_int() else int(id)
		runner.set_multiplayer_authority(auth)
	players.add_child(runner)
	runner.on_marks = not Match.started
	var persona := slot
	for row in Match.qualifiers:
		if str(row["id"]) == id or (view and Match.is_me(row)):
			persona = int(row["seed"])
			break
	runner.set_meta("bot_seed", persona)
	var grounded: Vector3 = runner.place_on_roof(feet)
	runner.checkpoint_pos = grounded
	runner.global_position = grounded
	_held_slots.erase(slot)


func _roster() -> int:
	return players.get_child_count() + _held_slots.size()


func _take_slot() -> int:
	var used := {}
	for child in players.get_children():
		used[int(child.spawn_slot)] = true
	for held in _held_slots:
		used[int(held)] = true
	var n := 0
	while used.has(n):
		n += 1
	_held_slots.append(n)
	return n


func _open_start(slot: int) -> Vector3:
	var first := posmod(slot, spawn_points.size())
	if not _start_busy(spawn_points[first]):
		return spawn_points[first]
	for i in spawn_points.size():
		if not _start_busy(spawn_points[i]):
			return spawn_points[i]
	var spill := spawn_points[first]
	return spill + Vector3(0.0, 0.2, 1.2 + float(slot))


func _start_busy(spot: Vector3) -> bool:
	for child in players.get_children():
		var flat := Vector2(child.position.x - spot.x, child.position.z - spot.z)
		if flat.length() < 0.95:
			return true
	return false
