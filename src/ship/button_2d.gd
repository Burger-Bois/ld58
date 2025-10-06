class_name Button2D
extends Area2D

signal pressed()


func _ready() -> void:
	body_entered.connect(func(__): %Label.show())
	body_exited.connect(func(__): %Label.hide())


func press() -> void:
	pressed.emit()
