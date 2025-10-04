class_name PauseMenu
extends Control

signal resume_pressed()

@onready
var resume_button: Button = %ResumeButton


func _ready() -> void:
	resume_button.pressed.connect(resume_pressed.emit)
