extends Node3D

const PlayerScript := preload("res://scripts/player.gd")
const Styles := preload("res://scripts/styles.gd")
const Trails := preload("res://scripts/trails.gd")
const ThemeLib := preload("res://scripts/theme.gd")
const CrateScript := preload("res://scripts/crate.gd")
const Items := preload("res://scripts/items.gd")
const Names := preload("res://scripts/names.gd")

const MATCH_LEN := 75.0
const COLORS: Array[Color] = [
	Color("e23b2f"),
	Color("1f8a70"),
	Color("e0a106"),
	Color("2f5be7"),
	Color("7a4ea3"),
	Color("d4552f"),
]
var runners: Array = []
var countdown := 3.0
var left := MATCH_LEN
var ended := false
var clock_label: Label
var you_label: Label
var board_label: Label
var message_label: Label
var help_label: Label
var back_button: Button
var deck_shader: Shader


func _ready() -> void:
	PlayerScript.ensure_actions()
	_court()
	_world()
	_spawn()
	_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if OS.get_environment("ROOFLINE_BATTLE_CHECK") == "1":
		call_deferred("_check")


func _court() -> void:
	_solid(Vector3(0, -0.3, 0), Vector3(28, 0.6, 28), Color("c8c2b6"))
	_solid(Vector3(0, 0.8, -14.15), Vector3(28.6, 1.6, 0.5), Color("8d8680"))
	_solid(Vector3(0, 0.8, 14.15), Vector3(28.6, 1.6, 0.5), Color("8d8680"))
	_solid(Vector3(-14.15, 0.8, 0), Vector3(0.5, 1.6, 28.6), Color("8d8680"))
	_solid(Vector3(14.15, 0.8, 0), Vector3(0.5, 1.6, 28.6), Color("8d8680"))
	for spot in [Vector3(-4.2, 0.4, -4.2), Vector3(4.2, 0.4, -4.2), Vector3(-4.2, 0.4, 4.2), Vector3(4.2, 0.4, 4.2)]:
		_solid(spot, Vector3(2.4, 0.8, 2.4), Color("a39e96"))
	_solid(Vector3(0, 0.28, 0), Vector3(3.4, 0.56, 3.4), Color("b7b1a8"))
	_paint(Vector3(0, 0.02, 0), Vector3(6.2, 0.04, 0.18), Color("e23b2f"))
	_paint(Vector3(0, 0.02, 0), Vector3(0.18, 0.04, 6.2), Color("e23b2f"))
	for spot in [Vector3(-6.2, 0.7, 0), Vector3(6.2, 0.7, 0), Vector3(0, 0.7, -6.2), Vector3(0, 0.7, 6.2), Vector3(-8.4, 0.7, -8.4), Vector3(8.4, 0.7, 8.4)]:
		var crate := CrateScript.new()
		crate.position = spot
		add_child(crate)
	_skyline()


func _solid(center: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _deck(color)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(mesh)
	body.add_child(col)
	add_child(body)


func _paint(center: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = center
	mesh.material_override = _deck(color)
	add_child(mesh)


func _deck(color: Color) -> ShaderMaterial:
	if deck_shader == null:
		deck_shader = load("res://shaders/deck.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = deck_shader
	mat.set_shader_parameter("albedo", color)
	mat.set_shader_parameter("roughness_amt", 0.9)
	mat.set_shader_parameter("metal", 0.0)
	mat.set_shader_parameter("rim", 0.12)
	return mat


func _skyline() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	for i in 18:
		var ang := rng.randf() * TAU
		var dist := rng.randf_range(34.0, 62.0)
		var h := rng.randf_range(6.0, 22.0)
		var w := rng.randf_range(3.0, 7.0)
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(w, h, w)
		mesh.mesh = box
		mesh.position = Vector3(sin(ang) * dist, h * 0.5 - 4.0, cos(ang) * dist)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("9aa3ad").darkened(rng.randf_range(0.0, 0.35))
		mat.roughness = 0.92
		mesh.material_override = mat
		add_child(mesh)


func _world() -> void:
	var sky := Color("d5e3ef")
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = sky.darkened(0.16)
	sky_mat.sky_horizon_color = sky.lightened(0.12)
	sky_mat.ground_horizon_color = sky.darkened(0.4)
	sky_mat.ground_bottom_color = Color("8d8680")
	sky_mat.sky_energy_multiplier = 1.05
	sky_mat.sky_curve = 0.1
	sky_mat.sun_angle_max = 24.0
	var canvas := Sky.new()
	canvas.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = canvas
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_light_color = sky_mat.sky_horizon_color
	env.fog_density = 0.006
	env.glow_enabled = true
	env.glow_intensity = 0.22
	env.glow_bloom = 0.08
	Settings.dress_env(env, 1.0)
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 28, 0)
	sun.light_color = Color(1.0, 0.96, 0.9)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.shadow_bias = 0.03
	sun.directional_shadow_max_distance = 80.0
	Settings.dress_sun(sun)
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-16, -140, 0)
	fill.light_color = Color(0.7, 0.78, 0.9)
	fill.light_energy = 0.28
	add_child(fill)


func _spawn() -> void:
	var used_names := {}
	for i in 6:
		var ang := TAU * float(i) / 6.0
		var spot := Vector3(sin(ang) * 9.0, 0.05, cos(ang) * 9.0)
		var bot := i > 0
		var dname := Profile.screen_name() if not bot else Names.take(used_names)
		var tint: Color = Profile.player_color() if not bot else COLORS[i]
		var hat := Profile.hat_id() if not bot else "cap"
		var style := Profile.style_id() if not bot else Styles.random_id()
		var trail := Profile.trail_id() if not bot else Trails.for_slot(i)
		var runner := PlayerScript.new()
		runner.name = "you" if not bot else "bot%d" % (i + 1)
		runner.spawn_slot = i
		runner.is_bot = bot
		runner.view_player = not bot
		runner.rival = bot
		runner.display_name = dname
		runner.player_color = tint
		runner.worn_hat = hat
		runner.worn_style = style
		runner.worn_trail = trail
		runner.position = spot
		runner.checkpoint_pos = spot
		runner.yaw = atan2(spot.x, spot.z)
		runner.rotation.y = runner.yaw
		add_child(runner)
		runners.append(runner)


func _hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = ThemeLib.make()
	layer.add_child(root)
	you_label = _label(root, 28, Vector2(24, 16))
	clock_label = _label(root, 32, Vector2(1040, 16))
	board_label = _label(root, 18, Vector2(980, 64))
	board_label.size = Vector2(276, 420)
	board_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	message_label = _label(root, 42, Vector2(340, 150))
	message_label.size = Vector2(600, 90)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_label = _label(root, 16, Vector2(24, 676))
	help_label.text = "WASD run    Mouse look    Space jump    Shift slide    V camera    Click or F uses the item"
	back_button = Button.new()
	back_button.text = "Back"
	back_button.position = Vector2(24, 620)
	back_button.custom_minimum_size = Vector2(120, 42)
	back_button.visible = false
	back_button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	back_button.pressed.connect(_leave)
	root.add_child(back_button)
	_refresh_hud()


func _label(parent: Node, size: int, pos: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings := LabelSettings.new()
	settings.font_size = size
	settings.font_color = Color("1c1915")
	settings.outline_size = 8 if size >= 32 else 6
	settings.outline_color = Color(0.98, 0.96, 0.92, 0.9)
	label.label_settings = settings
	parent.add_child(label)
	return label


func _process(delta: float) -> void:
	if ended or clock_label == null:
		return
	if not Match.started:
		countdown -= delta
		clock_label.text = str(maxi(1, int(ceil(countdown))))
		you_label.text = "Balloons  ● ● ●"
		message_label.text = "Grab a crate. One item at a time."
		if countdown <= 0.0:
			Match.started = true
			var you = _view()
			if you != null:
				you.message = "Go"
				you.message_time = 0.8
		return
	left -= delta
	_refresh_hud()
	if left <= 0.0 or _living().size() <= 1:
		_finish()


func _refresh_hud() -> void:
	var you = _view()
	var item := "Empty"
	var shielded := false
	if you != null:
		shielded = bool(you.guard_up)
		if str(you.held_item) != "":
			item = Items.label_of(str(you.held_item))
		if shielded:
			item = "Guard" if item == "Empty" else item + " + Guard"
	var mine := 0 if you == null else int(you.balloons)
	you_label.text = "Balloons  %s     %s" % [_pips(mine), item]
	var t := maxf(0.0, left)
	clock_label.text = "%d:%02d" % [int(t) / 60, int(t) % 60]
	var lines: PackedStringArray = PackedStringArray()
	for runner in runners:
		var tag := str(runner.display_name)
		var extra := ""
		if bool(runner.guard_up):
			extra = "  Guard"
		if str(runner.held_item) != "":
			var held := Items.label_of(str(runner.held_item))
			extra = "  " + held if extra == "" else extra + " + " + held
		lines.append("%s   %s%s" % [tag, _pips(int(runner.balloons)), extra])
	board_label.text = "\n".join(lines)
	if you != null and float(you.message_time) > 0.0:
		message_label.text = str(you.message)
	else:
		message_label.text = ""


func _pips(n: int) -> String:
	var text := ""
	for i in 3:
		text += "●" if i < n else "○"
	return text


func _living() -> Array:
	var alive: Array = []
	for runner in runners:
		if int(runner.balloons) > 0 and not bool(runner.finished):
			alive.append(runner)
	return alive


func _view():
	for runner in runners:
		if runner.view_player:
			return runner
	return null


func _finish() -> void:
	if ended:
		return
	ended = true
	Match.started = false
	var best := -1
	var winners: Array = []
	for runner in runners:
		var n := int(runner.balloons)
		if n > best:
			best = n
			winners = [runner]
		elif n == best:
			winners.append(runner)
	var line := "Draw"
	if winners.size() == 1:
		var winner = winners[0]
		line = "You win" if winner.view_player else "%s wins" % str(winner.display_name)
	message_label.text = line
	help_label.text = "A test match. It does not pay XP."
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_button.visible = true
	back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if ended:
		if event.is_action_pressed("ui_cancel"):
			_leave()
		return
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			back_button.visible = true
			back_button.grab_focus()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			back_button.visible = false
			var owner := get_viewport().gui_get_focus_owner()
			if owner:
				owner.release_focus()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		Match.begin_battle()
		Curtain.again("Loading the court.")


func _leave() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Match.battle = false
	Match.started = false
	Curtain.go("res://scenes/menu.tscn", "Loading.")


func _check() -> void:
	Match.started = true
	var you = _view()
	print("runners ", runners.size(), " crates ", get_tree().get_nodes_in_group("crate").size())
	print("give ", you.give_item("guard"))
	you._use_item()
	var before := int(you.balloons)
	you.strike(Vector3(2, 4, 0), "Test")
	print("blocked ", before, " -> ", you.balloons, " guard ", you.guard_up)
	print("give2 ", you.give_item("brick"))
	you._use_item()
	print("bricks ", get_tree().get_nodes_in_group("brick").size())
	you.give_item("slick")
	you._use_item()
	print("slicks ", get_tree().get_nodes_in_group("slick").size())
	you.give_item("gust")
	you._use_item()
	print("BATTLE_OK")
	get_tree().quit()
