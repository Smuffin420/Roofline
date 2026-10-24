extends Control

const ThemeLib := preload("res://scripts/theme.gd")
const MannequinScript := preload("res://scripts/mannequin.gd")
const Styles := preload("res://scripts/styles.gd")
const Trails := preload("res://scripts/trails.gd")

var status: Label
var name_box: LineEdit
var spin_slider: HSlider
var preview
var body_note: Label
var body_left: Button
var body_right: Button
var _body_index := 0
var trail_note: Label
var trail_left: Button
var trail_right: Button
var _trail_index := 0
var sheet: Control
var _step := ""
var _listing := false
var _joining := false
var _holding := false
var _join_wait := 0.0
var _room_stamp := ""
var _join_note := ""
var _typed_ip := ""
var _quick := false
var _quick_wait := 0.0
var _home: Control
var _reveal := 0.0
var _tab := "run"
var _scope := "self"
var _board_mode := "practice"
var _run_box: VBoxContainer
var _board_box: VBoxContainer
var _board_list: VBoxContainer
var _run_tab: Button
var _board_tab: Button
var _scope_buttons := {}
var _mode_buttons := {}
var _next_label: Label
var _dev_switch: Control
var _dev_knob: Control
var _dev_track: StyleBoxFlat


func _ready() -> void:
	Match.clear_series()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ThemeLib.make()

	add_child(_backdrop())

	_home = MarginContainer.new()
	_home.set_anchors_preset(Control.PRESET_FULL_RECT)
	_home.add_theme_constant_override("margin_left", 36)
	_home.add_theme_constant_override("margin_right", 36)
	_home.add_theme_constant_override("margin_top", 10)
	_home.add_theme_constant_override("margin_bottom", 40)
	_home.modulate.a = 0.0
	add_child(_home)
	_dev_switch = _make_dev_switch()
	add_child(_dev_switch)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 48)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_home.add_child(row)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(480, 0)
	left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override("separation", 3)
	var left_card := _paper()
	left_card.add_child(left)
	row.add_child(left_card)

	left.add_child(_label("THREE ROUNDS  ·  ONE TROPHY", 16, Color("e23b2f")))
	left.add_child(_label("ROOFLINE", 48, Color("1c1915")))
	left.add_child(_label(str(ProjectSettings.get_setting("application/config/version", "0.3.15")), 16, Color("5c564e")))
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	_run_tab = _button("Run", func() -> void: _show_tab("run"))
	_board_tab = _button("Leaderboard", func() -> void: _show_tab("board"))
	_run_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_run_tab.custom_minimum_size = Vector2(0, 36)
	_board_tab.custom_minimum_size = Vector2(0, 36)
	tabs.add_child(_run_tab)
	tabs.add_child(_board_tab)
	left.add_child(tabs)

	_run_box = VBoxContainer.new()
	_run_box.add_theme_constant_override("separation", 3)
	left.add_child(_run_box)
	var career := _label("Level %d    ·    %s" % [Profile.level(), Profile.trophy_label()], 18, Color("1c1915"))
	_run_box.add_child(career)
	_run_box.add_child(ThemeLib.bar(Profile.level_progress(), 480))
	_next_label = _label("", 15, Color("5c564e"))
	_run_box.add_child(_next_label)
	_paint_next()

	var play := _button("Play", _play)
	_run_box.add_child(play)
	_run_box.add_child(_button("Practice", _practice))
	_run_box.add_child(_button("Challenge", _challenge))
	_run_box.add_child(_button("Battle", _battle))
	_run_box.add_child(_button("Host a room", _ask_host))
	_run_box.add_child(_button("Join", func() -> void: _ask_join()))
	_run_box.add_child(_button("Settings", _settings))
	_run_box.add_child(_button("Quit", _quit))

	status = _label("", 16, Color("e23b2f"))
	status.visible = false
	_run_box.add_child(status)
	var rates := _label("Three rounds. Twenty, then ten, then five. A later round pays more for the same place. One crown, for the winner of the final. Battle pays half, with no crown. Practice pays nothing.", 15, Color("5c564e"))
	rates.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rates.custom_minimum_size = Vector2(460, 0)
	_run_box.add_child(rates)
	for child in _run_box.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(0, 38)
	_board_box = _make_board()
	_board_box.visible = false
	left.add_child(_board_box)
	_paint_tabs()

	var identity := _identity()
	var right_card := _paper()
	right_card.add_child(identity)
	row.add_child(right_card)
	var hue_slider: HSlider = identity.get_meta("hue_slider")
	play.focus_neighbor_right = play.get_path_to(hue_slider)
	hue_slider.focus_neighbor_left = hue_slider.get_path_to(play)
	hue_slider.focus_neighbor_top = hue_slider.get_path_to(name_box)
	name_box.focus_neighbor_bottom = name_box.get_path_to(hue_slider)
	name_box.focus_neighbor_left = name_box.get_path_to(play)
	name_box.focus_neighbor_top = name_box.get_path_to(spin_slider)
	spin_slider.focus_neighbor_top = spin_slider.get_path_to(trail_left)
	spin_slider.focus_neighbor_bottom = spin_slider.get_path_to(name_box)
	spin_slider.focus_neighbor_left = spin_slider.get_path_to(play)
	body_left.focus_neighbor_right = body_left.get_path_to(body_right)
	body_right.focus_neighbor_left = body_right.get_path_to(body_left)
	body_left.focus_neighbor_top = body_left.get_path_to(spin_slider)
	body_right.focus_neighbor_top = body_right.get_path_to(spin_slider)
	body_left.focus_neighbor_bottom = body_left.get_path_to(trail_left)
	body_right.focus_neighbor_bottom = body_right.get_path_to(trail_right)
	trail_left.focus_neighbor_right = trail_left.get_path_to(trail_right)
	trail_right.focus_neighbor_left = trail_right.get_path_to(trail_left)
	trail_left.focus_neighbor_top = trail_left.get_path_to(body_left)
	trail_right.focus_neighbor_top = trail_right.get_path_to(body_right)
	trail_left.focus_neighbor_bottom = trail_left.get_path_to(spin_slider)
	trail_right.focus_neighbor_bottom = trail_right.get_path_to(spin_slider)

	Network.join_accepted.connect(_enter_room)
	Network.join_denied.connect(_join_failed)
	Network.need_password.connect(_need_password)
	if OS.get_environment("ROOFLINE_BOT") == "1":
		call_deferred("_solo")
	elif OS.get_environment("ROOFLINE_FIELD") == "1":
		call_deferred("_field_race")
	elif OS.get_environment("ROOFLINE_BATTLE") == "1":
		call_deferred("_battle")
	elif OS.get_environment("ROOFLINE_HOST") == "1":
		call_deferred("_confirm_host_text", "%s room" % Profile.screen_name(), "")
	elif OS.get_environment("ROOFLINE_JOIN") == "1":
		call_deferred("_confirm_join", "127.0.0.1", "")
	else:
		play.call_deferred("grab_focus")
	if Network.notice != "":
		status.text = Network.notice
		status.visible = true
		Network.notice = ""
	if not get_tree().root.close_requested.is_connected(_commit_identity):
		get_tree().root.close_requested.connect(_commit_identity)


func _process(_delta: float) -> void:
	if _dev_switch:
		_dev_switch.position = Vector2(18, size.y - 72)
		_dev_switch.visible = _step == ""
	if _reveal < 1.0:
		_reveal = minf(1.0, _reveal + _delta * 1.7)
		var fade := _reveal * _reveal * (3.0 - 2.0 * _reveal)
		if _home:
			_home.modulate.a = fade
		if _dev_switch:
			_dev_switch.modulate.a = fade
	if _listing and _step == "list":
		var stamp := Network.room_stamp()
		if stamp != _room_stamp:
			_room_stamp = stamp
			_paint_rooms()
	if _quick and _step == "quick":
		_quick_wait += _delta
		var room := _next_open_room()
		if not room.is_empty() and _quick_wait >= 0.8:
			_quick = false
			_confirm_join(str(room["ip"]), "", "Joining the next available lobby.")
		elif _quick_wait >= 1.6:
			_enter_local_lobby()
	if _joining:
		_join_wait += _delta
		if _join_wait > 8.0:
			_joining = false
			Network.cancel_join()
			_ask_join("The room did not answer.")


func _unhandled_input(event: InputEvent) -> void:
	if _step == "" or not event.is_action_pressed("ui_cancel"):
		return
	if _step == "joining" or _holding:
		_cancel_join()
	elif _step == "password":
		_ask_join(_join_note)
	else:
		_close_sheet()
	get_viewport().set_input_as_handled()


func _backdrop() -> Control:
	var stack := Control.new()
	stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.color = Color("e7b56a")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(bg)
	var fly: TextureRect = (load("res://scripts/home_fly.gd") as GDScript).new() as TextureRect
	fly.set_anchors_preset(Control.PRESET_FULL_RECT)
	fly.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fly.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fly.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(fly)
	var wash := ColorRect.new()
	wash.color = Color(0.91, 0.71, 0.42, 0.16)
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(wash)
	return stack


func _paper() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var box := StyleBoxFlat.new()
	box.bg_color = Color("efe8dc")
	box.set_corner_radius_all(2)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", box)
	return panel


func _identity() -> Control:
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(380, 0)
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	column.add_theme_constant_override("separation", 8)
	column.add_child(_stage())
	spin_slider = HSlider.new()
	spin_slider.min_value = -180.0
	spin_slider.max_value = 180.0
	spin_slider.step = 1.0
	spin_slider.value = 0.0
	spin_slider.custom_minimum_size = Vector2(0, 36)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("d9d0c3")
	track.set_corner_radius_all(2)
	track.content_margin_top = 14
	track.content_margin_bottom = 14
	spin_slider.add_theme_stylebox_override("slider", track)
	spin_slider.value_changed.connect(_on_spin)
	column.add_child(spin_slider)

	name_box = LineEdit.new()
	name_box.text = Profile.screen_name()
	name_box.max_length = 16
	name_box.placeholder_text = "Screen name"
	name_box.custom_minimum_size = Vector2(0, 44)
	name_box.text_changed.connect(_on_name)
	name_box.focus_exited.connect(_commit_identity)
	column.add_child(name_box)
	column.add_child(_label("Your name stays on this computer.", 14, Color("5c564e")))

	column.add_child(_label("Color", 16, Color("1c1915")))
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(380, 36)
	var bar := _hue_bar()
	bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar.offset_top = 11
	bar.offset_bottom = -11
	stack.add_child(bar)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.001
	slider.value = Profile.hue
	slider.set_anchors_preset(Control.PRESET_FULL_RECT)
	slider.value_changed.connect(_on_hue)
	stack.add_child(slider)
	column.add_child(stack)
	column.set_meta("hue_slider", slider)
	return column


func _stage() -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(380, 420)
	wrap.add_child(_hat_cluster())
	call_deferred("_mount_preview", wrap)
	return wrap


func _mount_preview(wrap: Control) -> void:
	if not is_instance_valid(wrap):
		return
	var frame := SubViewportContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.stretch = true
	var viewport := SubViewport.new()
	viewport.size = Vector2i(380, 420)
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.handle_input_locally = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	frame.add_child(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("efe8dc")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("fff6ea")
	env.ambient_light_energy = 0.9
	env_node.environment = env
	world.add_child(env_node)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-42, 36, 0)
	key.light_color = Color(1.0, 0.94, 0.84)
	key.light_energy = 1.15
	world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-18, -148, 0)
	fill.light_energy = 0.35
	fill.light_color = Color("c5d4e4")
	world.add_child(fill)

	var disc := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.78
	cylinder.bottom_radius = 0.78
	cylinder.height = 0.04
	disc.mesh = cylinder
	disc.position.y = 0.02
	var deck := StandardMaterial3D.new()
	deck.albedo_color = Color("cfc6b8")
	deck.roughness = 0.92
	disc.material_override = deck
	world.add_child(disc)
	var backdrop := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(9.0, 9.0)
	backdrop.mesh = quad
	backdrop.position = Vector3(0.15, 1.45, 1.8)
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color("efe8dc")
	paper.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper.cull_mode = BaseMaterial3D.CULL_DISABLED
	backdrop.material_override = paper
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(backdrop)

	preview = MannequinScript.new()
	preview.tint = Profile.player_color()
	preview.name_text = Profile.screen_name()
	preview.name_size = 64
	preview.style_id = Profile.style_id()
	preview.trail_id = Profile.trail_id()
	preview.trail_preview = true
	_body_index = Styles.index_of(Profile.style_id())
	_trail_index = Trails.index_of(Profile.trail_id())
	world.add_child(preview)

	var camera := Camera3D.new()
	camera.fov = 36
	camera.look_at_from_position(Vector3(0.62, 1.48, -2.7), Vector3(0, 1.38, 0))
	camera.current = true
	world.add_child(camera)
	wrap.add_child(frame)
	wrap.move_child(frame, 0)


func _hat_cluster() -> Control:
	var cluster := VBoxContainer.new()
	cluster.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	cluster.offset_left = -168
	cluster.offset_right = -8
	cluster.offset_top = 188
	cluster.offset_bottom = 320
	cluster.add_theme_constant_override("separation", 0)
	cluster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var body_row := HBoxContainer.new()
	body_row.alignment = BoxContainer.ALIGNMENT_CENTER
	body_row.add_theme_constant_override("separation", 2)
	body_left = _picker_button("‹", _shift_style.bind(-1))
	body_right = _picker_button("›", _shift_style.bind(1))
	var body_word := _label("body", 20, Color("1c1915"))
	body_word.custom_minimum_size = Vector2(64, 36)
	body_word.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_row.add_child(body_left)
	body_row.add_child(body_word)
	body_row.add_child(body_right)
	cluster.add_child(body_row)
	body_note = _label("", 13, Color("5c564e"))
	body_note.custom_minimum_size = Vector2(148, 18)
	cluster.add_child(body_note)
	var trail_row := HBoxContainer.new()
	trail_row.alignment = BoxContainer.ALIGNMENT_CENTER
	trail_row.add_theme_constant_override("separation", 2)
	trail_left = _picker_button("‹", _shift_trail.bind(-1))
	trail_right = _picker_button("›", _shift_trail.bind(1))
	var trail_word := _label("trail", 20, Color("1c1915"))
	trail_word.custom_minimum_size = Vector2(64, 36)
	trail_word.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	trail_row.add_child(trail_left)
	trail_row.add_child(trail_word)
	trail_row.add_child(trail_right)
	cluster.add_child(trail_row)
	trail_note = _label("", 13, Color("5c564e"))
	trail_note.custom_minimum_size = Vector2(148, 18)
	cluster.add_child(trail_note)
	_show_style()
	_show_trail()
	return cluster


func _picker_button(glyph: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = glyph
	button.custom_minimum_size = Vector2(36, 36)
	button.focus_mode = Control.FOCUS_ALL
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("focus", empty)
	button.add_theme_color_override("font_color", Color("1c1915"))
	button.add_theme_color_override("font_hover_color", Color("e23b2f"))
	button.add_theme_color_override("font_pressed_color", Color("9d241c"))
	button.add_theme_color_override("font_focus_color", Color("e23b2f"))
	button.add_theme_font_size_override("font_size", 28)
	button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	button.pressed.connect(action)
	return button


func _shift_style(delta: int) -> void:
	var catalog := Styles.all()
	_body_index = posmod(_body_index + delta, catalog.size())
	_show_style()


func _shift_trail(delta: int) -> void:
	var catalog := Trails.all()
	_trail_index = posmod(_trail_index + delta, catalog.size())
	_show_trail()


func _make_dev_switch() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.focus_mode = Control.FOCUS_NONE
	row.modulate.a = 0.0
	row.custom_minimum_size = Vector2(78, 20)
	row.gui_input.connect(_on_dev_click)
	var track := Panel.new()
	track.custom_minimum_size = Vector2(30, 16)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dev_track = StyleBoxFlat.new()
	_dev_track.bg_color = Color("cfc6b8")
	_dev_track.set_corner_radius_all(8)
	track.add_theme_stylebox_override("panel", _dev_track)
	_dev_knob = Panel.new()
	_dev_knob.custom_minimum_size = Vector2(12, 12)
	_dev_knob.size = Vector2(12, 12)
	_dev_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color = Color("efe8dc")
	knob_style.set_corner_radius_all(6)
	_dev_knob.add_theme_stylebox_override("panel", knob_style)
	track.add_child(_dev_knob)
	row.add_child(track)
	var word := _label("Dev", 13, Color("5c564e"))
	word.autowrap_mode = TextServer.AUTOWRAP_OFF
	word.custom_minimum_size = Vector2(36, 18)
	word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	word.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(word)
	_paint_dev_switch()
	row.reset_size()
	return row


func _on_dev_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_unlock()


func _paint_dev_switch() -> void:
	if _dev_knob == null or _dev_track == null:
		return
	var on := Profile.dev_unlock
	_dev_knob.position = Vector2(16 if on else 2, 2)
	_dev_track.bg_color = Color("e23b2f") if on else Color("cfc6b8")


func _paint_next() -> void:
	if _next_label == null:
		return
	var nxt := Profile.next_unlock(Profile.level())
	if nxt.is_empty():
		_next_label.text = "Every reward is unlocked."
	else:
		_next_label.text = "Next, level %s: %s." % [str(nxt["level"]), str(nxt["name"])]


func _toggle_unlock() -> void:
	Sfx.play("click", -8.0)
	Profile.set_dev_unlock(not Profile.dev_unlock)
	_paint_dev_switch()
	_body_index = Styles.index_of(Profile.style_id())
	_trail_index = Trails.index_of(Profile.trail_id())
	_show_style()
	_show_trail()


func _show_trail() -> void:
	var item: Dictionary = Trails.all()[_trail_index]
	var id := str(item["id"])
	if preview and preview.has_method("set_trail"):
		preview.set_trail(id)
	var open := Trails.is_open(id, Profile.reward_level())
	if open:
		Profile.set_trail(id)
		trail_note.text = str(item["name"])
		trail_note.add_theme_color_override("font_color", Color("5c564e"))
	else:
		trail_note.text = "Level %s" % str(item["level"])
		trail_note.add_theme_color_override("font_color", Color("e23b2f"))


func _show_style() -> void:
	var item: Dictionary = Styles.all()[_body_index]
	var id := str(item["id"])
	if preview and preview.has_method("set_style"):
		preview.set_style(id)
	var open := Styles.is_open(id, Profile.reward_level())
	if open:
		Profile.set_style(id)
		body_note.text = str(item["name"])
		body_note.add_theme_color_override("font_color", Color("5c564e"))
	else:
		body_note.text = "Level %s" % str(item["level"])
		body_note.add_theme_color_override("font_color", Color("e23b2f"))


func _hue_bar() -> TextureRect:
	var gradient := Gradient.new()
	var offsets := PackedFloat32Array()
	var colors := PackedColorArray()
	for i in 9:
		var t := float(i) / 8.0
		offsets.append(t)
		colors.append(Profile.color_from_hue(t))
	gradient.offsets = offsets
	gradient.colors = colors
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	texture.width = 256
	var bar := TextureRect.new()
	bar.texture = texture
	bar.custom_minimum_size = Vector2(0, 14)
	bar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar.stretch_mode = TextureRect.STRETCH_SCALE
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return bar


func _on_name(text: String) -> void:
	var shown := text.strip_edges()
	if shown.is_empty():
		shown = "Runner"
	if preview and preview.has_method("set_name_text"):
		preview.set_name_text(shown)
	if not text.strip_edges().is_empty():
		Profile.set_screen_name(text)


func _on_spin(value: float) -> void:
	if preview:
		preview.rotation.y = deg_to_rad(value)


func _on_hue(value: float) -> void:
	Profile.set_hue(value)
	if preview and preview.has_method("set_tint"):
		preview.set_tint(Profile.player_color())


func _label(text: String, size: int, color: Color) -> Label:
	var node := Label.new()
	node.text = text
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	return node


func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	button.pressed.connect(callback)
	return button


func _make_board() -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var scopes := HBoxContainer.new()
	scopes.add_theme_constant_override("separation", 8)
	box.add_child(scopes)
	for pair in [["self", "Self"], ["friends", "Friends"], ["global", "Global"]]:
		var id := str(pair[0])
		var button := _button(str(pair[1]), _pick_scope.bind(id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 36)
		scopes.add_child(button)
		_scope_buttons[id] = button
	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 8)
	box.add_child(modes)
	for pair in [["practice", "Practice"], ["challenge", "Challenges"]]:
		var id := str(pair[0])
		var button := _button(str(pair[1]), _pick_mode.bind(id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 36)
		modes.add_child(button)
		_mode_buttons[id] = button
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(440, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_board_list = VBoxContainer.new()
	_board_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_list.add_theme_constant_override("separation", 2)
	scroll.add_child(_board_list)
	var note := _label("Self is your speedrun best. Friends are people you have shared a lobby with. Global is both.", 14, Color("5c564e"))
	note.custom_minimum_size = Vector2(440, 0)
	box.add_child(note)
	return box


func _show_tab(tab: String) -> void:
	_tab = tab
	_run_box.visible = tab == "run"
	_board_box.visible = tab == "board"
	_paint_tabs()
	if tab == "board":
		_paint_board()


func _pick_scope(id: String) -> void:
	_scope = id
	_paint_tabs()
	_paint_board()


func _pick_mode(id: String) -> void:
	_board_mode = id
	_paint_tabs()
	_paint_board()


func _paint_tabs() -> void:
	_mark_tab(_run_tab, _tab == "run")
	_mark_tab(_board_tab, _tab == "board")
	for key in _scope_buttons.keys():
		_mark_tab(_scope_buttons[key], str(key) == _scope)
	for key in _mode_buttons.keys():
		_mark_tab(_mode_buttons[key], str(key) == _board_mode)


func _mark_tab(button: Button, on: bool) -> void:
	var ink := Color("e23b2f") if on else Color("efe8dc")
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", Color("efe8dc"))
	button.add_theme_color_override("font_focus_color", Color("efe8dc"))
	button.add_theme_color_override("font_pressed_color", Color("efe8dc"))


func _paint_board() -> void:
	if _board_list == null:
		return
	for child in _board_list.get_children():
		child.queue_free()
	var Board := preload("res://scripts/board.gd")
	var sheets: Array = Board.rows(_scope, _board_mode)
	var any := false
	for sheet in sheets:
		var times: Array = sheet["times"]
		if _scope != "self" and times.is_empty():
			continue
		any = true
		var title := _label(str(sheet["name"]), 16, Color("1c1915"))
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_board_list.add_child(title)
		if times.is_empty():
			var empty := _label("No time yet", 15, Color("5c564e"))
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			_board_list.add_child(empty)
			continue
		var place := 1
		for row in times:
			var clock := preload("res://scripts/ghosts.gd").format_clock(float(row["time"]))
			var you := "    you" if bool(row["you"]) else ""
			var line := _label("%d    %s    %s%s" % [place, str(row["name"]), clock, you], 15, Color("e23b2f") if bool(row["you"]) else Color("3c3832"))
			line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			_board_list.add_child(line)
			place += 1
	if not any:
		var empty_text := "No practice times yet. Turn on Speedrun and finish a roof."
		if _board_mode == "challenge":
			empty_text = "No challenge times yet. Turn on Speedrun and finish a roof."
		if _scope == "friends":
			empty_text = "No friends yet. Share a lobby and their bests show up here."
		elif _scope == "global" and _board_mode == "practice":
			empty_text = "No times yet. A speedrun best, yours or a friend's, lands here."
		elif _scope == "global":
			empty_text = "No challenge times yet."
		var empty := _label(empty_text, 15, Color("5c564e"))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_board_list.add_child(empty)


func _quit() -> void:
	_commit_identity()
	get_tree().quit()


func _commit_identity() -> void:
	if name_box == null:
		return
	Profile.set_screen_name(name_box.text)
	name_box.text = Profile.screen_name()
	if preview and preview.has_method("set_name_text"):
		preview.set_name_text(Profile.screen_name())


func _practice() -> void:
	_commit_identity()
	Network.offline()
	Match.audit = false
	get_tree().change_scene_to_file("res://scenes/practice.tscn")


func _settings() -> void:
	_commit_identity()
	Curtain.go("res://scenes/settings.tscn", "Loading.")


func _challenge() -> void:
	_commit_identity()
	Network.offline()
	Match.audit = false
	get_tree().change_scene_to_file("res://scenes/challenge.tscn")


func _battle() -> void:
	_commit_identity()
	Network.offline()
	Match.audit = false
	Match.picking_battle = true
	Match.battle = false
	get_tree().change_scene_to_file("res://scenes/practice.tscn")


func _play() -> void:
	_commit_identity()
	_quick = true
	_quick_wait = 0.0
	_joining = false
	_holding = false
	_listing = false
	_step = "quick"
	Network.offline()
	Network.start_browse()
	var note := _label("Joining the next available lobby.", 18, Color("3c3832"))
	note.custom_minimum_size = Vector2(460, 0)
	_open_sheet("Lobby", [
		note,
		_button("Back", _close_sheet),
	])


func _next_open_room() -> Dictionary:
	for room in Network.listed_rooms():
		if not bool(room["locked"]):
			return room
	return {}


func _enter_local_lobby() -> void:
	_quick = false
	_step = ""
	_listing = false
	Network.stop_browse()
	_free_sheet()
	Network.offline()
	Match.audit = false
	get_tree().change_scene_to_file("res://scenes/vote.tscn")


func _field_race() -> void:
	_commit_identity()
	Network.offline()
	Match.audit = false
	var forced := OS.get_environment("ROOFLINE_MAP")
	Match.begin_race(forced if forced != "" else "kiln")
	Match.fill_bots = true
	Curtain.go("res://scenes/race.tscn", "Loading the roof.")


func _solo() -> void:
	_commit_identity()
	Network.offline()
	Match.audit = false
	if OS.get_environment("ROOFLINE_BOT") == "1":
		var forced := OS.get_environment("ROOFLINE_MAP")
		Match.audit = true
		Match.begin_race(forced if forced != "" else "annex")
		Match.started = true
		Curtain.go("res://scenes/race.tscn", "Loading the roof.")
		return
	get_tree().change_scene_to_file("res://scenes/vote.tscn")


func _ask_host() -> void:
	_commit_identity()
	_listing = false
	Network.stop_browse()
	_step = "host"
	var room := _field("%s room" % Profile.screen_name(), "Room name", false)
	var secret := _field("", "Password, optional", false)
	var hint := _label("Leave the password empty for an open room.", 16, Color("5c564e"))
	hint.custom_minimum_size = Vector2(460, 0)
	_open_sheet("Name the room", [
		room,
		secret,
		hint,
		_button("Open room", func() -> void: _confirm_host_text(room.text, secret.text)),
		_button("Back", _close_sheet),
	])
	room.call_deferred("grab_focus")
	room.caret_column = room.text.length()


func _confirm_host_text(named: String, secret: String) -> void:
	_close_sheet()
	var err := Network.host_game(named, secret)
	if err != OK:
		status.text = "Couldn't open port 7777."
		status.visible = true
		return
	Match.audit = false
	get_tree().change_scene_to_file("res://scenes/vote.tscn")


func _ask_join(note: String = "") -> void:
	_commit_identity()
	_joining = false
	_holding = false
	_step = "list"
	_listing = true
	_join_note = note
	var err := Network.start_browse()
	if err != OK and _join_note == "":
		_join_note = "Couldn't listen for rooms. You can still join by IP."
	_room_stamp = Network.room_stamp()
	_paint_rooms()


func _paint_rooms() -> void:
	var rows: Array = []
	if _join_note != "":
		var note := _label(_join_note, 16, Color("e23b2f"))
		note.custom_minimum_size = Vector2(460, 0)
		rows.append(note)
	var found: Array = Network.listed_rooms()
	if found.is_empty():
		var looking := "Looking for rooms on this Wi-Fi."
		if Network.tailscale_address() != "":
			looking = "Looking for rooms on this Wi-Fi and on Tailscale."
		rows.append(_label(looking, 18, Color("3c3832")))
	else:
		rows.append(_label("Click Join on a room.", 18, Color("3c3832")))
		for room in found:
			rows.append(_room_row(str(room["ip"]), str(room["name"]), bool(room["locked"])))
	rows.append(_label("On another network", 16, Color("5c564e")))
	var ip_box := _field(_typed_ip, "Host IP", false)
	ip_box.text_changed.connect(func(text: String) -> void: _typed_ip = text)
	rows.append(ip_box)
	rows.append(_button("Find room", _find_ip))
	rows.append(_button("Back", _close_sheet))
	_open_sheet("Rooms", rows)


func _room_row(ip: String, named: String, locked: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var caption := named if not locked else "%s    ·    password" % named
	var title := _label(caption, 22, Color("1c1915"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	var join := _button("Join", _pick_room.bind(ip, named, locked))
	join.custom_minimum_size = Vector2(120, 42)
	row.add_child(join)
	return row


func _pick_room(ip: String, named: String, locked: bool) -> void:
	if not locked:
		_confirm_join(ip, "")
		return
	_listing = false
	_step = "password"
	var secret := _field("", "Password", true)
	_open_sheet(named, [
		_label("Enter the password.", 18, Color("3c3832")),
		secret,
		_button("Join", func() -> void: _confirm_join(ip, secret.text)),
		_button("Back", func() -> void: _ask_join(_join_note)),
	])
	secret.call_deferred("grab_focus")


func _find_ip() -> void:
	var ip := _clean_ip(_typed_ip)
	_typed_ip = ip
	if ip.is_empty():
		_join_note = "Type the host's IP address."
		_room_stamp = Network.room_stamp()
		_paint_rooms()
		return
	_confirm_join(ip, "")


func _confirm_join(ip: String, secret: String, note: String = "") -> void:
	_listing = false
	_holding = false
	_joining = true
	_join_wait = 0.0
	_step = "joining"
	var title := ip
	if Network.rooms.has(ip):
		title = str(Network.rooms[ip]["name"])
	_open_sheet(title, [
		_label(note if note != "" else "Joining...", 18, Color("3c3832")),
		_button("Back", _cancel_join),
	])
	var err := Network.join_game(ip, secret)
	if err != OK:
		_joining = false
		_ask_join("Couldn't join %s." % ip)


func _need_password(named: String) -> void:
	if not _joining and not _holding:
		return
	_joining = false
	_holding = true
	_step = "password"
	var secret := _field("", "Password", true)
	_open_sheet(named, [
		_label("Enter the password.", 18, Color("3c3832")),
		secret,
		_button("Join", func() -> void: _send_held_password(secret.text)),
		_button("Back", _cancel_join),
	])
	secret.call_deferred("grab_focus")


func _send_held_password(secret: String) -> void:
	_holding = false
	_joining = true
	_join_wait = 0.0
	_step = "joining"
	_open_sheet(Network.room_name if Network.room_name != "" else "Room", [
		_label("Joining...", 18, Color("3c3832")),
		_button("Back", _cancel_join),
	])
	Network.send_password(secret)


func _enter_room() -> void:
	if not _joining:
		return
	_joining = false
	_holding = false
	_listing = false
	_step = ""
	Network.stop_browse()
	_free_sheet()
	Match.audit = false
	get_tree().change_scene_to_file("res://scenes/vote.tscn")


func _join_failed() -> void:
	if not _joining and not _holding:
		return
	_joining = false
	_holding = false
	var msg := Network.notice
	Network.notice = ""
	_ask_join(msg if msg != "" else "Couldn't join that room.")


func _cancel_join() -> void:
	_joining = false
	_holding = false
	Network.cancel_join()
	_ask_join(_join_note)


func _open_sheet(title: String, rows: Array) -> void:
	_free_sheet()
	sheet = ColorRect.new()
	sheet.color = Color("efe8dc")
	sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(480, 0)
	box.add_theme_constant_override("separation", 10)
	box.add_child(_label(title, 40, Color("1c1915")))
	for row in rows:
		box.add_child(row)
	center.add_child(box)
	sheet.add_child(center)
	add_child(sheet)


func _close_sheet() -> void:
	_step = ""
	_quick = false
	_listing = false
	_joining = false
	_holding = false
	Network.stop_browse()
	_free_sheet()


func _free_sheet() -> void:
	if sheet == null:
		return
	var old := sheet
	sheet = null
	if old.get_parent() == self:
		remove_child(old)
	old.queue_free()


func _field(text: String, placeholder: String, hidden: bool) -> LineEdit:
	var box := LineEdit.new()
	box.text = text
	box.placeholder_text = placeholder
	box.secret = hidden
	box.max_length = 24
	box.custom_minimum_size = Vector2(460, 44)
	return box


func _clean_ip(raw: String) -> String:
	var ip := raw.strip_edges()
	if ip.begins_with("["):
		return ip
	var colon := ip.rfind(":")
	if colon > 0 and ip.count(":") == 1 and ip.substr(colon + 1).is_valid_int():
		return ip.substr(0, colon)
	return ip
