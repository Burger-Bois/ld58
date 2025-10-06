class_name OxygenBar extends ProgressBar

func _ready():
	SignalBus.player_oxygen_changed.connect(update_value)
	update_value(100)
	
	
func update_value(new_value: int):
	value = new_value
	if (oxygen_low()):
		self.get("theme_override_styles/background").border_color = Color(0.447, 0.11, 0.129, 1.0)
	else:
		self.get("theme_override_styles/background").border_color = Color(0.8, 0.8, 0.8)
		
	
func oxygen_low() -> bool:
	if (value/max_value) * 100 < 20:
		return true
	return false
