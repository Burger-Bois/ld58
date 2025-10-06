class_name Stage
extends Node2D

signal finished()

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

enum State {
	LOADING,
	PLAYING,
	PAUSED,
}
var _state: State = State.LOADING: set=set_state

var _level: Level
var _ship: Ship
var _player: Player

func _init() -> void:
	SignalBus.game_over.connect(_game_over)

func _ready() -> void:
	_state = _state

	end_menu.main_menu_pressed.connect(finished.emit)
	pause_menu.main_menu_pressed.connect(finished.emit)

	_ship = SHIP_SCENE.instantiate() as Ship
	_ship.process_mode = Node.PROCESS_MODE_DISABLED
	_ship.leave_pressed.connect(load_level)
	add_child(_ship)

	_player = PLAYER_SCENE.instantiate() as Player
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_player)

	var camera := Camera2D.new()
	_player.add_child(camera)

	minimap.to_follow = _player


func load_level() -> void:
	_state = State.LOADING

	# Clear current level
	if is_instance_valid(_level):
		_level.queue_free()
		_level = null

	# Create level
	_level = LEVEL_SCENE.instantiate()
	_level.generated.connect(spawn_entities)
	%Level.add_child(_level, true)


func spawn_entities() -> void:
	# Place ship and player
	var ship_spawn_location := _level.docking_position()
	_ship.position = ship_spawn_location
	_player.position = ship_spawn_location

	# Spawn items
	for i in range(50):
		var item_spawn_position := _level.random_in_bounds()
		var item := getNewItem()
		item.position = item_spawn_position
		_level.add_child(item)

	# Start game
	_state = State.PLAYING


func set_state(new_state: State) -> void:
	_state = new_state
	match _state:
		State.LOADING:
			if is_instance_valid(_ship):
				_ship.process_mode = Node.PROCESS_MODE_DISABLED
			if is_instance_valid(_player):
				_player.process_mode = Node.PROCESS_MODE_DISABLED
		State.PLAYING:
			get_tree().paused = false
			_ship.process_mode = Node.PROCESS_MODE_PAUSABLE
			_player.process_mode = Node.PROCESS_MODE_PAUSABLE
		State.PAUSED:
			get_tree().paused = true


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
