extends Node3D

var velocity := Vector3.ZERO
var thrower: Node = null
var life := 3.1
var arm := 0.32
var bounces := 0
var mesh: MeshInstance3D


func _ready() -> void:
	add_to_group("brick")
	mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.28, 0.16, 0.34)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("c4473a")
	mat.roughness = 0.72
	mesh.material_override = mat
	add_child(mesh)


func _physics_process(delta: float) -> void:
	life -= delta
	arm -= delta
	if life <= 0.0 or bounces > 6:
		queue_free()
		return
	mesh.rotate_x(delta * 9.0)
	mesh.rotate_y(delta * 6.0)
	var step := Vector3(velocity.x, 0.0, velocity.z) * delta
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + step)
	query.collision_mask = 1
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		global_position += step
	else:
		var normal: Vector3 = hit.normal
		normal.y = 0.0
		if normal.length() < 0.2:
			global_position += step
		else:
			normal = normal.normalized()
			var flat := Vector3(velocity.x, 0.0, velocity.z).bounce(normal)
			if flat.length() < 0.2:
				queue_free()
				return
			velocity = flat.normalized() * 17.0
			global_position = hit.position + normal * 0.32
			bounces += 1
	global_position.y = 0.78
	for runner in get_tree().get_nodes_in_group("runners"):
		if arm > 0.0 and runner == thrower:
			continue
		if not runner.has_method("strike"):
			continue
		var gap: Vector3 = runner.global_position - global_position
		gap.y = 0.0
		if gap.length() > 0.82:
			continue
		var push := velocity.normalized() * 11.0 + Vector3(0, 6.2, 0)
		runner.strike(push, "Brick")
		queue_free()
		return
