class_name Pursue
extends State

var target: Node3D


func enter(msg := {}) -> void:
	target = msg[&"target"]


func fixed_update(delta: float) -> void:
	monster.agent.target_position = target.global_position
