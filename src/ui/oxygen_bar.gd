class_name OxygenBar extends ProgressBar

func _ready():
	SignalBus.player_oxygen_changed.connect(update_value)
	
func update_value(new_value: int):
	value = new_value
