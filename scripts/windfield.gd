extends MeshInstance3D

var push := Vector3(16, 0, 0)
var span := Vector3(3.2, 2.4, 4.0)

var _mesh: ImmediateMesh
var _mat: StandardMaterial3D
var _clock := 0.0


func _ready() -> void:
	_mesh = ImmediateMesh.new()
	mesh = _mesh
	_mat = StandardMaterial3D.new()
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.vertex_color_use_as_albedo = true
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat.albedo_color = Color.WHITE
	material_override = _mat
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _process(delta: float) -> void:
	_clock += delta
	var dir := Vector3(signf(push.x), 0, 0)
	if dir.x == 0.0:
		dir.x = 1.0
	var half_x := span.x * 0.5
	var half_y := span.y * 0.42
	var half_z := span.z * 0.46
	var speed := 6.4 * dir.x
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _mat)
	for i in 14:
		var seed := float(i)
		var travel := fposmod(_clock * speed + seed * 1.37, span.x) - half_x
		var y := lerpf(-half_y, half_y, fposmod(seed * 0.29, 1.0))
		var z := lerpf(-half_z, half_z, fposmod(seed * 0.47, 1.0))
		var length := lerpf(0.55, 1.15, fposmod(seed * 0.19, 1.0))
		var fade := 0.22 + 0.38 * absf(sin(_clock * 2.4 + seed))
		_streak(Vector3(travel, y, z), Vector3(dir.x * length, 0, 0), 0.035, Color(0.9, 0.96, 1.0, fade))
	_mesh.surface_end()


func _streak(origin: Vector3, delta: Vector3, width: float, color: Color) -> void:
	var tip := origin + delta
	var side := Vector3(0, width, 0)
	_tri(origin - side, origin + side, tip, color)


func _tri(a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	_mesh.surface_set_color(color)
	_mesh.surface_add_vertex(a)
	_mesh.surface_set_color(color)
	_mesh.surface_add_vertex(b)
	_mesh.surface_set_color(Color(color.r, color.g, color.b, color.a * 0.05))
	_mesh.surface_add_vertex(c)
