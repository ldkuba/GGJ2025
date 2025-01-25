class_name Monster
extends CharacterBody3D

@export var agent: NavigationAgent3D
@export var speed := 5.0
@export var state_machine: StateMachine
@export var sprite: Sprite3D


func _ready() -> void:
	agent.target_position = global_position
	agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta: float) -> void:
	var next_path_position := agent.get_next_path_position()
	var new_velocity := global_position.direction_to(next_path_position) * speed
	if agent.avoidance_enabled:
		agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)


func _on_detection_body_entered(body: Node3D) -> void:
	if body is Player:
		state_machine.transition_to(&"Pursue", { &"target": body })


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	sprite.look_at(agent.target_position)
	move_and_slide()
