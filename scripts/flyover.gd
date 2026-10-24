extends Node3D

const Catalog := preload("res://scripts/catalog.gd")

var map_name := ""
var _cam: Camera3D
var _age := 0.0
var _sky_color := Color("e7b56a")


func _ready() -> void:
	setup()
	_place(0.0)


func setup() -> void:
	if map_name != "":
		return
	var ids: Array = Catalog.ids()
	var day := int(Time.get_unix_time_from_system() / 86400.0)
	var map: Dictionary = Catalog.get_map(str(ids[posmod(day, ids.size())]))
	map_name = str(map["name"])
	_sky_color = Color(str(map.get("sky", "e7b56a")))
	_lay(map)
	_sky()
	_cam = Camera3D.new()
	_cam.fov = 40.0
	_cam.current = true
	add_child(_cam)


func _process(delta: float) -> void:
	_age += delta
	_place(_age)


func _place(age: float) -> void:
	if _cam == null:
		return
	var wave := 0.5 - 0.5 * cos(TAU * fposmod(age, 24.0) / 24.0)
	var z := lerpf(6.0, -46.0, wave)
	var sway := sin(TAU * fposmod(age, 24.0) / 24.0) * 5.5
	var here := _deck_y(z)
	var ahead := _deck_y(z - 16.0)
	_cam.position = Vector3(sway + 2.4, here + 6.6, z + 5.0)
	_cam.look_at(Vector3(sway * 0.2, ahead + 1.35, z - 16.0), Vector3.UP)


func _deck_y(z: float) -> float:
	return sin(z * 0.07) * 1.6


func _lay(map: Dictionary) -> void:
	var concrete := Color(str(map.get("concrete", "e2c2a0")))
	var dark := Color(str(map.get("dark", "8a7560")))
	var metal := Color(str(map.get("metal", "5c564e")))
	var accent := Color(str(map.get("accent", "e23b2f")))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(map.get("seed", 1))
	var z := 14.0
	var n := 0
	while z > -78.0 and n < 14:
		var length := rng.randf_range(9.0, 16.0)
		var y := _deck_y(z - length * 0.5)
		_block(Vector3(0.0, y, z - length * 0.5), Vector3(7.2, 0.45, length), concrete)
		_block(Vector3(0.0, y + 0.26, z - 1.2), Vector3(7.2, 0.08, 0.22), accent)
		for side in [-1.0, 1.0]:
			var width := rng.randf_range(2.4, 4.6)
			var depth := rng.randf_range(3.2, 6.4)
			var tall := rng.randf_range(3.4, 9.5)
			var tint := dark if n % 2 == 0 else metal
			_block(Vector3(side * (4.2 + width * 0.5), y + tall * 0.5, z - length * 0.45), Vector3(width, tall, depth), tint)
		z -= length + rng.randf_range(2.4, 4.2)
		n += 1


func _block(at: Vector3, size: Vector3, color: Color) -> void:
	var mesh_node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = at
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	paint.roughness = 0.86
	mesh_node.material_override = paint
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_node)


func _sky() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = _sky_color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = _sky_color.lightened(0.25)
	env.ambient_light_energy = 0.85
	env.fog_enabled = true
	env.fog_light_color = _sky_color
	env.fog_density = 0.012
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, 28, 0)
	sun.light_color = Color(1.0, 0.96, 0.9).lerp(_sky_color, 0.45)
	sun.light_energy = 1.15
	sun.shadow_enabled = false
	add_child(sun)
