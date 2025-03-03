extends Node3D

signal picked_up(item: Item)

@export var item: Item
@export var rotation_per_second := PI / 4.0

@export var poem_sound: AudioStream
@export var map_sound: AudioStream

var shape: CollisionShape3D

func _ready() -> void:
	EventBus.game_reset.connect(_on_game_reset)
	shape = $Area3D/CollisionShape3D

func _process(delta: float) -> void:
	rotation.y += rotation_per_second * delta
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	hide()
	shape.disabled = true
	$Area3D.remove_child(shape)
	
	if item is Poem:
		$Sound.stream = poem_sound
		EventBus.poem_picked_up.emit(item)
	elif item is MapPiece:
		$Sound.stream = map_sound
		EventBus.map_piece_picked_up.emit(item)
	
	$Sound.play()


func _on_game_reset() -> void:
	show()
	if $Area3D.get_child_count() == 0:
		$Area3D.add_child(shape)
	shape.disabled = false
