extends Node

const PlayerScript := preload("res://scripts/player.gd")

var master := 1.0
var effects := 1.0
var interface := 1.0
var mouse_sens := 1.0
var pad_sens := 1.0
var invert_y := false
var stick_deadzone := 0.18
var window_mode := "windowed"
var resolution := "1280x720"
var display_custom := false
var vsync := true
var msaa := 0
var fps_cap := 0
var fov := 80.0
var brightness := 1.0
var shadows := "medium"
var glow := true
var tilt := true
var binds := {}


func _ready() -> void:
	_load()
	apply_video()
	PlayerScript.ensure_actions()


func gain(kind: String) -> float:
	var part := interface if kind == "ui" else effects
	var lin := clampf(master, 0.0, 1.0) * clampf(part, 0.0, 1.0)
	if lin <= 0.001:
		return -80.0
	return linear_to_db(lin)


func move_deadzone() -> float:
	return 0.22 * (clampf(stick_deadzone, 0.05, 0.55) / 0.18)


func set_master(value: float) -> void:
	master = clampf(value, 0.0, 1.0)
	_save()


func set_effects(value: float) -> void:
	effects = clampf(value, 0.0, 1.0)
	_save()


func set_interface(value: float) -> void:
	interface = clampf(value, 0.0, 1.0)
	_save()


func reset_audio() -> void:
	master = 1.0
	effects = 1.0
	interface = 1.0
	_save()


func set_mouse_sens(value: float) -> void:
	mouse_sens = clampf(value, 0.25, 3.0)
	_save()


func set_pad_sens(value: float) -> void:
	pad_sens = clampf(value, 0.25, 3.0)
	_save()


func set_invert_y(on: bool) -> void:
	invert_y = on
	_save()


func set_stick_deadzone(value: float) -> void:
	stick_deadzone = clampf(value, 0.05, 0.55)
	_save()
	PlayerScript.ensure_actions()


func set_bind(action: String, event: InputEvent) -> void:
	var spec := _spec_of(event)
	if spec == "":
		return
	if spec.begins_with("j"):
		binds[action + "#pad"] = spec
	else:
		binds[action] = spec
	_save()
	PlayerScript.ensure_actions()


func reset_controls() -> void:
	mouse_sens = 1.0
	pad_sens = 1.0
	invert_y = false
	stick_deadzone = 0.18
	binds.clear()
	_save()
	PlayerScript.ensure_actions()


func set_window_mode(mode: String) -> void:
	window_mode = mode
	display_custom = true
	_save()
	apply_video()


func set_resolution(value: String) -> void:
	resolution = value
	display_custom = true
	_save()
	apply_video()


func set_vsync(on: bool) -> void:
	vsync = on
	_save()
	apply_video()


func set_msaa(level: int) -> void:
	msaa = level
	_save()
	apply_video()


func set_fps_cap(cap: int) -> void:
	fps_cap = maxi(cap, 0)
	_save()
	apply_video()


func set_fov(value: float) -> void:
	fov = clampf(value, 70.0, 110.0)
	_save()


func set_brightness(value: float) -> void:
	brightness = clampf(value, 0.7, 1.4)
	_save()


func set_shadows(level: String) -> void:
	shadows = level
	_save()


func set_glow(on: bool) -> void:
	glow = on
	_save()


func set_tilt(on: bool) -> void:
	tilt = on
	_save()


func reset_video() -> void:
	window_mode = "windowed"
	resolution = "1280x720"
	display_custom = true
	vsync = true
	msaa = 0
	fps_cap = 0
	fov = 80.0
	brightness = 1.0
	shadows = "medium"
	glow = true
	tilt = true
	_save()
	apply_video()


func apply_video() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var root_vp := get_tree().root
	match msaa:
		2:
			root_vp.msaa_3d = Viewport.MSAA_2X
		4:
			root_vp.msaa_3d = Viewport.MSAA_4X
		8:
			root_vp.msaa_3d = Viewport.MSAA_8X
		_:
			root_vp.msaa_3d = Viewport.MSAA_DISABLED
	var sync := DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(sync)
	Engine.max_fps = fps_cap
	if not display_custom:
		return
	var mode := DisplayServer.WINDOW_MODE_WINDOWED
	if window_mode == "borderless":
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	elif window_mode == "fullscreen":
		mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	DisplayServer.window_set_mode(mode)
	if window_mode != "windowed":
		return
	var size := _parse_res(resolution)
	DisplayServer.window_set_size(size)
	var screen := DisplayServer.window_get_current_screen()
	var origin := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	DisplayServer.window_set_position(origin + (screen_size - size) / 2)


func dress_env(env: Environment, base_exposure: float) -> void:
	if not glow:
		env.glow_enabled = false
	env.tonemap_exposure = base_exposure * brightness


func dress_sun(sun: DirectionalLight3D) -> void:
	var base := sun.directional_shadow_max_distance
	if shadows == "off":
		sun.shadow_enabled = false
		return
	sun.shadow_enabled = true
	if shadows == "low":
		sun.directional_shadow_max_distance = minf(base, 48.0)
		sun.directional_shadow_blend_splits = false
	elif shadows == "high":
		sun.directional_shadow_max_distance = maxf(base, 140.0)
		sun.directional_shadow_blend_splits = true


func resolutions() -> PackedStringArray:
	var found := PackedStringArray()
	var screen := DisplayServer.screen_get_size()
	if DisplayServer.get_name() == "headless":
		screen = Vector2i(1920, 1080)
	for pair in ["1280x720", "1366x768", "1600x900", "1920x1080", "2560x1440", "3840x2160"]:
		var size := _parse_res(pair)
		if size.x <= screen.x + 8 and size.y <= screen.y + 8:
			found.append(pair)
	if found.is_empty():
		found.append("1280x720")
	if resolution not in found:
		found.append(resolution)
	return found


func binding_text(action: String) -> String:
	if not InputMap.has_action(action):
		return "Unbound"
	var parts := PackedStringArray()
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion:
			continue
		var text := _event_text(ev)
		if text != "" and not parts.has(text):
			parts.append(text)
	if parts.is_empty():
		return "Unbound"
	return "  ·  ".join(parts)


func overlay_binds() -> void:
	var actions: Array[String] = ["move_forward", "move_back", "move_left", "move_right", "jump", "slide", "pause", "restart", "view", "item"]
	for action in actions:
		var key_spec := str(binds.get(action, ""))
		var pad_spec := str(binds.get(action + "#pad", ""))
		if key_spec != "":
			_strip(action, false)
			var ev := _event_from(key_spec)
			if ev != null:
				InputMap.action_add_event(action, ev)
		if pad_spec != "":
			_strip(action, true)
			var pad_ev := _event_from(pad_spec)
			if pad_ev != null:
				InputMap.action_add_event(action, pad_ev)


func _strip(action: String, pad_buttons: bool) -> void:
	if not InputMap.has_action(action):
		return
	var keep: Array[InputEvent] = []
	for existing in InputMap.action_get_events(action):
		if pad_buttons and existing is InputEventJoypadButton:
			continue
		if not pad_buttons and (existing is InputEventKey or existing is InputEventMouseButton):
			continue
		keep.append(existing)
	InputMap.action_erase_events(action)
	for ev in keep:
		InputMap.action_add_event(action, ev)


func _spec_of(event: InputEvent) -> String:
	if event is InputEventKey:
		var key := event as InputEventKey
		return "k:%d" % int(key.physical_keycode)
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		return "m:%d" % int(mouse.button_index)
	if event is InputEventJoypadButton:
		var pad := event as InputEventJoypadButton
		return "j:%d" % int(pad.button_index)
	return ""


func _event_from(spec: String) -> InputEvent:
	var parts := spec.split(":", false)
	if parts.size() != 2 or not str(parts[1]).is_valid_int():
		return null
	var code := int(parts[1])
	if parts[0] == "k":
		var key := InputEventKey.new()
		key.physical_keycode = code as Key
		return key
	if parts[0] == "m":
		var mouse := InputEventMouseButton.new()
		mouse.button_index = code as MouseButton
		return mouse
	if parts[0] == "j":
		var pad := InputEventJoypadButton.new()
		pad.button_index = code as JoyButton
		return pad
	return null


func _event_text(event: InputEvent) -> String:
	if event is InputEventKey:
		var key := event as InputEventKey
		var code: Key = key.physical_keycode
		if code == KEY_NONE:
			code = key.keycode
		var text := OS.get_keycode_string(code)
		if text == "":
			return "Key"
		return text
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		match mouse.button_index:
			MOUSE_BUTTON_LEFT:
				return "Mouse 1"
			MOUSE_BUTTON_RIGHT:
				return "Mouse 2"
			MOUSE_BUTTON_MIDDLE:
				return "Mouse 3"
			_:
				return "Mouse %d" % int(mouse.button_index)
	if event is InputEventJoypadButton:
		var pad := event as InputEventJoypadButton
		match pad.button_index:
			JOY_BUTTON_A:
				return "A"
			JOY_BUTTON_B:
				return "B"
			JOY_BUTTON_X:
				return "X"
			JOY_BUTTON_Y:
				return "Y"
			JOY_BUTTON_BACK:
				return "Back"
			JOY_BUTTON_START:
				return "Start"
			JOY_BUTTON_LEFT_SHOULDER:
				return "LB"
			JOY_BUTTON_RIGHT_SHOULDER:
				return "RB"
			JOY_BUTTON_LEFT_STICK:
				return "L3"
			JOY_BUTTON_RIGHT_STICK:
				return "R3"
			JOY_BUTTON_DPAD_UP:
				return "Up"
			JOY_BUTTON_DPAD_DOWN:
				return "Down"
			JOY_BUTTON_DPAD_LEFT:
				return "Left"
			JOY_BUTTON_DPAD_RIGHT:
				return "Right"
			_:
				return "Pad %d" % int(pad.button_index)
	return ""


func _parse_res(pair: String) -> Vector2i:
	var parts := pair.split("x", false)
	if parts.size() != 2 or not str(parts[0]).is_valid_int() or not str(parts[1]).is_valid_int():
		return Vector2i(1280, 720)
	return Vector2i(int(parts[0]), int(parts[1]))


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	master = clampf(float(cfg.get_value("audio", "master", 1.0)), 0.0, 1.0)
	effects = clampf(float(cfg.get_value("audio", "effects", 1.0)), 0.0, 1.0)
	interface = clampf(float(cfg.get_value("audio", "interface", 1.0)), 0.0, 1.0)
	mouse_sens = clampf(float(cfg.get_value("controls", "mouse_sens", 1.0)), 0.25, 3.0)
	pad_sens = clampf(float(cfg.get_value("controls", "pad_sens", 1.0)), 0.25, 3.0)
	invert_y = bool(cfg.get_value("controls", "invert_y", false))
	stick_deadzone = clampf(float(cfg.get_value("controls", "deadzone", 0.18)), 0.05, 0.55)
	window_mode = str(cfg.get_value("video", "window", "windowed"))
	resolution = str(cfg.get_value("video", "resolution", "1280x720"))
	display_custom = bool(cfg.get_value("video", "display_custom", false))
	vsync = bool(cfg.get_value("video", "vsync", true))
	msaa = int(cfg.get_value("video", "msaa", 0))
	fps_cap = maxi(int(cfg.get_value("video", "fps", 0)), 0)
	fov = clampf(float(cfg.get_value("video", "fov", 80.0)), 70.0, 110.0)
	brightness = clampf(float(cfg.get_value("video", "brightness", 1.0)), 0.7, 1.4)
	shadows = str(cfg.get_value("video", "shadows", "medium"))
	glow = bool(cfg.get_value("video", "glow", true))
	tilt = bool(cfg.get_value("video", "tilt", true))
	binds.clear()
	if cfg.has_section("binds"):
		for key in cfg.get_section_keys("binds"):
			binds[str(key)] = str(cfg.get_value("binds", key, ""))


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master)
	cfg.set_value("audio", "effects", effects)
	cfg.set_value("audio", "interface", interface)
	cfg.set_value("controls", "mouse_sens", mouse_sens)
	cfg.set_value("controls", "pad_sens", pad_sens)
	cfg.set_value("controls", "invert_y", invert_y)
	cfg.set_value("controls", "deadzone", stick_deadzone)
	cfg.set_value("video", "window", window_mode)
	cfg.set_value("video", "resolution", resolution)
	cfg.set_value("video", "display_custom", display_custom)
	cfg.set_value("video", "vsync", vsync)
	cfg.set_value("video", "msaa", msaa)
	cfg.set_value("video", "fps", fps_cap)
	cfg.set_value("video", "fov", fov)
	cfg.set_value("video", "brightness", brightness)
	cfg.set_value("video", "shadows", shadows)
	cfg.set_value("video", "glow", glow)
	cfg.set_value("video", "tilt", tilt)
	for key in binds.keys():
		cfg.set_value("binds", str(key), str(binds[key]))
	cfg.save("user://settings.cfg")
