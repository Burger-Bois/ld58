class_name HubLevel
extends Level

signal strength_upgrade_got()
signal speed_upgrade_got()
signal oxygen_upgrade_got()

@export
var key_scene: PackedScene

@onready
var docking_location: Node2D = %DockingLocation
@onready
var red_trade_area: TradeArea = %RedTradeArea
@onready
var yellow_trade_area: TradeArea = %YellowTradeArea
@onready
var blue_trade_area: TradeArea = %BlueTradeArea

var _upgrades_left := 3: set=set_upgrades_left


func _ready() -> void:
	generated.emit()
	red_trade_area.completed.connect(func(): get_strength(false))
	yellow_trade_area.completed.connect(func(): get_speed(false))
	blue_trade_area.completed.connect(func(): get_oxygen(false))


func docking_position() -> Vector2:
	return docking_location.global_position


func get_strength(respawn_upgrade: bool) -> void:
	if respawn_upgrade:
		var upgrade := red_trade_area.reward_scene.instantiate() as Item
		upgrade.global_position = red_trade_area.global_position
		add_child(upgrade)
	red_trade_area.queue_free()
	_upgrades_left += -1
	strength_upgrade_got.emit()


func get_speed(respawn_upgrade: bool) -> void:
	if respawn_upgrade:
		var upgrade := yellow_trade_area.reward_scene.instantiate() as Item
		upgrade.global_position = yellow_trade_area.global_position
		add_child(upgrade)
	yellow_trade_area.queue_free()
	_upgrades_left += -1
	speed_upgrade_got.emit()


func get_oxygen(respawn_upgrade: bool) -> void:
	if respawn_upgrade:
		var upgrade := blue_trade_area.reward_scene.instantiate() as Item
		upgrade.global_position = blue_trade_area.global_position
		add_child(upgrade)
	blue_trade_area.queue_free()
	_upgrades_left += -1
	oxygen_upgrade_got.emit()


func set_upgrades_left(new_value: int) -> void:
	print(new_value)
	_upgrades_left = new_value
	if _upgrades_left <= 0:
		%FloorLights.modulate = Color.WHITE
		spawn_key()


func spawn_key() -> void:
	var key := key_scene.instantiate() as Node2D
	key.global_position = %KeySpawnPoint.global_position
	add_child(key)
