extends Node3D

const GhostStore := preload("res://scripts/ghosts.gd")
const MannequinScript := preload("res://scripts/mannequin.gd")

var samples := PackedFloat32Array()
var time := 0.0
var figure


func setup(run: PackedFloat32Array, color: Color) -> void:
	samples = run
	figure = MannequinScript.new()
	figure.tint = color
	figure.name_text = "PB"
	figure.name_size = 48
	figure.hat_id = Profile.hat_id()
	figure.style_id = Profile.style_id()
	figure.trail_id = Profile.trail_id()
	add_child(figure)
	if figure.has_method("set_ghost"):
		figure.set_ghost(0.72)


func _process(_delta: float) -> void:
	if samples.is_empty():
		visible = false
		return
	var pose: Dictionary = GhostStore.pose_at(samples, time)
	if not bool(pose["ok"]):
		visible = false
		return
	visible = true
	global_position = pose["pos"]
	rotation.y = float(pose["yaw"])
	_keep_off_the_lens()


func _keep_off_the_lens() -> void:
	if figure == null:
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		_show_meshes(figure)
		return
	_cull_meshes(figure, camera.global_position)


func _cull_meshes(node: Node, cam: Vector3) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D
			mesh.visible = cam.distance_to(mesh.global_position) > 0.38
		_cull_meshes(child, cam)


func _show_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = true
		_show_meshes(child)
