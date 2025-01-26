extends Control

var open := false
var poem: Poem

@onready var label: Label = $MarginContainer/MarginContainer/Label


func _ready() -> void:
	EventBus.poem_picked_up.connect(_on_poem_picked_up)
	EventBus.game_reset.connect(close)


func close() -> void:
	open = false
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.play()
	
	if poem and poem.resource_path == "res://poems/final_poem.tres":
		get_tree().quit() # TODO: Restart instead
	poem = null

func _on_poem_picked_up(p_poem: Poem) -> void:
	poem = p_poem
	label.text = poem.text
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.5)
	tw.play()
	await tw.finished
	open = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_portal") and open:
		get_viewport().set_input_as_handled()
		close()
