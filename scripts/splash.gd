extends Decal


func _on_area_3d_body_entered(body: Node3D) -> void:
	EventBus.puddle_entered.emit()


func _on_area_3d_body_exited(body: Node3D) -> void:
	EventBus.puddle_exited.emit()
