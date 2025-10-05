class_name Item
extends RigidBody2D

@export
var radius_min: float = 10.0
@export
var radius_max: float = 100.0

@export
var vertex_count_min: int = 3
@export
var vertex_count_max: int = 10

@export
var damping_min: float = 0.2
@export
var damping_max: float = 1.0


func _init() -> void:
	var radius := randf_range(radius_min, radius_max)
	generate_shape(radius)
	push_randomly()
	mass = radius
	linear_damp = calculate_linear_damp(radius)
	
func generate_polygon_points(vertex_count : int, radius : float) -> PackedVector2Array:
	var points : PackedVector2Array = []
	var angle_increment : float = TAU / vertex_count
	for i in vertex_count:
		var point : Vector2 = Vector2(radius * sin(angle_increment * i), radius * cos(angle_increment * i))
		point += point.direction_to(Vector2.ZERO) * radius * 0.25 * randf()
		points.append(point)
	return points
	
func generate_shape(radius: float) -> void:
	var vertex_count = randi_range(vertex_count_min, vertex_count_max)
	var random_points = generate_polygon_points(vertex_count, radius)
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

func calculate_linear_damp(radius: float) -> float:
	var size := (radius - radius_min) / radius_max
	return lerp(damping_min, damping_max, size)
