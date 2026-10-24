extends Control

const ThemeLib := preload("res://scripts/theme.gd")

const ACTIONS := [
	["move_forward", "Move forward"],
	["move_back", "Move back"],
	["move_left", "Move left"],
	["move_right", "Move right"],
	["jump", "Jump"],
	["slide", "Slide"],
	["pause", "Pause"],
	["restart", "Restart"],
	["view", "Change view"],
	["item", "Use item"],
]

var page: VBoxContainer
var tab_buttons := {}
var page_id := "audio"
var listen := ""


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ThemeLib.make()

	var bg := ColorRect.new()
	bg.color = Color("efe8dc")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.offset_left = 280
	column.offset_top = 12
	column.offset_right = -280
	column.offset_bottom = -12
	column.add_theme_constant_override("separation", 10)
	add_child(column)

	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, 8)
	column.add_child(pad)
	column.add_child(ThemeLib.label("SETTINGS", 18, Color("e23b2f")))
	column.add_child(ThemeLib.label("Audio, controls, and video.", 32, Color("1c1915")))

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(tabs)
	for item in [["audio", "Audio"], ["controls", "Controls"], ["video", "Video"]]:
		var id := str(item[0])
		var button := Button.new()
		button.text = str(item[1])
		button.custom_minimum_size = Vector2(160, 42)
		button.pressed.connect(_pick_tab.bind(id))
		tabs.add_child(button)
		tab_buttons[id] = button

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8)
	scroll.add_child(page)

	var back := ThemeLib.button("Back", _back)
	column.add_child(back)
	var foot := Control.new()
	foot.custom_minimum_size = Vector2(0, 8)
	column.add_child(foot)
	_show_page()
	if tab_buttons.has("audio"):
		tab_buttons["audio"].call_deferred("grab_focus")


func _pick_tab(id: String) -> void:
	Sfx.play("click", -8.0)
	page_id = id
	listen = ""
	call_deferred("_show_page")


func _show_page() -> void:
	_paint_tabs()
	for child in page.get_children():
		page.remove_child(child)
		child.queue_free()
	if page_id == "controls":
		_controls_page()
	elif page_id == "video":
		_video_page()
	else:
		_audio_page()


func _paint_tabs() -> void:
	for id in tab_buttons.keys():
		var button: Button = tab_buttons[id]
		var on := str(id) == page_id
		var box := StyleBoxFlat.new()
		box.bg_color = Color("e23b2f") if on else Color("1c1915")
		box.set_corner_radius_all(2)
		box.content_margin_top = 8
		box.content_margin_bottom = 8
		var focus := box.duplicate()
		focus.bg_color = box.bg_color.lightened(0.12)
		button.add_theme_stylebox_override("normal", box)
		button.add_theme_stylebox_override("hover", focus)
		button.add_theme_stylebox_override("pressed", box)
		button.add_theme_stylebox_override("focus", focus)


func _audio_page() -> void:
	page.add_child(_slider("Master", Settings.master, 0.0, 1.0, 0.01, _pct(Settings.master), _on_master))
	page.add_child(_slider("Effects", Settings.effects, 0.0, 1.0, 0.01, _pct(Settings.effects), _on_effects))
	page.add_child(_slider("Interface", Settings.interface, 0.0, 1.0, 0.01, _pct(Settings.interface), _on_interface))
	var note := ThemeLib.label("Effects cover the roof. Interface is the menu clicks.", 16, Color("5c564e"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(note)
	page.add_child(ThemeLib.button("Play a sample", _sample))
	page.add_child(ThemeLib.button("Reset audio", _reset_audio))


func _controls_page() -> void:
	var note := ThemeLib.label("Click a binding, then press a key, mouse button, or pad button. Esc cancels.", 16, Color("5c564e"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(note)
	page.add_child(_slider("Mouse sensitivity", Settings.mouse_sens, 0.25, 3.0, 0.05, _pct(Settings.mouse_sens), _on_mouse))
	page.add_child(_slider("Gamepad sensitivity", Settings.pad_sens, 0.25, 3.0, 0.05, _pct(Settings.pad_sens), _on_pad))
	page.add_child(_slider("Stick deadzone", Settings.stick_deadzone, 0.05, 0.5, 0.01, _pct(Settings.stick_deadzone), _on_deadzone))
	page.add_child(_toggle("Invert look", Settings.invert_y, _on_invert))
	for item in ACTIONS:
		page.add_child(_bind_row(str(item[0]), str(item[1])))
	page.add_child(ThemeLib.button("Reset controls", _reset_controls))


func _video_page() -> void:
	page.add_child(_cycle("Window", Settings.window_mode, ["windowed", "borderless", "fullscreen"], ["Windowed", "Borderless", "Fullscreen"], _on_window))
	var res_ids := Settings.resolutions()
	var res_labels := PackedStringArray()
	for pair in res_ids:
		res_labels.append(pair)
	page.add_child(_cycle("Resolution", Settings.resolution, res_ids, res_labels, _on_resolution))
	page.add_child(_toggle("VSync", Settings.vsync, _on_vsync))
	page.add_child(_cycle("Antialiasing", str(Settings.msaa), ["0", "2", "4", "8"], ["Off", "2x", "4x", "8x"], _on_msaa))
	page.add_child(_cycle("Frame cap", str(Settings.fps_cap), ["0", "60", "120", "144", "165", "240"], ["Unlimited", "60", "120", "144", "165", "240"], _on_fps))
	page.add_child(_slider("Field of view", Settings.fov, 70.0, 110.0, 1.0, str(int(round(Settings.fov))), _on_fov))
	page.add_child(_slider("Brightness", Settings.brightness, 0.7, 1.4, 0.05, _pct(Settings.brightness), _on_brightness))
	page.add_child(_cycle("Shadows", Settings.shadows, ["off", "low", "medium", "high"], ["Off", "Low", "Medium", "High"], _on_shadows))
	page.add_child(_toggle("Glow", Settings.glow, _on_glow))
	page.add_child(_toggle("Camera tilt", Settings.tilt, _on_tilt))
	var camera_mode := "third" if Profile.use_third() else "first"
	page.add_child(_cycle("Camera", camera_mode, ["first", "third"], ["First person", "Third person"], _on_camera))
	var note := ThemeLib.label("Window and resolution apply to the game window. The camera, shadows, glow, and brightness show on the next roof.", 16, Color("5c564e"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(note)
	page.add_child(ThemeLib.button("Reset video", _reset_video))


func _slider(title: String, value: float, min_v: float, max_v: float, step: float, caption: String, on_change: Callable) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	var head := HBoxContainer.new()
	var name := ThemeLib.label(title, 18, Color("1c1915"))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var amount := ThemeLib.label(caption, 18, Color("5c564e"))
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount.custom_minimum_size = Vector2(72, 0)
	head.add_child(name)
	head.add_child(amount)
	box.add_child(head)
	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = value
	slider.custom_minimum_size = Vector2(0, 28)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("d9d0c3")
	track.set_corner_radius_all(2)
	track.content_margin_top = 10
	track.content_margin_bottom = 10
	slider.add_theme_stylebox_override("slider", track)
	slider.value_changed.connect(func(v: float) -> void:
		on_change.call(v)
		if is_equal_approx(step, 1.0):
			amount.text = str(int(round(v)))
		else:
			amount.text = _pct(v)
	)
	box.add_child(slider)
	return box


func _toggle(title: String, on: bool, on_change: Callable) -> Button:
	var button := Button.new()
	button.text = "%s    %s" % [title, "On" if on else "Off"]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 44)
	button.pressed.connect(func() -> void:
		Sfx.play("click", -8.0)
		on_change.call(not on)
		call_deferred("_show_page")
	)
	return button


func _cycle(title: String, current: String, options: PackedStringArray, labels: PackedStringArray, on_pick: Callable) -> Button:
	var idx := options.find(current)
	if idx < 0:
		idx = 0
	var button := Button.new()
	button.text = "%s    %s" % [title, labels[idx]]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 44)
	button.pressed.connect(func() -> void:
		Sfx.play("click", -8.0)
		var next := (idx + 1) % options.size()
		on_pick.call(options[next])
		call_deferred("_show_page")
	)
	return button


func _bind_row(action: String, title: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var name := ThemeLib.label(title, 18, Color("1c1915"))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.custom_minimum_size = Vector2(200, 40)
	var button := Button.new()
	button.custom_minimum_size = Vector2(320, 40)
	button.text = "Press a key" if listen == action else Settings.binding_text(action)
	button.pressed.connect(func() -> void:
		Sfx.play("click", -8.0)
		listen = action
		call_deferred("_show_page")
	)
	row.add_child(name)
	row.add_child(button)
	return row


func _on_master(v: float) -> void:
	Settings.set_master(v)


func _on_effects(v: float) -> void:
	Settings.set_effects(v)


func _on_interface(v: float) -> void:
	Settings.set_interface(v)


func _on_mouse(v: float) -> void:
	Settings.set_mouse_sens(v)


func _on_pad(v: float) -> void:
	Settings.set_pad_sens(v)


func _on_deadzone(v: float) -> void:
	Settings.set_stick_deadzone(v)


func _on_invert(on: bool) -> void:
	Settings.set_invert_y(on)


func _on_window(mode: String) -> void:
	Settings.set_window_mode(mode)


func _on_resolution(pair: String) -> void:
	Settings.set_resolution(pair)


func _on_vsync(on: bool) -> void:
	Settings.set_vsync(on)


func _on_msaa(level: String) -> void:
	Settings.set_msaa(int(level))


func _on_fps(cap: String) -> void:
	Settings.set_fps_cap(int(cap))


func _on_fov(v: float) -> void:
	Settings.set_fov(v)


func _on_brightness(v: float) -> void:
	Settings.set_brightness(v)


func _on_shadows(level: String) -> void:
	Settings.set_shadows(level)


func _on_glow(on: bool) -> void:
	Settings.set_glow(on)


func _on_tilt(on: bool) -> void:
	Settings.set_tilt(on)


func _on_camera(mode: String) -> void:
	Profile.set_third_person(mode == "third")


func _sample() -> void:
	Sfx.play("boost", -3.0, 1.0, 0.32)
	Sfx.play("slide", -6.0, 1.0, 0.45)


func _reset_audio() -> void:
	Settings.reset_audio()
	call_deferred("_show_page")


func _reset_controls() -> void:
	listen = ""
	Settings.reset_controls()
	call_deferred("_show_page")


func _reset_video() -> void:
	Settings.reset_video()
	call_deferred("_show_page")


func _pct(v: float) -> String:
	return "%d%%" % int(round(v * 100.0))


func _back() -> void:
	Curtain.go("res://scenes/menu.tscn", "Loading.")


func _unhandled_input(event: InputEvent) -> void:
	if listen != "":
		if event.is_echo():
			return
		if event.is_action_pressed("ui_cancel"):
			listen = ""
			get_viewport().set_input_as_handled()
			_show_page()
			return
		if not event.pressed:
			return
		if event is InputEventMouseButton:
			var button := event as InputEventMouseButton
			if button.button_index == MOUSE_BUTTON_WHEEL_UP or button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				return
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			Settings.set_bind(listen, event)
			listen = ""
			get_viewport().set_input_as_handled()
			_show_page()
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()
