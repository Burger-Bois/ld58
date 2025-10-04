class_name Player
extends CharacterBody2D

@export
var speed := 200.0

@onready
var arms: Node2D = %Arms
@onready
var grab_area: Area2D = %GrabArea
@onready
var grab_joint: Joint2D = %GrabJoint


func _process(_delta: float) -> void:
	# Move
	var direction := Input.get_vector(
		'player_move_left',
		'player_move_right',
		'player_move_up',
		'player_move_down',
	).normalized()
	velocity = direction * speed
	move_and_slide()

	# Look at mouse
	var mouse_position := get_viewport().get_mouse_position()
	look_at(mouse_position)


func _input(event: InputEvent) -> void:
	if event.is_action('player_grab'):
		if event.is_pressed():
			arms.show()
			var objects := grab_area.get_overlapping_bodies()
			if not objects.is_empty():
				var object := objects[0]
				_grab(object)
		else:
			arms.hide()
			_release()


func _grab(object: RigidBody2D) -> void:
	grab_joint.node_b = object.get_path()


func _release() -> void:
	grab_joint.node_b = get_path()
