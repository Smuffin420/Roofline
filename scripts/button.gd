extends Area3D

var gate: Node
var pad: Node3D
var lit := Color(0.92, 0.92, 0.92)
var dim := Color(0.55, 0.55, 0.55)
var rest_y := 0.0
var armed := true


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	if pad != null:
		rest_y = pad.position.y


func _physics_process(delta: float) -> void:
	var held := false
	for body in get_overlapping_bodies():
		if body.is_in_group("runners"):
			held = true
			break
	if held and armed:
		armed = false
		if gate != null and gate.has_method("toggle"):
			gate.toggle()
	elif not held:
		armed = true
	if pad == null:
		return
	var target := rest_y - 0.05 if held else rest_y
	pad.position.y = move_toward(pad.position.y, target, delta * 0.4)
	var mesh := pad as MeshInstance3D
	if mesh and mesh.material_override is StandardMaterial3D:
		var down := gate != null and bool(gate.get("lowered"))
		var idle := Color(0.42, 0.2, 0.18) if down else dim
		(mesh.material_override as StandardMaterial3D).albedo_color = lit if held else idle
