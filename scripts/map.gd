class_name Map
extends Sprite3D

var level: Level
@export var animation_player: AnimationPlayer
@export var overlay: Sprite3D
@export var player: Player
@export var map_75: Texture2D
@export var map_100: Texture2D
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
	texture = map_75
	player.died.connect(close_map)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		print("map visible: ", map_visible)
		if not map_visible:
			open_map()
		else:
			close_map()
	if event.is_action_pressed("ui_accept"):
		unlock_map()

func unlock_map() -> void:
		texture = map_100

func open_map() -> void:
	if map_visible:
		print("map already open")
		return
	map_visible = true
	animation_player.play("toggle_map")
	$"../../../../MapOpenSound".play()

func close_map() -> void:
	if not map_visible:
		print("map already closed")
		return
	map_visible = false
	animation_player.play_backwards("toggle_map")
	$CloseSound.play()

func _process(_delta: float) -> void:
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
		map_size.y = map_size.x * level_max_dimensions.y / level_max_dimensions.x
		print("map size: ", map_size)

	if map_visible and player and overlay:
		overlay.rotation.z = player.rotation.y
		overlay.position.x = from_world_to_map(player.position.x, level_max_dimensions.x, level_min_dimensions.x, map_size.x)
		overlay.position.y = -from_world_to_map(player.position.z, level_max_dimensions.y, level_min_dimensions.y, map_size.y)

func from_world_to_map(x: float, max:float, min:float, size:float) -> float:
	if x < min or x > max:
		# print("Detected out of bounds input: ", x, " [", min, " ", max, "]")
		pass
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
		# print("Detected out of bounds output: ", x, " [", -size / 2.0, " ", size / 2.0, "]")
		pass
	return x
