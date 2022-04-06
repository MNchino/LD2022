extends Node2D

var room_template = preload("res://Level/SquareRandomRoom/SquareRandomRoom.tscn")
var max_rooms = 13
var map_position = Vector2(0,0)
var tile_length = 32
var room_length = 16*tile_length # CHANGE THIS IF U USE LARGER SQUARE

var used_map_positions = []
var tiles_to_visit = []
var dirs_to_use = []
var last_dir = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var has_correct_path = false
	
	#Generate paths until it satisfies conditions
	while !has_correct_path:
		tiles_to_visit = []
		dirs_to_use = []
		map_position = Vector2(0,0)
		used_map_positions = [Vector2(2,2),Vector2(-2,2),Vector2(2,-2),Vector2(-2,-2)]
		last_dir = 0
		var got_stuck = false
		for k in range(max_rooms):
			tiles_to_visit.push_back(map_position)
			used_map_positions.push_back(map_position)
			if k == max_rooms - 1:
				break
				
			#Choose Direction
			var routes_to_take = [0,1,2,3]
			routes_to_take.shuffle()
			var dir_index = randi()%4
			var dir = routes_to_take[dir_index]
			for i in range(4):
				if (used_map_positions.has(map_position + enum_to_vector(dir)) || is_dead_end(map_position + enum_to_vector(dir))):
					dir_index = (dir_index + 1)%4
					dir = routes_to_take[dir_index]
					if i == 3:
						got_stuck = true
				else:
					break
			dirs_to_use.push_back(dir)
			if got_stuck:
				break
			map_position += enum_to_vector(dir)
			last_dir = dir
		if dirs_to_use.back() == 3 && !got_stuck:
			has_correct_path = true
	
	map_position = Vector2(0,0)
	last_dir = 0
	for k in range(max_rooms):
		var room = room_template.instance()
		add_child(room)
		if k != 0:
			room.open((last_dir + 2)%4)
		else:
			room.set_as_spawn_room()
		room.position = map_position*room_length
		if k == max_rooms - 1:
			room.set_as_goal_room()
			GameState.num_rooms = k + 1	
			return
		room.set_center_if_unset()
		var dir = dirs_to_use[k]
		room.open(dir)
		map_position += enum_to_vector(dir)
		last_dir = dir
		
func is_dead_end(pos : Vector2):
	if used_map_positions.has(pos + Vector2(1,0)):
		if used_map_positions.has(pos + Vector2(-1,0)):
			if used_map_positions.has(pos + Vector2(0,1)):
				if used_map_positions.has(pos + Vector2(0,-1)):
					return true
	return false
	
func enum_to_vector(dir):
	match dir:
		0:
			return Vector2(0, -1)
		1:
			return Vector2(1, 0)
		2:
			return Vector2(0, 1)
		3:
			return Vector2(-1, 0)
