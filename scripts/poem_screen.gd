extends Control

var open := false

@onready var label: Label = $MarginContainer/MarginContainer/Label


func _ready() -> void:
	EventBus.poem_picked_up.connect(_on_poem_picked_up)


func close() -> void:
	open = false
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.play()


func _on_poem_picked_up(poem: Poem) -> void:
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
