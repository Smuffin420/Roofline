extends AnimatableBody3D

var period := 1.9
var swing := 0.86
var phase := 0.0
var area: Area3D
var _shape: Shape3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	if area != null and area.get_child_count() > 0:
		var shape_node := area.get_child(0) as CollisionShape3D
		if shape_node != null:
			_shape = shape_node.shape


func _physics_process(delta: float) -> void:
	phase += delta
	var omega := TAU / period
	var travel := cos(phase * omega)
	rotation.z = sin(phase * omega) * swing
	# The head used to shove only while it hung near center, and most of that
	# shove was up the street. A hit anywhere on the moving swing throws you
	# the way the head is going.
	if area == null or _shape == null or absf(travel) < 0.22:
		return
	var world := get_world_3d()
	if world == null:
		return
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = _shape
	params.transform = area.global_transform
	params.collision_mask = 2
	params.collide_with_areas = false
	params.collide_with_bodies = true
	var dir := signf(travel)
	if dir == 0.0:
		dir = 1.0
	var power := clampf((absf(travel) - 0.22) / 0.78, 0.0, 1.0)
	var impulse := Vector3(dir * lerpf(16.0, 24.0, power), lerpf(11.0, 15.0, power), 8.0)
	for hit in world.direct_space_state.intersect_shape(params, 8):
		var body: Object = hit.collider
		if body != null and body.has_method("shove"):
			body.shove(impulse)
