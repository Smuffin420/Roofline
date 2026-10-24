extends Node3D

const ThemeLib := preload("res://scripts/theme.gd")
const ResultsScript := preload("res://scripts/results.gd")
const MannequinScript := preload("res://scripts/mannequin.gd")

var _age := 0.0
var _trophy: Node3D
var _trophy_home := Vector3.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ResultsScript.settle_rewards()
	_world()
	_stage()
	_cast()
	_overlay()


func _process(delta: float) -> void:
	_age += delta
	if _trophy != null:
		_trophy.position = _trophy_home + Vector3(0.0, sin(_age * 2.3) * 0.08, 0.0)


func _world() -> void:
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	var sky := Color("f2c9a0")
	sky_mat.sky_top_color = Color("7eb0d8")
	sky_mat.sky_horizon_color = sky
	sky_mat.ground_horizon_color = Color("c4a07a")
	sky_mat.ground_bottom_color = Color("8a6244")
	sky_mat.sky_energy_multiplier = 1.05
	sky_mat.sky_curve = 0.12
	sky_mat.sun_angle_max = 0.0
	var canvas := Sky.new()
	canvas.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = canvas
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.22
	env.glow_bloom = 0.08
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, 28, 0)
	sun.light_color = Color("fff4e4")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.shadow_bias = 0.03
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-16, -150, 0)
	fill.light_color = Color("9eb4d0")
	fill.light_energy = 0.28
	add_child(fill)
	var cam := Camera3D.new()
	cam.position = Vector3(0.1, 1.9, 7.8)
	cam.fov = 46.0
	add_child(cam)
	cam.look_at(Vector3(0.0, 1.85, 0.0), Vector3.UP)


func _stage() -> void:
	var floor_mat := _mat(Color("efe8dc"), 0.82)
	var slab := MeshInstance3D.new()
	var deck := BoxMesh.new()
	deck.size = Vector3(9.2, 0.18, 5.4)
	slab.mesh = deck
	slab.position = Vector3(0.0, -0.09, 0.35)
	slab.material_override = floor_mat
	add_child(slab)


func _cast() -> void:
	var lineup: Array[Dictionary] = []
	for want in [2, 1, 3]:
		var row := _row_for(want)
		if row.is_empty():
			continue
		lineup.append(row)
	for row in lineup:
		_place(row)


func _row_for(place: int) -> Dictionary:
	for row in Match.results:
		if int(row["place"]) != place:
			continue
		var clock := str(row["clock"])
		var finished := bool(row.get("finished", true))
		if clock.contains("DNF") or clock == "Eliminated":
			finished = false
		if not finished:
			return {}
		return row
	return {}


func _place(row: Dictionary) -> void:
	var place := int(row["place"])
	var spec: Dictionary = _step(place)
	var block := MeshInstance3D.new()
	var box := BoxMesh.new()
	var size: Vector3 = spec["size"]
	box.size = size
	block.mesh = box
	block.position = spec["at"]
	block.material_override = _mat(spec["color"], 0.55)
	add_child(block)
	var number := Label3D.new()
	number.text = str(place)
	number.font_size = 128
	number.pixel_size = 0.012
	number.modulate = Color("1c1915")
	number.outline_size = 12
	number.outline_modulate = Color("efe8dc")
	number.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	number.position = spec["at"] + Vector3(0.0, size.y * 0.08, size.z * 0.5 + 0.04)
	add_child(number)
	var spot := Spot.new()
	spot.position = spec["at"] + Vector3(0.0, size.y * 0.5, 0.0)
	spot.won = place == 1
	spot.emote = "" if place == 1 else ("wave" if place == 2 else "cheer")
	add_child(spot)
	var figure = MannequinScript.new()
	figure.tint = Color.html(str(row.get("color", "e23b2f")))
	figure.style_id = str(row.get("style", "bulbous"))
	figure.name_text = str(row["name"])
	figure.name_size = 42
	figure.trail_id = "off"
	# The mascot's face is the parent's -Z. Turn that toward the camera.
	figure.rotation.y = float(spec["yaw"])
	spot.add_child(figure)
	if place == 1:
		_trophy = _cup()
		_trophy.scale = Vector3(1.15, 1.15, 1.15)
		_trophy_home = spot.position + Vector3(0.0, 2.05, 0.0)
		_trophy.position = _trophy_home
		add_child(_trophy)


func _step(place: int) -> Dictionary:
	match place:
		1:
			return {
				"size": Vector3(1.7, 1.16, 1.45),
				"at": Vector3(0.0, 0.58, 0.0),
				"color": Color("f0c14a"),
				"yaw": PI,
			}
		2:
			return {
				"size": Vector3(1.5, 0.78, 1.35),
				"at": Vector3(-1.72, 0.39, 0.18),
				"color": Color("d7dbe2"),
				"yaw": PI - 0.22,
			}
		_:
			return {
				"size": Vector3(1.5, 0.5, 1.35),
				"at": Vector3(1.72, 0.25, 0.32),
				"color": Color("c4844a"),
				"yaw": PI + 0.22,
			}


func _cup() -> Node3D:
	var root := Node3D.new()
	var gold := _mat(Color("f0c14a"), 0.22)
	gold.metallic = 0.9
	gold.emission_enabled = true
	gold.emission = Color("e0a106")
	gold.emission_energy_multiplier = 0.35
	_part(root, Vector3(0.0, 0.03, 0.0), Vector3(0.34, 0.06, 0.34), gold)
	_part(root, Vector3(0.0, 0.16, 0.0), Vector3(0.09, 0.2, 0.09), gold)
	var bowl := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.26
	bowl.mesh = sphere
	bowl.position = Vector3(0.0, 0.36, 0.0)
	bowl.material_override = gold
	root.add_child(bowl)
	for side in [-1.0, 1.0]:
		var handle := MeshInstance3D.new()
		var ring := TorusMesh.new()
		ring.inner_radius = 0.04
		ring.outer_radius = 0.1
		ring.rings = 8
		ring.ring_segments = 10
		handle.mesh = ring
		handle.position = Vector3(side * 0.22, 0.34, 0.0)
		handle.rotation.x = PI * 0.5
		handle.material_override = gold
		root.add_child(handle)
	return root


func _part(parent: Node3D, at: Vector3, size: Vector3, mat: StandardMaterial3D) -> void:
	var node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	node.mesh = box
	node.position = at
	node.material_override = mat
	parent.add_child(node)


func _mat(color: Color, rough: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	return mat


func _overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var ui := Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.theme = ThemeLib.make()
	ui.mouse_filter = Control.MOUSE_FILTER_PASS
	layer.add_child(ui)
	var title := ThemeLib.label(_title(), 42, Color("efe8dc"))
	title.position = Vector2(240, 28)
	title.size = Vector2(800, 64)
	title.add_theme_color_override("font_outline_color", Color("1c1915"))
	title.add_theme_constant_override("outline_size", 14)
	ui.add_child(title)
	var button := ThemeLib.button("Standings", _standings)
	button.position = Vector2(540, 640)
	button.custom_minimum_size = Vector2(200, 48)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(button)
	button.call_deferred("grab_focus")


func _title() -> String:
	for row in Match.results:
		if int(row["place"]) == 1 and bool(row.get("finished", false)):
			return "1st    %s" % str(row["name"])
	return "Podium"


func _standings() -> void:
	get_tree().change_scene_to_file("res://scenes/results.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_standings()


class Spot extends Node3D:
	var emote := ""
	var won := false
	var finished := true
	var glide_left := 0.0
	var plant := true

	func is_local() -> bool:
		return true
