extends Node3D

signal picked_up(item: Item)

@export var item: Item
@export var rotation_per_second := PI / 4.0


func _ready() -> void:
	EventBus.game_reset.connect(_on_game_reset)


func _process(delta: float) -> void:
	rotation.y += rotation_per_second * delta
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	hide()
	$Area3D/CollisionShape3D.disabled = true
	$Sound.play()
	if item is Poem:
		EventBus.poem_picked_up.emit(item)
	elif item is MapPiece:
		EventBus.map_piece_picked_up.emit(item)


func _on_game_reset() -> void:
	show()
	$Area3D/CollisionShape3D.disabled = false
