class_name Button2D
extends Node2D

signal pressed()


func press() -> void:
	pressed.emit()
