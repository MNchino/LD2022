extends Node2D

var room_template = preload("res://Level/SquareRandomRoom/SquareRandomRoom.tscn")
var used_map_positions = []
var max_rooms = 20
var map_position = Vector2(0,0)
var drunkard_position = Vector2(0,0)
var last_dir = 0
var tile_length = 32
var room_length = 11*tile_length # CHANGE THIS IF U USE LARGER SQUARE


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for k in range(max_rooms):
		var room = room_template.instance()
		add_child(room)
		if k != 0:
			room.open((last_dir + 2)%4)
		room.position = drunkard_position
		used_map_positions.push_back(map_position)
		if k == max_rooms - 1:
			return
		var routes_to_take = [0,1,2,3]
		routes_to_take.shuffle()
		var dir_index = randi()%4
		var dir = routes_to_take[dir_index]
		for i in range(4):
			if (used_map_positions.has(map_position + enum_to_vector(dir))):
				dir_index = (dir_index + 1)%4
				dir = routes_to_take[dir_index]
				if i == 3:
					# Cannot move anymore, stop
					return
			else:
				break
		room.open(dir)
		drunkard_position += room_length*enum_to_vector(dir)
		map_position += enum_to_vector(dir)
		last_dir = dir
	
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
