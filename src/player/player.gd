class_name Player
extends CharacterBody2D

@export
var speed := 200.0


func _process(_delta: float) -> void:
	var direction := Input.get_vector(
		'player_move_left',
		'player_move_right',
		'player_move_up',
		'player_move_down',
	).normalized()
	velocity = direction * speed
	move_and_slide()
