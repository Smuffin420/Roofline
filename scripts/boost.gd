extends Area3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_hit)


func _hit(body: Node) -> void:
	if bool(get_meta("wall", false)) and body.has_method("boost_along"):
		body.boost_along()
		return
	if body.has_method("boost"):
		body.boost(bool(get_meta("back", false)))
