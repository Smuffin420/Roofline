extends AnimatableBody3D

var period := 1.15
var travel := 1.9
var phase := 0.0
var axis := Vector3(1, 0, 0)
var origin := Vector3.ZERO
var blade: Node3D


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1
	collision_mask = 0
	origin = position
	blade = get_node_or_null("Blade") as Node3D


func _physics_process(delta: float) -> void:
	phase += delta
	position = origin + axis.normalized() * sin(phase * TAU / period) * travel
	if blade:
		blade.rotate_z(-delta * 16.0)
