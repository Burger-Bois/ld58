class_name StageUI
extends Control

@onready
var score_label: Label = %ScoreLabel
@onready
var time_label: Label = %TimeLabel

var stage_timer: Timer


func _ready() -> void:
	SignalBus.collected_updated.connect(_update_score_label)
	SignalBus.player_oxygen_paused.connect(_pause_timer)


func _process(_delta: float) -> void:
	if is_instance_valid(stage_timer):
		SignalBus.player_oxygen_changed.emit((stage_timer.time_left/stage_timer.wait_time) * 100)
		
func _pause_timer(paused: bool) -> void:
	stage_timer.paused = paused


func _update_score_label(score: int) -> void:
	score_label.text = str(score)
