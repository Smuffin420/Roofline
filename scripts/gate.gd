extends AnimatableBody3D

var period := 3.2
var phase := 0.0
var lowered := false
var base_y := 0.0
var drop := 2.55


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1
	collision_mask = 0
	base_y = position.y


func toggle() -> void:
	lowered = not lowered


func _physics_process(delta: float) -> void:
	var target := base_y - drop if lowered else base_y
	position.y = move_toward(position.y, target, delta * 7.0)
