extends Node3D
class_name Level

@export var floor: VisualInstance3D


func get_dimensions() -> AABB:
	var aabb: AABB = floor.get_aabb()
	print("aabb: ", aabb)
	return floor.global_transform * aabb
