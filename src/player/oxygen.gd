class_name Oxygen extends Node

@export
var value_max: float = 100.0

var _value: float = 100.0: set=_set_value

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


func _set_value(new_value) -> void:
	_value = clamp(new_value, 0, value_max)
