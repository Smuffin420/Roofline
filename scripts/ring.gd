extends Area3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_hit)


func _hit(body: Node) -> void:
	if body.has_method("ring"):
		body.ring()
