extends AudioStreamPlayer

var monster_chase_count := 0

@export var chase_music: AudioStreamPlayer
@onready var playback: AudioStreamPlaybackInteractive = get_stream_playback()

func _ready() -> void:
	EventBus.monster_chase_started.connect(_on_monster_chase_started)
	EventBus.monster_chase_ended.connect(_on_monster_chase_ended)


func _on_monster_chase_started(_monster: Monster) -> void:
	monster_chase_count += 1
	if monster_chase_count == 1:
		playback.switch_to_clip_by_name(&"chase_music")


func _on_monster_chase_ended(_monster: Monster) -> void:
	monster_chase_count -= 1
	if monster_chase_count == 0:
		playback.switch_to_clip_by_name(&"maze_ambience")
