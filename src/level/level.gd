class_name Level
extends Node2D

signal generated()

const DEBUG := false

const SOURCE_ID = 0

const WALL_ID := 1
const FLOOR_ID := 2

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
]

@onready var Map: TileMapLayer = $TileMapLayer

var _room: Room

@export
var tile_size = 32
@export
var num_rooms = 10
@export
var min_size = 10
@export
var max_size = 30
@export
var hspread = 400
@export
var cull = 0.2
@export
var corridor_width = 3

var path: AStar2D

func _ready():
	randomize()
	make_rooms()
	await get_tree().create_timer(1).timeout
	make_map()
	for child in $Rooms.get_children():
		child.queue_free()
	generated.emit()
	
func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(randf_range(-hspread, hspread), 0)
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		_room = Room.new()
		_room.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(_room)
	# wait for movement to stop
	await get_tree().create_timer(1).timeout
	# cull rooms
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.free()
		else:
			room.freeze = true
			room.lock_rotation = true
			room_positions.append(Vector2(room.position.x, room.position.y))
	find_mst(room_positions)
	queue_redraw()


func _draw():
	if DEBUG:
		for room in $Rooms.get_children():
			draw_rect(Rect2(room.position - room.size, room.size * 2),
					 Color(228.0, 228.0, 228.0, 1.0), false)
		if path:
			for p in path.get_point_ids():
				for c in path.get_point_connections(p):
					var pp = path.get_point_position(p)
					var cp = path.get_point_position(c)
					draw_line(pp, cp,Color(1, 1, 0), 15, true)


func find_mst(nodes):
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object
	
	# Initialize the AStar and add the first point
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# Repeat until no more nodes remain
	while nodes:
		var min_dist = INF  # Minimum distance so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through points in path
		for p1 in path.get_point_ids():
			var p_temp = path.get_point_position(p1)
			# Loop through the remaining nodes
			for p2 in nodes:
				# If the node is closer, make it the closest
				if p_temp.distance_to(p2) < min_dist:
					min_dist = p_temp.distance_to(p2)
					min_p = p2
					p = p_temp
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_p)


func make_map():
	# Create a TileMap from the generated rooms and path
	Map.clear()
	#find_start_room()
	#find_end_room()
	
	# Fill TileMap with walls, then carve empty rooms
	# var full_rect = Rect2()
	# for room in $Rooms.get_children():
	# 	var r = Rect2(
	# 		room.position-room.size,
	# 		room.get_child(0).get_shape().extents*2
	# 	)
	# 	full_rect = full_rect.merge(r)
	# var topleft = Map.local_to_map(full_rect.position)
	# var bottomright = Map.local_to_map(full_rect.end)
	# for x in range(topleft.x, bottomright.x):
	# 	for y in range(topleft.y, bottomright.y):
	# 		Map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 1)
	
	# Create rooms
	for room in $Rooms.get_children():
		create_room(room)
	
	# Create corridors
	var corridors = []  # One corridor per connection
	for start_point_id in path.get_point_ids():
		for end_point_id in path.get_point_connections(start_point_id):
			if end_point_id in corridors:
				continue
			var start_pos := path.get_point_position(start_point_id)
			var end_pos := path.get_point_position(end_point_id)
			create_corridor(start_pos, end_pos)
		corridors.append(start_point_id)


func create_room(room: Room) -> void:
	var size := Vector2i((room.size / tile_size).floor())
	var upper_left := Vector2i((room.position / tile_size).floor()) - size
	# North wall
	for x in range(size.x * 2):
		Map.set_cell(
			upper_left + Vector2i(x, 0),
			SOURCE_ID,
			Vector2i(0, 0),
			WALL_ID
		)
	# South wall
	for x in range(size.x * 2):
		Map.set_cell(
			upper_left + Vector2i(x, size.y * 2 - 1),
			SOURCE_ID,
			Vector2i(0, 0),
			WALL_ID
		)
	# West wall
	for y in range(size.y * 2):
		Map.set_cell(
			upper_left + Vector2i(0, y),
			SOURCE_ID,
			Vector2i(0, 0),
			WALL_ID
		)
	# East wall
	for y in range(size.y * 2):
		Map.set_cell(
			upper_left + Vector2i(size.x * 2 - 1, y),
			SOURCE_ID,
			Vector2i(0, 0),
			WALL_ID
		)
	for x in range(upper_left.x + 1, (upper_left.x + size.x * 2) - 1):
		for y in range(upper_left.y + 1, (upper_left.y + size.y * 2) - 1):
			Map.set_cell(
				Vector2i(x, y),
				SOURCE_ID,
				Vector2i(0, 0),
				FLOOR_ID,
			)


func create_corridor(pos_1: Vector2, pos_2: Vector2):
	var start: Vector2i
	var end: Vector2i
	if (randi() % 2) > 0:
		start = Map.local_to_map(pos_1)
		end = Map.local_to_map(pos_2)
	else:
		start = Map.local_to_map(pos_2)
		end = Map.local_to_map(pos_1)
	# Carve a path between two points
	var x_diff = sign(end.x - start.x)
	var y_diff = sign(end.y - start.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = start
	var y_x = end
	for x in range(start.x, end.x + corridor_width * x_diff, x_diff):
		for y_offset in range(-(corridor_width - 1), corridor_width):
			var target_cell := Vector2i(x, x_y.y + y_offset)
			place_floor(target_cell)
	for y in range(start.y, end.y + corridor_width * y_diff, y_diff):
		for x_offset in range(-(corridor_width - 1), corridor_width):
			var target_cell := Vector2i(y_x.x + x_offset, y)
			place_floor(target_cell)


func place_floor(coords: Vector2i) -> void:
	Map.set_cell(coords, SOURCE_ID, Vector2i(0, 0), FLOOR_ID)
	for direction in DIRECTIONS:
		var adjacent_cell := coords + direction
		var adjacent_cell_id := Map.get_cell_source_id(adjacent_cell)
		if adjacent_cell_id == -1:
			Map.set_cell(adjacent_cell, SOURCE_ID, Vector2i(0, 0), WALL_ID)


func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			min_x = room.position.x


func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			max_x = room.position.x


func random_in_bounds() -> Vector2i:
	var floor_cells := Map.get_used_cells_by_id(SOURCE_ID, Vector2i(-1, -1), FLOOR_ID)
	return Map.map_to_local(floor_cells.pick_random())
