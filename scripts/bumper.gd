extends StaticBody3D

var _squash := 0.0


func boop() -> void:
	_squash = 1.0


func _process(delta: float) -> void:
	var bag := get_node_or_null("Bag") as Node3D
	if bag == null:
		return
	_squash = move_toward(_squash, 0.0, delta * 3.4)
	var wide := 1.0 + _squash * 0.16
	var tall := 1.0 - _squash * 0.22
	bag.scale = Vector3(wide, tall, wide)
