extends Area3D

const Items := preload("res://scripts/items.gd")

var asleep := 0.0
var mesh: MeshInstance3D
var mark: Label3D
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("crate")
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.15, 1.15, 1.15)
	shape.shape = box
	add_child(shape)
	mesh = MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = Vector3(0.64, 0.64, 0.64)
	mesh.mesh = cube
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("f2c14e")
	mat.emission_enabled = true
	mat.emission = Color("e0a106")
	mat.emission_energy_multiplier = 0.85
	mat.roughness = 0.42
	mesh.material_override = mat
	add_child(mesh)
	mark = Label3D.new()
	mark.text = "?"
	mark.font_size = 72
	mark.pixel_size = 0.007
	mark.position = Vector3(0, 0.02, 0)
	mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mark.modulate = Color("1c1915")
	mark.outline_size = 10
	mark.outline_modulate = Color("fff8e8")
	add_child(mark)
	body_entered.connect(_touch)
	rng.seed = int(absf(position.x * 1000.0) + absf(position.z * 17.0)) + 3


func is_awake() -> bool:
	return asleep <= 0.0


func _physics_process(delta: float) -> void:
	if asleep > 0.0:
		asleep -= delta
		mesh.visible = false
		mark.visible = false
		monitoring = false
		if asleep <= 0.0:
			_wake()
		return
	mesh.rotate_y(delta * 1.6)
	mesh.position.y = sin(float(Time.get_ticks_msec()) * 0.003) * 0.07


func _wake() -> void:
	mesh.visible = true
	mark.visible = true
	monitoring = true
	for body in get_overlapping_bodies():
		_touch(body)
		if asleep > 0.0:
			return


func _touch(body: Node) -> void:
	if asleep > 0.0:
		return
	if not body.is_in_group("runners") or not body.has_method("give_item"):
		return
	if body.give_item(Items.roll(rng)):
		asleep = 7.0
		mesh.visible = false
		mark.visible = false
		monitoring = false
