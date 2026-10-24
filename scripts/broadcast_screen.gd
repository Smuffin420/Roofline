extends Node3D

var phase := 0.0
var _base_y := 0.0
var _linked := false
var _quads: Array[MeshInstance3D] = []


func _ready() -> void:
	_base_y = position.y
	add_to_group("broadcast")
	_silence(self)
	_add_glass(0.43, false)
	_add_glass(-0.43, true)


func arm(viewers: Vector3, bob: float) -> void:
	phase = bob
	if global_position.distance_squared_to(viewers) > 0.25:
		look_at(viewers, Vector3.UP)
	_base_y = position.y


func _process(delta: float) -> void:
	phase += delta
	position.y = _base_y + sin(phase * 0.62) * 0.22
	if _linked:
		return
	var race := get_tree().get_first_node_in_group("race")
	if race == null or not race.has_method("feed_material"):
		return
	var mat: Material = race.feed_material()
	if mat == null:
		return
	for glass in _quads:
		glass.material_override = mat
	_linked = true


func _add_glass(z: float, flip: bool) -> void:
	var glass := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1.28, 1.36)
	glass.mesh = quad
	glass.position = Vector3(0.0, 0.02, z)
	if flip:
		glass.rotation.y = PI
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glass.layers = 2
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.07, 0.08, 0.1)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.material_override = mat
	add_child(glass)
	_quads.append(glass)


func _silence(node: Node) -> void:
	if node is CollisionObject3D:
		var body := node as CollisionObject3D
		body.collision_layer = 0
		body.collision_mask = 0
	if node is CollisionShape3D:
		(node as CollisionShape3D).disabled = true
	if node is MeshInstance3D:
		var mesh := node as MeshInstance3D
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.layers = 2
		mesh.visibility_range_end = 190.0
		mesh.visibility_range_end_margin = 28.0
		mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	for child in node.get_children():
		_silence(child)
