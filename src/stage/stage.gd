class_name Stage
extends Node2D

signal finished()

const LEVEL_SCENE := preload('res://src/level/random_level.tscn') as PackedScene
const HUB_SCENE := preload('res://src/level/hub_level.tscn') as PackedScene
const SHIP_SCENE := preload('res://src/ship/ship.tscn') as PackedScene
const PLAYER_SCENE := preload('res://src/player/player.tscn') as PackedScene


@export
var end_time: float = 120.0

@onready
var end_menu: EndMenu = %EndMenu
@onready
var pause_menu: PauseMenu = %PauseMenu
@onready
var pauser: Pauser = %Pauser
@onready
var minimap: Minimap = %Minimap
@onready
var level_holder: Node2D = %Level

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
	# Clear current level
	var next_level := HUB_SCENE
	if is_instance_valid(_level):
		for item in _ship.collected_items.duplicate():
			item.freeze = true
			item.reparent(_ship)

		if _level is HubLevel:
			next_level = LEVEL_SCENE

		_level.queue_free()
		_level = null

	_state = State.LOADING

	_level = next_level.instantiate()
	_level.generated.connect(start_level)
	level_holder.add_child(_level)


func start_level() -> void:
	# Place ship and player
	var ship_spawn_location := _level.docking_position()
	_ship.position = ship_spawn_location
	_player.position = ship_spawn_location

	# Add ship items back to level
	var items := [] as Array[Item]
	for child in _ship.get_children():
		if child is Item:
			items.append(child)
	for item in items:
		if item is Item:
			item.reparent(_level)
			item.freeze = false

	_player.update_oxygen(-10000000)
	if _level is RandomLevel:
		_player.infinite_oxygen = false
	elif _level is HubLevel:
		_player.infinite_oxygen = true

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


func _game_over() -> void:
	pauser.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	end_menu.show()
