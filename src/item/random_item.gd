class_name Item
extends RigidBody2D


func _init() -> void:
	generate_shape()
	push_randomly()
	
func generate_polygon_points(vertex_count : int, radius : float) -> PackedVector2Array:
	var points : PackedVector2Array = []
	var angle_increment : float = TAU / vertex_count
	for i in vertex_count:
		var point : Vector2 = Vector2(radius * sin(angle_increment * i), radius * cos(angle_increment * i))
		point += point.direction_to(Vector2.ZERO) * radius * 0.25 * randf()
		points.append(point)
	return points
	
func generate_shape() -> void:
	var random_points = generate_polygon_points(randi_range(3,10), randi_range(20,60))
	var polygon = Polygon2D.new()
	var collision = CollisionPolygon2D.new()
	polygon.set_polygon(random_points)
	collision.set_polygon(random_points)
	add_child(polygon)
	add_child(collision)
	
func push_randomly() -> void:
	var direction = Vector2(randf_range(0, TAU), randf_range(0, TAU))
	var rot = randf_range(-PI/4, PI/4)
	var speed = randf_range(2,10)
	apply_central_impulse(direction.rotated(rot) * speed)
