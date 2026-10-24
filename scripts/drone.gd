extends Node3D

var aim := Vector3.ZERO
var filming := false
var phase := 0.0
var rate := 18.0
var amp := 0.11
var _base_y := 0.0


func _ready() -> void:
	_base_y = position.y
	_silence(self)


func arm(focus: Vector3, bob_phase: float) -> void:
	aim = focus
	filming = true
	phase = bob_phase
	rate = 16.0 + fmod(absf(bob_phase), 5.0)


func _process(delta: float) -> void:
	phase += delta
	position.y = _base_y + sin(phase * rate) * amp
	if not filming:
		rotation.x = sin(phase * rate * 0.45) * 0.05
		return
	var focus := aim + Vector3(sin(phase * 0.55) * 0.45, sin(phase * 0.8) * 0.1, 0.0)
	if global_position.distance_squared_to(focus) > 0.05:
		look_at(focus, Vector3.UP)
		# The lens sits on local +Z. look_at aims local -Z, so turn it around.
		rotate_object_local(Vector3.UP, PI)
	rotation.x = sin(phase * rate * 0.45) * 0.05


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
		mesh.visibility_range_end = 150.0
		mesh.visibility_range_end_margin = 24.0
		mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	for child in node.get_children():
		_silence(child)
