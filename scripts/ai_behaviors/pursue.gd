class_name Pursue
extends State

var target: Node3D


func enter(msg := {}) -> void:
	target = msg[&"target"]
	monster.front_sprite_calm.hide()
	monster.front_sprite_hostile.show()


func exit() -> void:
	target = null
	monster.front_sprite_calm.show()
	monster.front_sprite_hostile.hide()


func fixed_update(_delta: float) -> void:
	monster.agent.target_position = target.global_position
