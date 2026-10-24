extends Node3D

var spin_y := 0.0
var sway := 0.0
var phase := 0.0


func _process(delta: float) -> void:
	phase += delta
	if spin_y != 0.0:
		rotation.y += spin_y * delta
	if sway != 0.0:
		rotation.z = sin(phase * 1.4) * sway
