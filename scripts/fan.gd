extends Area3D

var _body: Node3D
var _mat: ShaderMaterial
var _rest_y := 0.0
var _spin := 0.0
var _hover := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	_body = get_node_or_null("FanBody") as Node3D
	if _body != null:
		_rest_y = _body.position.y
		_mat = _find_mat(_body)
		_hover = randf() * TAU


func _find_mat(node: Node) -> ShaderMaterial:
	if node is MeshInstance3D:
		var mat: Variant = node.get_meta("fan_mat", null)
		if mat is ShaderMaterial:
			return mat
	for child in node.get_children():
		var found := _find_mat(child)
		if found != null:
			return found
	return null


func _physics_process(delta: float) -> void:
	_spin += delta * 12.0
	_hover += delta
	if _mat != null:
		_mat.set_shader_parameter("spin", _spin)
	if _body != null:
		_body.position.y = _rest_y + sin(_hover * 1.6) * 0.045
	for body in get_overlapping_bodies():
		if body.has_method("blow_up"):
			body.blow_up()
