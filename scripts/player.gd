class_name Player
extends CharacterBody3D
## Resolution and FPS independent camera controller made by YoSoyFreeman.

signal died

var health := 5.0:
	set = set_health
var alive := true
var inside_bubble := false

@onready var home_location: Transform3D
@export var health_regain_per_second := 0.1
@export var max_health := 5.0
@export var death_screen: Control
var map: Map
@export var anim_player: AnimationPlayer

@export var dry_footsteps: AudioStream
@export var wet_footsteps: AudioStream

## Head node.
@export var head : Node3D
@export var camera: Camera3D

## Bubble dimensions
@export var bubble_dimensions: Array[BubbleDimension] = []
var active_bubble: BubbleDimension = null


@export_category("Settings")
@export_group("Camera")

## Max camera pitch in degrees.
@export_range(-90, 90, 0.1, "degrees") var max_pitch: float = 90

## Min camera pitch in degrees.
@export_range(-90, 90, 0.1, "degrees") var min_pitch: float = -90

@export_subgroup("Mouse", "mouse_")

## How many degrees the camera rotates by each unit reported by the mouse.
## This should be an small value and depends on your intended exposed [member sensitivity]. [br][br]
## The default value is meant to work with a sensitivity of [b]5[/b], in a range of [b]0 - 10[/b].
@export_range(0.01, 0.01, 0.01, "hide_slider", "or_greater", "degrees") var mouse_degrees_per_unit: float = 0.01

## The sensitivity the user is meant to adjust.[br] [br]If [member mouse_degrees_per_unit] is [b]0.5[/b]
## and this value is set to [b]2[/b] the final result will be [b]1[/b] degree of rotation by each unit.
@export_range(0.1, 10, 0.05, "or_greater") var mouse_sensitivity: float = 5

@export_subgroup("joystick", "joystick_")

## How many degrees per second the camera will rotate when the Joystick is fully tilted. [br][br]
## The default value is meant to work with a sensitivity of [b]5[/b], in a range of [b]0 - 10[/b].
@export_range(0.001, 10, 0.001, "hide_slider", "or_greater", "degrees") var joystick_degrees_per_second: float = 36

## Exponent to which the joystick input will be raised to.[br][br]
## Smaller values are more reactive, while bigger ones allow for finer movement when the tilting is subtle.
@export_exp_easing("positive_only") var joystick_exp: float = 2

## The sensitivity the user is meant to adjust. [br][br] If [member joystick_degrees_per_second] is [b]180[/b]
## and this value is set to [b]2[/b] the final result will be [b]360[/b] degrees of rotation per second.
@export_range(0.1, 10, 0.01, "or_greater") var joystick_sensitivity: float = 5

@export_group("Movement")

@export_subgroup("Acceleration")

## Ground acceleration.
@export var ground_acceleration: float = 250

## Air acceleration.
@export var air_acceleration: float = 0
@export_subgroup("Friction")

## Determines if the velocity along the [member up_direction] will be taken
## into account while calculating friction.
@export var apply_vertical_friction: bool = false

## Decay factor for friction.
@export_range(0, 50) var ground_friction: float = 25

## Decay factor for air friction.
@export_range(0, 50) var air_friction: float = 0

var walking := false


func _ready() -> void:
	Input.set_use_accumulated_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	home_location = global_transform
	print("Home location is: ", home_location)
	died.connect(_on_died)

	map = find_child("Map", true, false) as Map
	if not map:
		printerr("No map found!")
	
	if bubble_dimensions.size() > 0:
		print("Setting bubble dimension")
		active_bubble = bubble_dimensions[0]
		active_bubble.portals[0].player_crossed.connect(_crossed_portal)
		active_bubble.portals[1].player_crossed.connect(_crossed_portal)
	
	EventBus.puddle_entered.connect(_on_puddle_entered)
	EventBus.puddle_exited.connect(_on_puddle_exited)


func _crossed_portal(into_bubble: bool) -> void:
	inside_bubble = into_bubble
	if into_bubble:
		map.close_map()


func _unhandled_input(event: InputEvent)->void:
	if not alive: return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventKey:
			if event.is_action_pressed("ui_cancel"):
				get_tree().quit()

		if event is InputEventMouseButton:
			if event.button_index == 1:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		return

	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif event.is_action_pressed("use_portal") and not inside_bubble:
			print("E pressed")
			if not map.map_visible:
				map.open_map()
			elif active_bubble != null:
				print("Portal used")
				if active_bubble.is_open:
					active_bubble.close_bubble()
				$PortalOpenSound.play()
				map.close_map()
				active_bubble.open_bubble(global_transform)
		elif event.is_action_pressed("toggle_map") and not inside_bubble:
			if map.map_visible:
				map.close_map()
			else:
				map.open_map()
		elif event.is_action_pressed("unstuck") and not inside_bubble:
			if map.map_visible:
				map.close_map()
			global_transform = home_location
			print("Returning to home location(unstuck): ", home_location)
		return

	if event is InputEventMouseMotion:
		mouse_look(event)

func _physics_process(delta: float) -> void:
	if not alive: return
	health += health_regain_per_second * delta
	
	#joystick_look(delta)
	
	if is_on_floor():	
		accelerate(ground_acceleration, delta)
		apply_friction(ground_friction, delta)
		
	else:
		apply_gravity(delta)
		accelerate(air_acceleration, delta)
		apply_friction(air_friction, delta)
	
	move_and_slide()
	
	if velocity.length() > 0.1:
		if not walking:
			walking = true
			anim_player.play(&"footsteps")
	else:
		walking = false
		anim_player.stop()


#func joystick_look(delta) -> void:
	#return
	## ATTENTION: Add the following inputs to your project or replace the following line with your own ones.
	#var motion: Vector2 = Input.get_vector("look_left", "look_right", "look_down", "look_up")
#
	#if joystick_exp != 1:
		#motion = motion.normalized() * pow(motion.length(), joystick_exp)
#
	#motion *= joystick_degrees_per_second
	#motion *= joystick_sensitivity
	#motion *= delta
#
	#add_yaw(motion.x)
	#add_pitch(-motion.y)
	#clamp_pitch()


## Handles aim look with the mouse.
func mouse_look(event: InputEventMouseMotion)-> void:
	var motion: Vector2 = event.screen_relative

	motion *= mouse_degrees_per_unit
	motion *= mouse_sensitivity

	add_yaw(motion.x)
	add_pitch(motion.y)
	clamp_pitch()


## Rotates the character around the local Y axis by a given amount (In degrees) to achieve yaw.
func add_yaw(amount: float) -> void:
	if is_zero_approx(amount):
		return

	rotate_object_local(Vector3.DOWN, deg_to_rad(amount))
	orthonormalize()


## Rotates the head around the local x axis by a given amount (In degrees) to achieve pitch.
func add_pitch(amount: float) -> void:
	if is_zero_approx(amount):
		return

	head.rotate_object_local(Vector3.LEFT, deg_to_rad(amount))
	head.orthonormalize()


## Clamps the pitch between min_pitch and max_pitch.
func clamp_pitch()->void:
	if head.rotation.x > deg_to_rad(min_pitch) and head.rotation.x < deg_to_rad(max_pitch):
		return

	head.rotation.x = clamp(head.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	head.orthonormalize()


## Accelerates the character using linear acceleration.
func accelerate(accel: float, delta: float) -> void:
	if not alive: return
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_backwards", "move_forward")
	var input_direction: Vector3 = transform.basis.orthonormalized() * Vector3(input_vector.x, 0, -input_vector.y)
	velocity += input_direction * accel  * delta


## Applies gravity to the body.
func apply_gravity(delta: float) -> void:
	velocity += get_gravity() * delta


## Aplies friction to the body using fps independent exponential decay.
func apply_friction(friction: float, delta: float) -> void:
	if apply_vertical_friction:
		velocity = velocity * exp(-friction * delta)
		return
	
	var vertical_velocity: Vector3 = velocity.project(up_direction)
	var horizontal_velocity: Vector3 = velocity - vertical_velocity
	
	horizontal_velocity = horizontal_velocity * exp(-friction * delta)
	velocity = horizontal_velocity + vertical_velocity
	
	# Freya Holmer's exponential decay formula:
	# b + (a - b) * exp(-decay * delta)
	# For friction we always decay towards zero, so we can simplify to:
	# (a) * exp(-decay * delta)
	# Use the original formula in order to decay towards non zero velocities (for custom moving platforms, for example)


func set_health(value: float) -> void:
	value = clamp(value, 0, max_health)
	if value == health: return
	if health > 0 and value == 0.0:
		died.emit()
		
	health = value
	alive = health > 0


func _on_died() -> void:
	alive = false
	$DeathSound.play()
	var tw := get_tree().create_tween()
	tw.tween_property(death_screen, "modulate:a", 1.0, 1.0)
	tw.tween_interval(1.0)
	tw.play()
	await tw.finished
	health = max_health
	global_transform = home_location
	print("Returning to home location(death): ", home_location)
	
	death_screen.modulate.a = 0.0
	get_tree().paused = true
	EventBus.game_reset.emit()
	await get_tree().physics_frame
	get_tree().paused = false


func _on_puddle_entered() -> void:
	var anim := anim_player.get_animation(&"footsteps")
	anim.audio_track_set_key_stream(0, 0, wet_footsteps)


func _on_puddle_exited() -> void:
	var anim := anim_player.get_animation(&"footsteps")
	anim.audio_track_set_key_stream(0, 0, dry_footsteps)
