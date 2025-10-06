class_name Main
extends Node

const stage_scene: PackedScene = preload('res://src/stage/stage.tscn')

@onready
var main_menu: MainMenu = %MainMenu

var _stage: Stage

func _ready() -> void:
	main_menu.start_pressed.connect(start)


func start() -> void:
	end()
	main_menu.hide()
	_stage = stage_scene.instantiate()
	_stage.finished.connect(end)
	add_child(_stage)
	_stage.load_level()


func end() -> void:
	if is_instance_valid(_stage):
		_stage.process_mode = Node.PROCESS_MODE_DISABLED
		_stage.queue_free()
	main_menu.show()
	get_tree().paused = false
