class_name Ship
extends Node2D

signal leave_pressed()

@onready
var leave_button: Button2D = %LeaveButton


func _ready() -> void:
	leave_button.pressed.connect(leave_pressed.emit)
