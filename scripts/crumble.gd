extends AnimatableBody3D

var phase := 0.0
var span := 2.5
var home_y := 0.0
var home_x := 0.0
var shape: CollisionShape3D


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1
	collision_mask = 0
	home_y = position.y
	home_x = position.x
	shape = get_node_or_null("Shape") as CollisionShape3D


func _physics_process(delta: float) -> void:
	phase += delta
	var t := fposmod(phase, span) / span
	var warn := t >= 0.5 and t < 0.68
	var gone := t >= 0.68
	if gone:
		position.y = home_y - 12.0
		position.x = home_x
		if shape:
			shape.disabled = true
	else:
		position.y = home_y
		position.x = home_x + (sin(phase * 48.0) * 0.05 if warn else 0.0)
		if shape:
			shape.disabled = false
