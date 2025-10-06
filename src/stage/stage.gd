class_name Stage
extends Node2D

signal finished()
signal completed()

const LEVEL_SCENE := preload('res://src/level/level.tscn') as PackedScene
const SHIP_SCENE := preload('res://src/ship/ship.tscn') as PackedScene
const PLAYER_SCENE := preload('res://src/player/player.tscn') as PackedScene
const RED_ITEM_SCENE := preload('res://src/item/red_item.tscn') as PackedScene
const YELLOW_ITEM_SCENE := preload('res://src/item/yellow_item.tscn') as PackedScene
const BLUE_ITEM_SCENE := preload('res://src/item/blue_item.tscn') as PackedScene


@export
var end_time: float = 120.0
@export
var item_count: int = 32

@onready
var end_menu: EndMenu = %EndMenu
@onready
var pause_menu: PauseMenu = %PauseMenu
@onready
var pauser: Pauser = %Pauser
@onready
var minimap: Minimap = %Minimap

var _level: Level

func _init() -> void:
	SignalBus.game_over.connect(_game_over)

func _ready() -> void:
	_level = LEVEL_SCENE.instantiate()
	_level.generated.connect(start)
	add_child(_level, true)

	end_menu.main_menu_pressed.connect(finished.emit)
	pause_menu.main_menu_pressed.connect(finished.emit)


func start() -> void:
	var ship_spawn_location := _level.docking_position()
	var ship := SHIP_SCENE.instantiate() as Ship
	ship.position = ship_spawn_location
	ship.leave_pressed.connect(completed.emit)
	add_child(ship)

	var player := PLAYER_SCENE.instantiate() as Player
	player.position = ship_spawn_location
	add_child(player)

	var camera := Camera2D.new()
	player.add_child(camera)

	minimap.to_follow = player

	for i in range(50):
		var item_spawn_position := _level.random_in_bounds()
		var item := getNewItem()
		item.position = item_spawn_position
		add_child(item)

func getNewItem() -> Item:
	var i = randi_range(0, 2)
	if i == 0:
		return YELLOW_ITEM_SCENE.instantiate()
		
	if i == 1:
		return RED_ITEM_SCENE.instantiate()
	
	return BLUE_ITEM_SCENE.instantiate()

func _game_over() -> void:
	pauser.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	end_menu.show()
