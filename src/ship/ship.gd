class_name Ship
extends Node2D

signal leave_pressed()

@onready
var leave_button: Button2D = %LeaveButton
@onready
var collection_area: CollectionArea = $CollectionArea

@onready
var score: Label = %Score

var collected_items: Array[Item] = []


func _ready() -> void:
	leave_button.pressed.connect(leave_pressed.emit)
	SignalBus.collected_updated.connect(_update_score)
	collection_area.body_entered.connect(collect_item)
	collection_area.body_exited.connect(lose_item)


func _update_score(newScore: int) -> void:
	score.text = str(newScore)


func collect_item(body: PhysicsBody2D) -> void:
	if body is Item:
		collected_items.append(body)


func lose_item(body: PhysicsBody2D) -> void:
	if body is Item:
		collected_items.erase(body)
