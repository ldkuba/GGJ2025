extends Node3D
class_name Portal

@export var portal1: PortalDoor
@export var portal2: PortalDoor

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().root.find_child("Player", true, false) as Player
	if player == null:
		printerr("Character node not found")
		return

	# Setup viewports
	var mat1 = portal1.mesh.get_surface_override_material(0) as ShaderMaterial
	var tex1 = mat1.get_shader_parameter("albedo_texture") as ViewportTexture
	tex1.viewport_path = portal2.viewport.get_path()

	var mat2 = portal2.mesh.get_surface_override_material(0) as ShaderMaterial
	var tex2 = mat2.get_shader_parameter("albedo_texture") as ViewportTexture
	tex2.viewport_path = portal1.viewport.get_path()

	# Setup culling masks
	portal1.camera.set_cull_mask_value(2, false)
	portal1.mesh.set_layer_mask_value(3, true)
	portal2.camera.set_cull_mask_value(3, false)
	portal2.mesh.set_layer_mask_value(2, true)

	# Disable duplicate tonemapping
	portal1.camera.environment = get_viewport().world_3d.environment.duplicate()
	portal1.camera.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	portal2.camera.environment = get_viewport().world_3d.environment.duplicate()
	portal2.camera.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR

func _get_camera_transform(portal: PortalDoor, other_portal: PortalDoor, player_camera: Camera3D) -> Transform3D:
	var playerCamToPortal: Transform3D =  portal.global_transform.affine_inverse() * player_camera.global_transform
	var transform = other_portal.global_transform * playerCamToPortal.rotated(Vector3(0, 1, 0), PI)
	return transform
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Set transform of portal1 camera
	portal1.camera.global_transform = _get_camera_transform(portal2, portal1, player.camera)
	portal1.viewport.size = get_viewport().get_visible_rect().size

	# Set transform of portal2 camera
	portal2.camera.global_transform = _get_camera_transform(portal1, portal2, player.camera)
	portal2.viewport.size = get_viewport().get_visible_rect().size
