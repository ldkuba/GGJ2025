extends Node3D
class_name PortalDoor

@export var mesh: MeshInstance3D
@export var camera: Camera3D
@export var viewport: SubViewport
@export var spawn_collider: Area3D

@export var border_color: Color = Color(0, 0, 0, 1)
@export var border_size: float = 0.1

var _portal_active: bool = true

# func _input(event: InputEvent) -> void:
# 	if event is InputEventMouseButton:
# 		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
# 			set_portal_active(not _portal_active)

func set_portal_active(active: bool) -> void:
	_portal_active = active
	if _portal_active:
		mesh.set_instance_shader_parameter("portal_active", 0)
	else:
		mesh.set_instance_shader_parameter("portal_active", 1)

func _ready() -> void:
	set_portal_active(_portal_active)

func is_colliding() -> bool:
	return spawn_collider.get_overlapping_bodies().size() > 0

func _process(_delta: float) -> void:
	mesh.set_instance_shader_parameter("border_color", border_color)
	mesh.set_instance_shader_parameter("border_size", border_size)
