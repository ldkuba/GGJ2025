extends Node3D
class_name Level

@export var floor: VisualInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_dimensions() -> AABB:
	var aabb: AABB = floor.get_aabb()
	print("aabb: ", aabb)
	return floor.global_transform * aabb
