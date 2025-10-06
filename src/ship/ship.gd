class_name Ship
extends Node2D

signal leave_pressed()
signal item_collected(item: Item)
signal item_lost(item: Item)

@onready
var leave_button: Button2D = %LeaveButton
@onready
var collection_area: CollectionArea = $CollectionArea

var collected_items: Array[Item] = []

func _ready() -> void:
	leave_button.pressed.connect(leave_pressed.emit)
	collection_area.body_entered.connect(collect_item)
	collection_area.body_exited.connect(lose_item)



func collect_item(body: PhysicsBody2D) -> void:
	if body is Item:
		collected_items.append(body)
		item_collected.emit(body)


func lose_item(body: PhysicsBody2D) -> void:
	if body is Item:
		collected_items.erase(body)
		item_lost.emit(body)
