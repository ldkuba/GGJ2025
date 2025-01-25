extends Node3D
class_name PortalDoor

@export var mesh: MeshInstance3D
@export var camera: Camera3D
@export var viewport: SubViewport

@export var border_color: Color = Color(0, 0, 0, 1)
@export var border_size: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh.set_instance_shader_parameter("border_color", border_color)
	mesh.set_instance_shader_parameter("border_size", border_size)
