class_name Stage
extends Node2D

signal finished()

@export
var end_time: float = 120.0

@onready
var end_menu: EndMenu = %EndMenu
@onready
var pause_menu: PauseMenu = %PauseMenu
@onready
var pauser: Pauser = %Pauser
@onready
var stage_ui: StageUI = %StageUI


func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = end_time
	timer.autostart = true
	timer.timeout.connect(game_over)
	add_child(timer)
	stage_ui.stage_timer = timer

	end_menu.main_menu_pressed.connect(finished.emit)
	pause_menu.main_menu_pressed.connect(finished.emit)



func game_over() -> void:
	pauser.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	end_menu.show()
