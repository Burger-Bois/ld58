class_name Player
extends CharacterBody2D


@export
var default_speed = 180
@export
var sprint_multiplier = 1.6


@onready
var sprint_speed = default_speed * sprint_multiplier
@onready
var arms: Node2D = %Arms
@onready
var grab_area: Area2D = %GrabArea

var _speed: float = default_speed
var _grabbed_object: Item
var _object_collision_shapes: Array[CollisionPolygon2D] = []


func _physics_process(delta: float) -> void:
	var weight_multiplier: float
	if is_instance_valid(_grabbed_object):
		weight_multiplier = min(1 / (_grabbed_object.mass / 50), 1)
	else:
		weight_multiplier = 1

	# Move
	var direction := Input.get_vector(
		'player_move_left',
		'player_move_right',
		'player_move_up',
		'player_move_down',
	).normalized()
	velocity = direction * _speed * weight_multiplier
	move_and_slide()

	# Look at mouse
	if not is_instance_valid(_grabbed_object):
		var mouse_position := get_global_mouse_position()
		look_at(mouse_position)
	else:
		var rotate_speed := TAU * weight_multiplier
		var target_rotation := global_position.direction_to(get_global_mouse_position()).angle()
		rotation = lerp_angle(global_rotation, target_rotation, rotate_speed * delta)

	# Push objects
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			collider.apply_central_impulse(-collision.get_normal() * 20)


func _input(event: InputEvent) -> void:
	if event.is_action('player_sprint'):
		if event.is_action_released('player_sprint'):
			_speed = default_speed
		else:
			_speed = sprint_speed
		
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
	add_collision_exception_with(object)
	object.reparent(self, true)
	object.reset_physics_interpolation()
	object.freeze = true
	# Add object collision shapes to player
	for child in object.get_children():
		if child is CollisionPolygon2D:
			var dupe_collision_shape := child.duplicate()
			add_child(dupe_collision_shape)
			dupe_collision_shape.global_position = child.global_position
			dupe_collision_shape.global_rotation = child.global_rotation
			_object_collision_shapes.append(dupe_collision_shape)
	_grabbed_object = object


func _release() -> void:
	if is_instance_valid(_grabbed_object):
		_grabbed_object.freeze = false
		_grabbed_object.reparent(get_parent(), true)
		_grabbed_object.reset_physics_interpolation()
		call_deferred('remove_collision_exception_with', _grabbed_object)
		# Remove object collision shapes from player
		for object_collision_shape in _object_collision_shapes:
			object_collision_shape.queue_free()
		_object_collision_shapes = []
		_grabbed_object = null
