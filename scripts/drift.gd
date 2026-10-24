extends Area3D

var push := Vector3.ZERO
var air_only := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if air_only and body.has_method("is_on_floor") and body.is_on_floor():
			continue
		if body.has_method("drift"):
			body.drift(push)
