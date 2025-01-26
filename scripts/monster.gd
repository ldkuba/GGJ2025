class_name Monster
extends CharacterBody3D

@export var agent: NavigationAgent3D
@export var speed := 5.0
@export var state_machine: StateMachine
@export var sprite_root: Node3D
@export var front_sprite_calm: Sprite3D
@export var front_sprite_hostile: AnimatedSprite3D
@export var vision_ray: RayCast3D
@export var eye_socket: Node3D

@onready var home_location: Vector3
@onready var home_sprite_transform: Transform3D

func _ready() -> void:
	agent.target_position = global_position
	agent.velocity_computed.connect(_on_velocity_computed)
	home_location = global_position
	home_sprite_transform = sprite_root.transform
	EventBus.game_reset.connect(_on_game_reset)


func _physics_process(_delta: float) -> void:
	sprite_root.transform = home_sprite_transform
	vision_ray.global_position = eye_socket.global_position
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		return
	var next_path_position := agent.get_next_path_position()
	var new_velocity := global_position.direction_to(next_path_position) * speed
	if agent.avoidance_enabled:
		agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	sprite_root.look_at(Vector3(agent.target_position.x, sprite_root.global_position.y, agent.target_position.z))
	move_and_slide()


func _on_game_reset() -> void:
	state_machine.transition_to(&"Idle")
	global_position = home_location
	sprite_root.transform = home_sprite_transform
	await get_tree().physics_frame
	#state_machine.transition_to(&"Idle")
	
