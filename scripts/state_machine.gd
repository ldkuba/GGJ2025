class_name StateMachine
extends Node

var state: State

var states: Dictionary


func _ready() -> void:
	for child in get_children():
		if child is not State: continue
		states[child.name] = child
		if state == null:
			transition_to(child.name)


func _process(delta: float) -> void:
	if state:
		state.update(delta)


func _physics_process(delta: float) -> void:
	if state:
		state.fixed_update(delta)


func transition_to(target_state: StringName, message: Dictionary = {}) -> void:
	if state: state.exit()
	assert(states.has(target_state), "State '%s' does not exist" % target_state)
	print("'%s' is transitioning to state '%s'" % [owner, target_state])
	state = states[target_state]
	state.enter(message)
	
