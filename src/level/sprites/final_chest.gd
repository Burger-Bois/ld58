class_name FinalChest
extends StaticBody2D

@export
var artifact_scene: PackedScene


func _ready() -> void:
	%OpenArea.area_entered.connect(func(_area): open())


func open() -> void:
	var artifact := artifact_scene.instantiate() as Node2D
	artifact.global_position = global_position
	add_sibling(artifact)
	queue_free()
