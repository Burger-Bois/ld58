class_name Main
extends Node

const stage_scene: PackedScene = preload('res://src/stage/stage.tscn')

@onready
var main_menu: MainMenu = %MainMenu

func _ready() -> void:
	main_menu.start_pressed.connect(start)


func start() -> void:
	main_menu.hide()
	var stage := stage_scene.instantiate()
	add_child(stage)
