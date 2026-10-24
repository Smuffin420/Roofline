extends Area3D

var _mats: Array[ShaderMaterial] = []
var _busy := false
var _time := 0.0
var _sent := false
var _body: Node


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_hit)
	for child in get_children():
		if child is Node3D and bool(child.get_meta("coil", false)):
			_collect_mats(child)


func _collect_mats(node: Node) -> void:
	if node is MeshInstance3D:
		var mat: Variant = node.get_meta("spring_mat", null)
		if mat is ShaderMaterial:
			_mats.append(mat)
	for child in node.get_children():
		_collect_mats(child)


func _hit(body: Node) -> void:
	if not body.has_method("spring"):
		return
	if _busy:
		body.spring()
		return
	_body = body
	_busy = true
	_sent = false
	_time = 0.0


func _process(delta: float) -> void:
	if not _busy:
		return
	_time += delta
	var dip := 0.0
	if _time < 0.08:
		dip = _time / 0.08
	else:
		if not _sent:
			_sent = true
			if is_instance_valid(_body) and _body.has_method("spring"):
				_body.spring()
		var u := clampf((_time - 0.08) / 0.22, 0.0, 1.0)
		if u < 0.45:
			dip = lerpf(1.0, -0.28, u / 0.45)
		else:
			dip = lerpf(-0.28, 0.0, (u - 0.45) / 0.55)
		if u >= 1.0:
			_busy = false
			dip = 0.0
	for mat in _mats:
		mat.set_shader_parameter("dip", dip)
