class_name MainMenu
extends Control

signal start_pressed()

@onready
var start_button: Button = %StartButton


func _ready() -> void:
	start_button.pressed.connect(start_pressed.emit)
