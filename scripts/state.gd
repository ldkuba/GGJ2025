class_name State
extends Node
## Abstract class for AI behaviors

@onready var monster: Monster = owner as Monster


func enter(msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func update(delta: float) -> void:
	pass


func fixed_update(delta: float) -> void:
	pass
