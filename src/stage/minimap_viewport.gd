class_name Minimap
extends SubViewport

@export
var to_follow: Node2D

@onready
var camera: Camera2D = %MinimapCamera


func _ready() -> void:
	world_2d = get_tree().root.world_2d


func _process(_delta: float) -> void:
	if is_instance_valid(to_follow):
		camera.position = to_follow.position
