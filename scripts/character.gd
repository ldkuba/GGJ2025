class_name Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouse_input: Vector2 = Vector2.ZERO
@export var sensitivity: Vector2 = Vector2(0.1, 0.1)

@export var camera: Camera3D

func _init() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		pass
	elif event is InputEventMouseMotion:
		mouse_input = event.relative

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle the mouse input.
	rotate_y(-mouse_input.x * sensitivity.x * delta)
	camera.rotate_x(-mouse_input.y * sensitivity.y * delta)
	mouse_input = Vector2.ZERO

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
