extends AnimatableBody3D

var period := 2.6
var travel := 0.42
var phase := 0.0
var origin_x := 0.0


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1
	collision_mask = 0
	origin_x = position.x


func _physics_process(delta: float) -> void:
	phase += delta
	position.x = origin_x + sin(phase * TAU / period) * travel
