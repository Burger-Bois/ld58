class_name Room
extends RigidBody2D

var size

func make_room(_pos, _size):
	position = _pos
	size = _size
	lock_rotation = true
	var s = RectangleShape2D.new()
	s.custom_solver_bias = 0.75
	s.extents = size
	s.resource_local_to_scene = true
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = s
	add_child(collision_shape)
