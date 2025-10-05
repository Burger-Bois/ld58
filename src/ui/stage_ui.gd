class_name StageUI
extends Control

@onready
var score_label: Label = %ScoreLabel
@onready
var time_label: Label = %TimeLabel

var stage_timer: Timer


func _ready() -> void:
	SignalBus.collected_updated.connect(_update_score_label)


func _process(_delta: float) -> void:
	if is_instance_valid(stage_timer):
		time_label.text = str(int(stage_timer.time_left))


func _update_score_label(score: int) -> void:
	score_label.text = str(score)
