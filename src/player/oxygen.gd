class_name Oxygen extends Node

var _value: float = 100.0

var oxygen_paused: bool = true

func _init() -> void:
	SignalBus.player_oxygen_paused.connect(_handle_oxygen_pause)
	SignalBus.player_oxygen_changed.emit(_value)

func reduce_oxygen(minus: float) -> void:
	if !oxygen_paused:
		_value -= minus
		SignalBus.player_oxygen_changed.emit(_value)
		if _value <= 0:
			SignalBus.game_over.emit()

func _handle_oxygen_pause(is_paused: bool) -> void:
	oxygen_paused = is_paused
