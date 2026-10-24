extends Area3D

@export var index: int = 1
var spawn := Vector3.ZERO


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body)


func _on_body(body: Node) -> void:
	if body.has_method("reach_checkpoint"):
		body.reach_checkpoint(index, spawn)
