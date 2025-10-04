class_name Pauser
extends Node

@onready
var pause_menu: PauseMenu = %PauseMenu

var paused := false:
	set=set_paused


func _ready() -> void:
	pause_menu.resume_pressed.connect(set_paused.bind(false))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		paused = not paused


func set_paused(new_paused: bool) -> void:
	paused = new_paused
	pause_menu.visible = paused
	get_tree().paused = new_paused
