extends Node3D
class_name Portal

@export var portal1: PortalDoor
@export var portal2: PortalDoor

var player: Player
var player_last_pos: Vector3 = Vector3.ZERO

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

func _crossed_portal(portal: PortalDoor, player_pos: Vector3, near_delta: float) -> bool:
	var portal_a: Vector3 = portal.global_position + portal.global_transform.basis.x * 0.5 + player.camera.global_transform.basis.z * near_delta
	var portal_b: Vector3 = portal.global_position - portal.global_transform.basis.x * 0.5 + player.camera.global_transform.basis.z * near_delta
	var portal_a_xz: Vector2 = Vector2(portal_a.x, portal_a.z)
	var portal_b_xz: Vector2 = Vector2(portal_b.x, portal_b.z)
	var player_pos_xz: Vector2 = Vector2(player_pos.x, player_pos.z)
	var player_last_pos_xz: Vector2 = Vector2(player_last_pos.x, player_last_pos.z)

	var direction: int = sign((player_pos - player_last_pos).cross(portal_b - portal_a).y)

	return Geometry2D.segment_intersects_segment(player_pos_xz, player_last_pos_xz, portal_a_xz, portal_b_xz) != null && direction == 1

func _get_camera_transform(portal: PortalDoor, other_portal: PortalDoor, player_camera: Camera3D) -> Transform3D:
	var playerCamToPortal: Transform3D =  portal.global_transform.affine_inverse() * player_camera.global_transform
	var t: Transform3D = other_portal.global_transform * playerCamToPortal.rotated(Vector3(0, 1, 0), PI)
	return t

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Set transform of portal1 camera
	portal1.camera.global_transform = _get_camera_transform(portal2, portal1, player.camera)
	portal1.viewport.size = get_viewport().get_visible_rect().size

	# Set transform of portal2 camera
	portal2.camera.global_transform = _get_camera_transform(portal1, portal2, player.camera)
	portal2.viewport.size = get_viewport().get_visible_rect().size

	# Handle teleporting player
	var player_pos: Vector3 = player.global_position
	# if player_last_pos != player_pos:
	var near_delta: float = player.camera.near
	if _crossed_portal(portal1, player_pos, near_delta):
		var playerRelativePortal1: Transform3D = portal1.global_transform.affine_inverse() * player.global_transform
		player.global_transform = portal2.global_transform * playerRelativePortal1.rotated(Vector3(0, 1, 0), PI)
		player.global_position += portal2.global_transform.basis.z * near_delta
	elif _crossed_portal(portal2, player_pos, near_delta):
		var playerRelativePortal2: Transform3D = portal2.global_transform.affine_inverse() * player.global_transform
		player.global_transform = portal1.global_transform * playerRelativePortal2.rotated(Vector3(0, 1, 0), PI)
		player.global_position += portal1.global_transform.basis.z * near_delta

	player_last_pos = player_pos