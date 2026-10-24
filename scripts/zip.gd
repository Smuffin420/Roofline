extends Area3D

var a := Vector3.ZERO
var b := Vector3.ZERO


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_catch)


func setup(from: Vector3, to: Vector3) -> void:
	a = from
	b = to


func _catch(body: Node) -> void:
	if body.has_method("catch_zip"):
		body.catch_zip(a, b)
