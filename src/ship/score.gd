class_name Score extends Control

@onready
var _red_score: RedScore = $RedScore

@onready
var _yellow_score: YellowScore = $YellowScore

@onready
var _blue_score: BlueScore = $BlueScore


func _get_total_score() -> int:
	return (_red_score._score + _yellow_score._score + _blue_score._score)
	
#func _physics_process(delta: float) -> void:
	#print(str(["Total: ", _get_total_score(), ", RedScore: ", _red_score._score, " YellowScore: ", _yellow_score._score, " BlueScore: ", _blue_score._score]))
