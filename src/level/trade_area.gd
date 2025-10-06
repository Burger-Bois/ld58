class_name TradeArea
extends Area2D

signal completed()
signal amount_changed(value: int)

@export
var reward_scene: PackedScene

@export
var item_group: String
@export
var cost: int

var _current_items: Array[RandomItem] = []
var _current_amount: int = 0: set=_set_current_amount


func _ready() -> void:
	body_entered.connect(collect_item)
	body_exited.connect(lose_item)


func collect_item(body: Node2D) -> void:
	if body.is_in_group(item_group):
		var item := body as RandomItem
		_current_items.append(item)
		_current_amount += item.points


func lose_item(body: Node2D) -> void:
	if body.is_in_group(item_group):
		var item := body as RandomItem
		_current_items.erase(item)
		_current_amount += -item.points


func _set_current_amount(new_amount: int) -> void:
	var old_amount := _current_amount
	_current_amount = new_amount
	if _current_amount >= cost:
		completed.emit()
		var reward := reward_scene.instantiate() as Node2D
		reward.global_position = global_position
		add_sibling(reward)
		queue_free()
		for item in _current_items:
			item.queue_free()
	amount_changed.emit(new_amount - old_amount)
