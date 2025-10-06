class_name WinMenu extends Control

signal main_menu_pressed()

@onready
var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	main_menu_button.pressed.connect(main_menu_pressed.emit)
