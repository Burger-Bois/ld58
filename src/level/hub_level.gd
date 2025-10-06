class_name HubLevel
extends Level

@onready
var docking_location: Node2D = %DockingLocation


func _ready() -> void:
	generated.emit()


func docking_position() -> Vector2:
	return docking_location.global_position
