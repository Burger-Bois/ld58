extends Node

signal collected_updated(collected: int)

signal player_oxygen_changed(new_value: int)

signal player_oxygen_paused(paused: bool)

signal player_sprinting(is_sprinting: bool)

signal add_to_red_score(score: int)

signal add_to_yellow_score(score: int)

signal add_to_blue_score(score: int)

signal game_over()
