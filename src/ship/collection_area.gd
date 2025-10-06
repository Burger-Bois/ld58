class_name CollectionArea
extends Area2D

var _collected: int = 0:
	set=_set_collected

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exit)
	
func on_body_entered(_body: Node2D) -> void:
	if (_body is Item):
		collect_item(_body)
	elif (_body is Player):
		pause_oxygen_timer()

func on_body_exit(_body: Node2D) -> void:
	if (_body is Item):
		lose_item(_body)
	elif (_body is Player):
		resume_oxygen_timer()
	
func collect_item(_item: Item) -> void:
	if _item is BlueItem:
		SignalBus.add_to_blue_score.emit(_item.points)
	elif _item is YellowItem:
		SignalBus.add_to_yellow_score.emit(_item.points)
	elif _item is RedItem:
		SignalBus.add_to_red_score.emit(_item.points)
		

func lose_item(_item: Item) -> void:
	if _item is BlueItem:
		SignalBus.add_to_blue_score.emit(_item.points * -1)
	elif _item is YellowItem:
		SignalBus.add_to_yellow_score.emit(_item.points * -1)
	elif _item is RedItem:
		SignalBus.add_to_red_score.emit(_item.points * -1)

func _set_collected(new_collected: int) -> void:
	_collected = new_collected
	SignalBus.collected_updated.emit(_collected)

func pause_oxygen_timer() -> void:
	SignalBus.player_oxygen_paused.emit(true)

func resume_oxygen_timer() -> void:
	SignalBus.player_oxygen_paused.emit(false)
	

	
