extends Sprite3D

var level: Level
@export var animation_player: AnimationPlayer
@export var overlay: Sprite3D
@export var player: Node3D
var level_max_dimensions: Vector2 = Vector2(10, 10)
var level_min_dimensions: Vector2 = Vector2(0, 0)
var aabb: AABB
var map_size: Vector2 = Vector2(1, 1)
var map_visible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level = get_tree().root.find_child("Level", true, false) as Level
	if not level:
		printerr("No level found!")
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		map_visible = not map_visible
		print("map visible: ", map_visible)
		if map_visible:
			animation_player.play("toggle_map")
		else:
			animation_player.play_backwards("toggle_map")

func _process(delta: float) -> void:
	#update dimensions
	if not aabb:
		aabb = level.get_dimensions()
		print("level aabb: ", aabb , "end: ", aabb.end)
		#aabb.position = level.global_position + aabb.position
		#aabb = level.global_transform * aabb
		print("level aabb: ", aabb , "end: ", aabb.end)
		level_max_dimensions = Vector2(aabb.end.x, aabb.end.z)
		level_min_dimensions = Vector2(aabb.position.x, aabb.position.z)
		print("level dimensions: ", level_max_dimensions, " ", level_min_dimensions)
		map_size.x = get_aabb().size.x
		map_size.y = get_aabb().size.y
		print("map size: ", map_size)

	if map_visible and player and overlay:
		overlay.rotation.z = player.rotation.y
		print("player position: ", player.position)
		print("global position: ", player.global_position)
		overlay.position.x = from_world_to_map(player.position.x, level_max_dimensions.x, level_min_dimensions.x, map_size.x)
		overlay.position.y = -from_world_to_map(player.position.z, level_max_dimensions.y, level_min_dimensions.y, map_size.y)

func from_world_to_map(x: float, max:float, min:float, size:float) -> float:
	if x < min or x > max:
		print("Detected out of bounds input: ", x, " [", min, " ", max, "]")
	var diff := max - min
	# to 0-diff
	x -= min
	# to 0-1
	x /= diff
	# to 0-size
	x *= size
	# to -size/2 - size/2
	x -= size / 2.0
	if x > size / 2.0 or x < -size / 2.0:
		print("Detected out of bounds output: ", x, " [", -size / 2.0, " ", size / 2.0, "]")
	return x
