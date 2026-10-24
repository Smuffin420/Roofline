extends Node3D

var phase := 0.0
var period := 2.15
var board: Node3D
var area: Area3D


func _ready() -> void:
	board = get_node_or_null("Board") as Node3D
	if board:
		area = board.get_node_or_null("Hit") as Area3D


func _physics_process(delta: float) -> void:
	phase += delta
	var ang := sin(phase * TAU / period) * 1.05
	if board:
		board.rotation.z = ang
	if area == null or absf(ang) > 0.42:
		return
	var side := signf(cos(phase * TAU / period))
	if side == 0.0:
		side = 1.0
	for body in area.get_overlapping_bodies():
		if body.get("sliding") == true:
			continue
		if body.has_method("shove"):
			body.shove(Vector3(side * 7.5, 5.5, 5.0), "Sign")
