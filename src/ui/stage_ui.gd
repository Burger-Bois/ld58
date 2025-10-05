class_name StageUI
extends Control

@onready
var score_label: Label = %ScoreLabel
@onready
var time_label: Label = %TimeLabel


func _ready() -> void:
	SignalBus.collected_updated.connect(_update_score_label)
		

func _update_score_label(score: int) -> void:
	score_label.text = str(score)

	
