extends Node3D

var period := 2.6
var phase := 0.0
var rotor: Node3D


func _ready() -> void:
	rotor = get_node_or_null("Rotor") as Node3D
	if rotor:
		rotor.rotation.z = phase


func _physics_process(delta: float) -> void:
	phase += delta * TAU / period
	if rotor == null:
		return
	rotor.rotation.z = phase
	for blade in rotor.get_children():
		var area := blade.get_node_or_null("Hit") as Area3D
		if area == null:
			continue
		var side := signf(area.global_position.x - global_position.x)
		if side == 0.0:
			side = 1.0
		for body in area.get_overlapping_bodies():
			if body.has_method("shove"):
				body.shove(Vector3(side * 6.5, 6.0, 8.0), "Mill")
