class_name Pursue
extends State

var target: Node3D
var eyes_on_target := false

@export var search_timer: Timer
@export var detected_sound: AudioStreamPlayer3D


func _ready() -> void:
	search_timer.timeout.connect(_on_search_timer_timeout)


func enter(msg := {}) -> void:
	target = msg[&"target"]
	monster.front_sprite_calm.hide()
	monster.front_sprite_hostile.show()
	monster.agent.navigation_finished.connect(_on_navigation_finished)
	detected_sound.play()
	EventBus.monster_chase_started.emit(monster)


func exit() -> void:
	target = null
	monster.front_sprite_calm.show()
	monster.front_sprite_hostile.hide()
	monster.agent.navigation_finished.disconnect(_on_navigation_finished)
	search_timer.stop()
	EventBus.monster_chase_ended.emit(monster)


func fixed_update(_delta: float) -> void:
	if not target: return
	
	monster.vision_ray.target_position = (target.global_position - monster.vision_ray.global_position)
	monster.vision_ray.force_raycast_update()
	var collider := monster.vision_ray.get_collider()
	eyes_on_target = (collider == target)
	
	if eyes_on_target:
		monster.agent.target_position = target.global_position
		search_timer.stop()


func _on_navigation_finished() -> void:
	if not eyes_on_target:
		search_timer.start()


func _on_search_timer_timeout() -> void:
	state_machine.transition_to(&"Idle")
