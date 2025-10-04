class_name CollectionArea
extends Area2D

var _collected: int = 0:
	set=_set_collected


func _ready() -> void:
	body_entered.connect(collect_item)
	body_exited.connect(lose_item)


func collect_item(_item: Item) -> void:
	_collected += 1


func lose_item(_item: Item) -> void:
	_collected += -1


func _set_collected(new_collected: int) -> void:
	_collected = new_collected
	SignalBus.collected_updated.emit(_collected)
