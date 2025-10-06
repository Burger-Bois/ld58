class_name Player
extends CharacterBody2D


@export
var default_speed := 180.0
@export
var multiplier := 1.6


@onready
var arms: Node2D = %Arms
@onready
var grab_area: Area2D = %GrabArea
@onready
var use_box: Area2D = %UseBox

var _speed: float = default_speed
var _oxygen: Oxygen = Oxygen.new()
var _grabbed_object: Item
var _object_collision_shapes: Array[CollisionPolygon2D] = []

var is_sprinting: bool = false
var sprint_speed: float = default_speed * multiplier
var infinite_oxygen: bool = false


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
	
	update_oxygen(1*delta)
	

func update_oxygen(minus: float) -> void:
	if infinite_oxygen:
		return
	if is_sprinting:
		_oxygen.reduce_oxygen(minus * multiplier)
	else:
		_oxygen.reduce_oxygen(minus)

func _input(event: InputEvent) -> void:
	if event.is_action('player_sprint'):
		if event.is_action_released('player_sprint'):
			_speed = default_speed
			is_sprinting = false
		else:
			_speed = sprint_speed
			is_sprinting = true
	
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
	
	if event.is_action('player_use') and event.is_pressed():
		var usables := use_box.get_overlapping_areas()
		if not usables.is_empty():
			usables[0].press()


func _grab(object: RigidBody2D) -> void:
	add_collision_exception_with(object)
	object.freeze = true
	# Add object collision shapes to player
	for child in object.get_children():
		if child is CollisionPolygon2D:
			var dupe_collision_shape := child.duplicate()
			add_child(dupe_collision_shape)
			dupe_collision_shape.global_position = child.global_position
			dupe_collision_shape.global_rotation = child.global_rotation

			var remote_transform := RemoteTransform2D.new()
			remote_transform.remote_path = object.get_path()
			dupe_collision_shape.add_child(remote_transform)

			_object_collision_shapes.append(dupe_collision_shape)
	_grabbed_object = object


func _release() -> void:
	if is_instance_valid(_grabbed_object):
		_grabbed_object.freeze = false
		call_deferred('remove_collision_exception_with', _grabbed_object)
		# Remove object collision shapes from player
		for object_collision_shape in _object_collision_shapes:
			for child in object_collision_shape.get_children():
				if child is RemoteTransform2D:
					child.remote_path = child.get_path()
			object_collision_shape.queue_free()
		_object_collision_shapes = []
		_grabbed_object = null
