class_name Idle
extends State

@export var detection_area: Area3D

var tracking: Player


func enter(_msg := {}) -> void:
	monster.agent.target_position = monster.home_location
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)


func exit() -> void:
	detection_area.body_entered.disconnect(_on_detection_body_entered)
	detection_area.body_exited.disconnect(_on_detection_body_exited)
	tracking = null


func _on_detection_body_entered(body: Node3D) -> void:
	if body is not Player: return
	tracking = body


func _on_detection_body_exited(body: Node3D) -> void:
	if body is not Player: return
	tracking = body


func fixed_update(_delta: float) -> void:
	if not tracking: return
	monster.vision_ray.target_position = (tracking.global_position - monster.vision_ray.global_position)
	monster.vision_ray.force_raycast_update()
	var collider := monster.vision_ray.get_collider()
	print(collider)
	if collider == tracking:
		state_machine.transition_to(&"Pursue", { &"target": tracking })
