extends AudioStreamPlayer

var monster_chase_count := 0

@export var chase_music: AudioStreamPlayer
@onready var playback: AudioStreamPlaybackInteractive = get_stream_playback()


func _ready() -> void:
	EventBus.monster_chase_started.connect(_on_monster_chase_started)
	EventBus.monster_chase_ended.connect(_on_monster_chase_ended)
	EventBus.bubble_entered.connect(_on_bubble_entered)
	EventBus.bubble_exited.connect(_on_bubble_exited)


func _on_monster_chase_started(_monster: Monster) -> void:
	monster_chase_count += 1
	if monster_chase_count == 1:
		playback.switch_to_clip_by_name(&"chase_music")


func _on_monster_chase_ended(_monster: Monster) -> void:
	monster_chase_count -= 1
	if monster_chase_count == 0:
		playback.switch_to_clip_by_name(&"maze_ambience")


func _on_bubble_entered() -> void:
	playback.switch_to_clip_by_name(&"bubble_ambience")


func _on_bubble_exited() -> void:
	if monster_chase_count == 0:
		playback.switch_to_clip_by_name(&"maze_ambience")
	else:
		playback.switch_to_clip_by_name(&"chase_music")
