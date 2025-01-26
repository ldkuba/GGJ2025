extends Node3D
class_name BubbleDimension

@export var portals: Array[Portal] = []

const PORTAL_OFFSET: float = 1.0

var is_open: bool = false

@export var bubble_env: Environment
@export var bubble_camera_attributes: CameraAttributes


func _ready() -> void:
	EventBus.game_reset.connect(close_bubble)

func _close_portal(portal: Portal):
	portal.portal2.global_transform = portal.portal1.global_transform.rotated_local(Vector3(0, 1, 0), PI)
	portal.player_crossed.disconnect(_player_crossed)
	portal.portal1.set_portal_active(false)
	portal.portal2.set_portal_active(false)

func open_bubble(player_transform: Transform3D) -> void:
	if is_open: return

	print("Openning bubble dimension")

	for i in range(portals.size()):
		if i == 0:
			portals[i].portal2.global_transform = player_transform.translated_local(Vector3(0, 0, -PORTAL_OFFSET))

		else:
			var relative_to_entrance: Transform3D = portals[0].portal1.global_transform.affine_inverse() * portals[i].portal1.global_transform
			portals[i].portal2.global_transform = portals[0].portal2.global_transform * relative_to_entrance.rotated(Vector3(0, 1, 0), PI)
			portals[i].portal2.rotate_y(PI)

		portals[i].player_crossed.connect(_player_crossed)
		portals[i].portal1.camera.environment = bubble_env

		# Hide until ready
		portals[i].visible = false

	# Wait for physics frame after moving the portals
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	var entrance_colliding: bool = false

	for i in range(portals.size()):
		portals[i].visible = true
		var is_colliding: bool = portals[i].portal2.is_colliding()
		if is_colliding or entrance_colliding:
			_close_portal(portals[i])

			if i == 0:
				entrance_colliding = true
		else:
			portals[i].portal1.set_portal_active(true)
			portals[i].portal2.set_portal_active(true)

	if entrance_colliding:
		print("Entrance colliding, not openning bubble")
		return

	is_open = true

func _player_crossed(into_bubble: bool):
	if into_bubble:
		get_viewport().get_camera_3d().environment = bubble_env
		# get_viewport().get_camera_3d().camera_attributes = bubble_camera_attributes
	else:
		get_viewport().get_camera_3d().environment = null
		# get_viewport().get_camera_3d().camera_attributes = null


func close_bubble() -> void:
	if not is_open: return

	print("Closing bubble dimension")

	for i in range(portals.size()):
		_close_portal(portals[i])

	is_open = false

func toggle_bubble(player_transform: Transform3D) -> void:
	if is_open:
		close_bubble()
	else:
		open_bubble(player_transform)


func _on_enter_detection_body_entered(_body: Node3D) -> void:
	EventBus.bubble_entered.emit()


func _on_enter_detection_body_exited(_body: Node3D) -> void:
	EventBus.bubble_exited.emit()
