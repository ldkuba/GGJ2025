extends Sprite3D

@export var animation_player: AnimationPlayer
@export var overlay: Sprite3D
@export var player: Node3D
@export var level_max_dimensions: Vector2 = Vector2(10, 10)
@export var level_min_dimensions: Vector2 = Vector2(0, 0)
@export var map_size: Vector2 = Vector2(1, 1)
var map_visible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		map_visible = not map_visible
		print("map visible: ", map_visible)
		if map_visible:
			animation_player.play("toggle_map")
		else:
			animation_player.play_backwards("toggle_map")

func _process(delta: float) -> void:
	if map_visible and player and overlay:
		overlay.rotation.z = player.rotation.y
		overlay.position.x = from_world_to_map(player.position.x, level_max_dimensions.x, level_min_dimensions.x, map_size.x)
		overlay.position.y = from_world_to_map(player.position.z, level_max_dimensions.y, level_min_dimensions.y, map_size.y)

func from_world_to_map(x: float, max:float, min:float, size:float) -> float:
	var diff := max - min
	return (x - min - diff * 0.5) / diff * size
