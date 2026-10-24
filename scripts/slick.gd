extends Area3D

var thrower: Node = null
var life := 9.0
var arm := 0.45


func _ready() -> void:
	add_to_group("slick")
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.35, 0.42, 1.35)
	shape.shape = box
	shape.position.y = 0.2
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var slab := BoxMesh.new()
	slab.size = Vector3(1.45, 0.06, 1.45)
	mesh.mesh = slab
	mesh.position.y = 0.04
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.13, 0.15, 0.92)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.18
	mat.metallic = 0.35
	mesh.material_override = mat
	add_child(mesh)
	body_entered.connect(_touch)


func _physics_process(delta: float) -> void:
	life -= delta
	arm -= delta
	if life <= 0.0:
		queue_free()


func _touch(body: Node) -> void:
	if not is_inside_tree():
		return
	if arm > 0.0 and body == thrower:
		return
	if not body.has_method("strike"):
		return
	var away: Vector3 = body.global_position - global_position
	away.y = 0.0
	if away.length() < 0.15:
		away = Vector3(1, 0, 0)
	body.strike(away.normalized() * 8.0 + Vector3(0, 5.4, 0), "Slick")
	queue_free()
