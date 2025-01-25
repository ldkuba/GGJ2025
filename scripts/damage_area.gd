class_name DamageArea
extends Area3D

@export var damage_per_second: float = 1.0

var player: Player

func _on_body_entered(body: Node3D) -> void:
	if body is not Player: return
	player = body


func _on_body_exited(body: Node3D) -> void:
	if body is not Player: return
	player = null


func _physics_process(delta: float) -> void:
	if not player: return
	player.health -= damage_per_second * delta
