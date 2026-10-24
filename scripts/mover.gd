extends AnimatableBody3D

var period := 3.2
var travel := 2.6
var phase := 0.0
var axis := Vector3(1, 0, 0)
var origin := Vector3.ZERO


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1
	collision_mask = 0
	origin = position


func _physics_process(delta: float) -> void:
	phase += delta
	var along := axis
	if along.length() < 0.01:
		along = Vector3(1, 0, 0)
	position = origin + along.normalized() * sin(phase * TAU / period) * travel
