class_name State
extends Node
## Abstract class for AI behaviors

@onready var monster: Monster = owner as Monster

@warning_ignore("unused_parameter")
func enter(msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass

@warning_ignore("unused_parameter")
func update(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func fixed_update(delta: float) -> void:
	pass
