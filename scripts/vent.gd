extends Area3D

var phase := 0.0
var period := 1.65
var plume: MeshInstance3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	plume = get_node_or_null("Plume") as MeshInstance3D


func _physics_process(delta: float) -> void:
	phase += delta
	var wave := sin(phase * TAU / period)
	var hot := wave > 0.62
	if plume:
		plume.scale = Vector3(1.0, 0.2 + maxf(wave, 0.0) * 1.5, 1.0)
		plume.visible = wave > 0.05
	if not hot:
		return
	for body in get_overlapping_bodies():
		if body.has_method("pop"):
			body.pop()
