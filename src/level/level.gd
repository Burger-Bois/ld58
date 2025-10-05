extends Node2D

@onready var Map: TileMapLayer = $TileMapLayer

var _room: Room


var tile_size = 32
var num_rooms = 20
var min_size = 10
var max_size = 30
var hspread = 400
var cull = 0.6

var path

func _ready():
	randomize()
	make_rooms()
	await get_tree().create_timer(1).timeout
	make_map()
	
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

		
# func _draw():
# 	for room in $Rooms.get_children():
# 		draw_rect(Rect2(room.position - room.size, room.size * 2),
# 				 Color(228.0, 228.0, 228.0, 1.0), false)
# 	if path:
# 		for p in path.get_point_ids():
# 			for c in path.get_point_connections(p):
# 				var pp = path.get_point_position(p)
# 				var cp = path.get_point_position(c)
# 				draw_line(pp, cp,Color(1, 1, 0), 15, true)

#func _input(event):
	#if event.is_action_pressed('ui_select'):
		#for n in $Rooms.get_children():
			#n.queue_free()
		#path = null
		#make_rooms()
	#if event.is_action_pressed('ui_focus_next'):
		#make_map()
		
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
	return path
	
func make_map():
	# Create a TileMap from the generated rooms and path
	Map.clear()
	#find_start_room()
	#find_end_room()d
	
	# Fill TileMap with walls, then carve empty rooms
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size,
					room.get_child(0).get_shape().extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.local_to_map(full_rect.position)
	var bottomright = Map.local_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 1)		
			
	
	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(Vector2i(ul.x + x, ul.y + y), -1, Vector2i(0, 0), 1)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector2(room.position.x, 
											room.position.y))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.local_to_map(Vector2(path.get_point_position(p).x,
													path.get_point_position(p).y))
				var end = Map.local_to_map(Vector2(path.get_point_position(conn).x,
													path.get_point_position(conn).y))									
				carve_path(start, end)
		corridors.append(p)

func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(Vector2i(x, x_y.y), -1, Vector2i(0, 0), 1)
		Map.set_cell(Vector2i(x, x_y.y + y_diff), -1, Vector2i(0, 0), 1)
	for y in range(pos1.y, pos2.y, x_diff):
		Map.set_cell(Vector2i(y_x.x, y), -1, Vector2i(0, 0), 1)
		Map.set_cell(Vector2i(y_x.x + x_diff, y), -1, Vector2i(0, 0), 1)
	
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
		
