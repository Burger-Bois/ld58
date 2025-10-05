class_name OxygenBar extends ProgressBar
@onready var _label := $TimeLabel as Label


func _ready():
	SignalBus.player_oxygen_changed.connect(update_value)
	
func update_value(new_value: int):
	value = new_value
	_label.text = str(new_value)
