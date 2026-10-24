extends RefCounted

const Catalog := preload("res://scripts/catalog.gd")

static var cache := {}
static var pending: Array[String] = []
static var busy := false
static var stage := 0
static var vp: SubViewport
static var shot_tree: SceneTree
static var shot_host: Node
static var shot_ready: Callable
static var shot_tries := 0


static func card(caption: String) -> Button:
	var button := Button.new()
	button.clip_contents = true
	button.text = ""
	button.custom_minimum_size = Vector2(0, 132)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	var shot := TextureRect.new()
	shot.name = "Shot"
	shot.set_anchors_preset(Control.PRESET_FULL_RECT)
	shot.offset_left = 3
	shot.offset_top = 3
	shot.offset_right = -3
	shot.offset_bottom = -3
	shot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	shot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(shot)
	var bar := ColorRect.new()
	bar.name = "Bar"
	bar.color = Color(0.07, 0.06, 0.05, 0.78)
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -30
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shot.add_child(bar)
	var label := Label.new()
	label.name = "Caption"
	label.text = caption
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("efe8dc"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(label)
	mark(button, false)
	return button


static func caption(button: Button, text: String) -> void:
	var label := button.get_node_or_null("Shot/Bar/Caption") as Label
	if label:
		label.text = text


static func fill(button: Button, tex: Texture2D) -> void:
	var shot := button.get_node_or_null("Shot") as TextureRect
	if shot:
		shot.texture = tex


static func mark(button: Button, selected: bool, cleared: bool = false) -> void:
	var bg := Color("1c1915")
	if selected:
		bg = Color("e23b2f")
	elif cleared:
		bg = Color("1f8a70")
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.set_corner_radius_all(2)
	var focus := StyleBoxFlat.new()
	focus.bg_color = bg.lightened(0.12)
	focus.set_corner_radius_all(2)
	button.add_theme_stylebox_override("normal", box)
	button.add_theme_stylebox_override("hover", focus)
	button.add_theme_stylebox_override("pressed", box)
	button.add_theme_stylebox_override("focus", focus)


static func request(host: Node, ids: Array, on_ready: Callable) -> void:
	if is_instance_valid(host) and host.is_inside_tree():
		shot_tree = host.get_tree()
		shot_host = host
		shot_ready = on_ready
	for raw in ids:
		var id := str(raw)
		if cache.has(id):
			on_ready.call(id, cache[id])
		elif not pending.has(id):
			pending.append(id)
			on_ready.call(id, _swatch(id))
	if busy or pending.is_empty() or shot_tree == null:
		return
	busy = true
	stage = 0
	shot_tree.process_frame.connect(_step, CONNECT_ONE_SHOT)


static func _step() -> void:
	if shot_tree == null:
		_abort()
		return
	if stage == 0:
		if pending.is_empty():
			busy = false
			return
		_begin(pending[0])
		stage = 1
	elif stage < 3:
		stage += 1
	else:
		var id: String = str(pending.pop_front())
		var tex := _grab()
		if tex == null:
			shot_tries += 1
			if shot_tries < 4:
				pending.push_front(id)
			else:
				shot_tries = 0
			stage = 0
		else:
			shot_tries = 0
			cache[id] = tex
			if is_instance_valid(shot_host) and shot_host.is_inside_tree() and shot_ready.is_valid():
				shot_ready.call(id, tex)
			stage = 0
			if pending.is_empty():
				busy = false
				return
	shot_tree.process_frame.connect(_step, CONNECT_ONE_SHOT)


static func _swatch(id: String) -> Texture2D:
	var map := Catalog.get_map(id)
	var sky := Color(str(map.get("sky", "d7d2c8")))
	var deck := Color(str(map.get("concrete", "e2c2a0")))
	var image := Image.create(8, 8, false, Image.FORMAT_RGB8)
	image.fill(sky)
	image.fill_rect(Rect2i(0, 5, 8, 3), deck)
	return ImageTexture.create_from_image(image)


static func _begin(id: String) -> void:
	_clear_vp()
	if shot_tree == null:
		return
	vp = SubViewport.new()
	vp.own_world_3d = true
	vp.size = Vector2i(480, 270)
	vp.transparent_bg = false
	vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_DISABLED
	vp.positional_shadow_atlas_size = 0
	shot_tree.root.add_child(vp)
	var map := Catalog.get_map(id)
	var sky := Color(str(map.get("sky", "d7d2c8")))
	_world(vp, sky)
	_postcard(vp, id, map)
	var cam := Camera3D.new()
	cam.fov = 46
	cam.current = true
	vp.add_child(cam)
	cam.look_at_from_position(Vector3(7.2, 5.6, 14.0), Vector3(0.0, 1.1, -6.0))


static func _postcard(host: Node, id: String, map: Dictionary) -> void:
	var concrete := Color(str(map.get("concrete", "e2c2a0")))
	var dark := Color(str(map.get("dark", "8a7560")))
	var metal := Color(str(map.get("metal", "5c564e")))
	var accent := Color(str(map.get("accent", "e23b2f")))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(map.get("seed", 1))
	_block(host, Vector3(0, 0, 2), Vector3(6.4, 0.4, 18), concrete)
	_block(host, Vector3(0, 0, -20), Vector3(6.4, 0.4, 16), concrete)
	_block(host, Vector3(0, 0.24, -5.6), Vector3(6.4, 0.08, 0.28), accent)
	for i in 5:
		var side := -1.0 if i % 2 == 0 else 1.0
		var depth := rng.randf_range(2.8, 5.2)
		var width := rng.randf_range(2.2, 4.4)
		var tall := rng.randf_range(3.2, 8.5)
		var z := 8.0 - float(i) * 7.5
		_block(host, Vector3(side * (3.8 + width * 0.5), tall * 0.5, z), Vector3(width, tall, depth), dark if i % 2 == 0 else metal)
	_landmark(host, id, accent, metal, dark)


static func _landmark(host: Node, id: String, accent: Color, metal: Color, dark: Color) -> void:
	match id:
		"switchback", "spire":
			for i in 8:
				var side := -1.0 if i % 2 == 0 else 1.0
				_block(host, Vector3(side * 1.35, 0.4 + float(i) * 0.55, 4.0 - float(i) * 1.7), Vector3(0.28, 2.2, 1.1), accent)
			_block(host, Vector3(0, 4.6, -12.0), Vector3(5.2, 0.35, 6.0), dark)
		"annex", "kiln", "market":
			_block(host, Vector3(-0.8, 2.1, 3.0), Vector3(0.08, 0.08, 9.0), accent)
			_block(host, Vector3(1.1, 1.2, -2.0), Vector3(0.08, 0.08, 12.0), metal)
		"highline", "gallery":
			_block(host, Vector3(0, -3.2, -16.0), Vector3(6.2, 0.4, 10.0), dark)
		"culvert":
			_block(host, Vector3(0, 1.5, -2.0), Vector3(4.2, 0.22, 8.0), metal)
		"canal":
			_block(host, Vector3(0, 0.28, -6.0), Vector3(7.4, 0.12, 14.0), Color(0.75, 0.88, 0.95))
		_:
			_block(host, Vector3(side_of(id), 2.4, -4.0), Vector3(0.4, 4.8, 6.0), accent)


static func side_of(id: String) -> float:
	return -2.4 if posmod(id.hash(), 2) == 0 else 2.4


static func _block(host: Node, at: Vector3, size: Vector3, color: Color) -> void:
	var mesh_node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = at
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	paint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_node.material_override = paint
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	host.add_child(mesh_node)


static func _world(host: Node, sky: Color) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = sky.lightened(0.2)
	env.ambient_light_energy = 1.0
	var world := WorldEnvironment.new()
	world.environment = env
	host.add_child(world)


static func _grab() -> Texture2D:
	var tex: Texture2D = null
	if vp != null and is_instance_valid(vp) and vp.get_texture() != null:
		var image := vp.get_texture().get_image()
		if image != null and image.get_width() > 2 and not _flat_black(image):
			tex = ImageTexture.create_from_image(image)
	_clear_vp()
	return tex


static func _flat_black(image: Image) -> bool:
	var pixel := image.get_pixel(image.get_width() / 2, image.get_height() / 2)
	return pixel.r < 0.02 and pixel.g < 0.02 and pixel.b < 0.02


static func _clear_vp() -> void:
	if vp != null and is_instance_valid(vp):
		vp.queue_free()
	vp = null


static func _abort() -> void:
	busy = false
	stage = 0
	_clear_vp()
