extends Sprite3D

@export var animation_player: AnimationPlayer
@export var overlay: Sprite3D
@export var player: Node3D
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
		# Update overlay rotation to match player's Y rotation
		overlay.rotation.z = player.rotation.y
