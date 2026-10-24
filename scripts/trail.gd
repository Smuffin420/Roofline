extends Node3D

const Trails := preload("res://scripts/trails.gd")
const LIFE := 0.32
const REACH := 1.15

var trail_id := "off"
var preview_pose := false

var _kind := "off"
var _color := Color.WHITE
var _ribbon: MeshInstance3D
var _mesh: ImmediateMesh
var _mat: StandardMaterial3D
var _pts: Array[Vector3] = []
var _ages: Array[float] = []


func _ready() -> void:
	_ribbon = MeshInstance3D.new()
	_ribbon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh = ImmediateMesh.new()
	_ribbon.mesh = _mesh
	_mat = StandardMaterial3D.new()
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.vertex_color_use_as_albedo = true
	_mat.albedo_color = Color.WHITE
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat.roughness = 1.0
	_ribbon.material_override = _mat
	add_child(_ribbon)
	set_trail(trail_id)


func set_trail(id: String) -> void:
	trail_id = id if id != "" else "off"
	var item := Trails.get_trail(trail_id)
	if item.is_empty():
		trail_id = "off"
		item = Trails.get_trail("off")
	_kind = str(item.get("kind", "off"))
	_color = Color(str(item.get("color", "ffffff")))
	_pts.clear()
	_ages.clear()
	if _mat != null and _kind == "glow":
		_mat.emission_enabled = true
		_mat.emission = _color
		_mat.emission_energy_multiplier = 0.65
	elif _mat != null:
		_mat.emission_enabled = false
	if _ribbon:
		_ribbon.visible = _kind != "off"
	_clear()


func _process(delta: float) -> void:
	if _mesh == null or _kind == "off":
		return
	if preview_pose:
		_ribbon.top_level = false
		_ribbon.position = Vector3.ZERO
		_ribbon.rotation = Vector3.ZERO
		_draw_pose()
		return
	_track(delta)
	_ribbon.top_level = true
	_ribbon.global_transform = Transform3D.IDENTITY
	_draw_history()


func _track(delta: float) -> void:
	if not is_inside_tree():
		return
	for i in _ages.size():
		_ages[i] += delta
	var here := global_position
	if _pts.is_empty() or _pts[0].distance_to(here) > 0.045:
		_pts.push_front(here)
		_ages.push_front(0.0)
	var keep := 1
	var walked := 0.0
	for i in range(1, _pts.size()):
		walked += _pts[i - 1].distance_to(_pts[i])
		if walked > REACH or _ages[i] > LIFE:
			break
		keep = i + 1
	if keep < _pts.size():
		var next: Array[Vector3] = []
		var next_age: Array[float] = []
		for i in keep:
			next.append(_pts[i])
			next_age.append(_ages[i])
		_pts = next
		_ages = next_age


func _draw_pose() -> void:
	_clear()
	if _kind == "wind":
		var t := float(Time.get_ticks_msec()) * 0.001
		for lane in 3:
			var x := (float(lane) - 1.0) * 0.07
			for dash in 3:
				var z0 := 0.02 + float(dash) * 0.2
				var wobble := sin(t * 3.2 + float(dash) + float(lane)) * 0.012
				var fade := 0.55 - float(dash) * 0.13
				_dash(Vector3(x + wobble, float(lane) * 0.012, z0), Vector3(x + wobble, float(lane) * 0.012, z0 + 0.12), 0.012, Color(_color.r, _color.g, _color.b, fade))
		return
	var pts := PackedVector3Array([
		Vector3(0.0, 0.02, 0.02),
		Vector3(0.0, 0.02, 0.24),
		Vector3(0.0, 0.01, 0.48),
		Vector3(0.0, 0.0, 0.74),
	])
	var cols := PackedColorArray([
		Color(_color.r, _color.g, _color.b, 0.72),
		Color(_color.r, _color.g, _color.b, 0.46),
		Color(_color.r, _color.g, _color.b, 0.22),
		Color(_color.r, _color.g, _color.b, 0.0),
	])
	var widths := PackedFloat32Array([0.07, 0.05, 0.03, 0.012])
	_strip(pts, cols, widths)


func _draw_history() -> void:
	_clear()
	if _pts.size() < 2:
		return
	if _kind == "wind":
		for lane in 3:
			var lift := (float(lane) - 1.0) * 0.04
			for i in range(0, _pts.size() - 1, 2):
				var fade := clampf(1.0 - _ages[i] / LIFE, 0.0, 1.0) * 0.55
				if fade <= 0.02:
					continue
				var span := _pts[i] - _pts[i + 1]
				var side := span.cross(Vector3.UP)
				if side.length() < 0.02:
					side = Vector3.RIGHT
				side = side.normalized() * lift
				var a := _pts[i] + side
				var b := _pts[i + 1] + side
				_dash(a, b, 0.012, Color(_color.r, _color.g, _color.b, fade))
		return
	var pts := PackedVector3Array()
	var cols := PackedColorArray()
	var widths := PackedFloat32Array()
	for i in _pts.size():
		var fade := clampf(1.0 - _ages[i] / LIFE, 0.0, 1.0)
		pts.append(_pts[i] + Vector3(0, 0.05, 0))
		cols.append(Color(_color.r, _color.g, _color.b, fade * 0.78))
		widths.append(lerpf(0.012, 0.062, fade))
	_strip(pts, cols, widths)


func _dash(a: Vector3, b: Vector3, width: float, color: Color) -> void:
	var span := b - a
	var length := span.length()
	if length < 0.02:
		return
	var tip := a + span * (minf(length, 0.18) / length)
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _mat)
	_edge(a, tip - a, width, color)
	_edge(tip, tip - a, width * 0.35, Color(color.r, color.g, color.b, color.a * 0.15))
	_mesh.surface_end()


func _strip(pts: PackedVector3Array, cols: PackedColorArray, widths: PackedFloat32Array) -> void:
	if pts.size() < 2:
		return
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _mat)
	for i in pts.size():
		var dir := Vector3.FORWARD
		if i + 1 < pts.size():
			dir = pts[i + 1] - pts[i]
		elif i > 0:
			dir = pts[i] - pts[i - 1]
		_edge(pts[i], dir, widths[i], cols[i])
	_mesh.surface_end()


func _edge(point: Vector3, dir: Vector3, width: float, color: Color) -> void:
	if dir.length() < 0.001:
		dir = Vector3(0, 0, 1)
	dir = dir.normalized()
	var side := dir.cross(Vector3.UP)
	if side.length() < 0.25:
		side = dir.cross(Vector3.RIGHT)
	side = side.normalized() * width
	_mesh.surface_set_color(color)
	_mesh.surface_add_vertex(point - side)
	_mesh.surface_set_color(color)
	_mesh.surface_add_vertex(point + side)


func _clear() -> void:
	if _mesh:
		_mesh.clear_surfaces()
