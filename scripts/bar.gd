extends AnimatableBody3D

var period := 2.4
var phase := 0.0
var low_y := 0.56
var high_y := 1.24
var _base_y := 0.0


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1
	collision_mask = 0
	_base_y = position.y
	_apply_height()


func _physics_process(delta: float) -> void:
	phase += delta
	_apply_height()


func _apply_height() -> void:
	var wave := sin(phase * TAU / period)
	var t := 0.0
	if wave >= 0.32:
		t = 1.0
	elif wave <= -0.32:
		t = 0.0
	else:
		t = (wave + 0.32) / 0.64
	position.y = _base_y + lerpf(low_y, high_y, t)
