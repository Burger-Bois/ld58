class_name Ship
extends Node2D

signal leave_pressed()

@onready
var leave_button: Button2D = %LeaveButton

@onready
var score: Label = %Score


func _ready() -> void:
	leave_button.pressed.connect(leave_pressed.emit)
	SignalBus.collected_updated.connect(_update_score)
	
func _update_score(newScore: int) -> void:
	score.text = str(newScore)
