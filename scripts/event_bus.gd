extends Node

signal game_reset

signal monster_chase_started(monster: Monster)
signal monster_chase_ended(monster: Monster)

signal bubble_entered
signal bubble_exited

signal poem_picked_up(poem: Poem)
signal map_piece_picked_up(map_piece: MapPiece)
