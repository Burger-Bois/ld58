class_name YellowScore extends ProgressBar

@onready
var label: Label = $YellowScoreLabel

var _score: int = 0

func _ready():
	SignalBus.add_to_yellow_score.connect(update_value)
	value = _score
	label.text = str(_score)
	
func update_value(points_to_add: int):
	_score += points_to_add
	value = _score
	label.text = str(_score)
