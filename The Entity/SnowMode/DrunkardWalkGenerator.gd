extends "res://Level/SquareRandomRoom/DrunkardWalkGenerator.gd"

var chaser_template = preload("res://WallChaser/WallChaser.tscn")
var room_template_2 = preload("res://SnowMode/AlternateSquareRandomRoom.tscn")
var snow_max_rooms = 15

func _init():
	room_template = room_template_2
	max_rooms = snow_max_rooms
	
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_chaser()
#	GameState.connect("player_teleported_to_start", self, 'shuffle_rooms')

#Regenerates the map every time we teleport back to start
#We're not doing this in the end, too much time, not putting in effort to optimize
func shuffle_rooms():
	clean_up_rooms()
	spawn_rooms()
	
func clean_up_rooms():
	if room_container:
		room_container.queue_free()
		room_container = null

func spawn_chaser():
	var i = chaser_template.instance()
	add_child(i)
	
	var initial_move = (tiles_to_visit[1] - tiles_to_visit[0])*room_length
	var moves = [initial_move]
	for k in range(dirs_to_use.size() - 1):
		moves.push_back(room_length*enum_to_vector(dirs_to_use[k]))
	
	i.global_position = global_position + (tiles_to_visit[0] - tiles_to_visit[1] + tiles_to_visit[0])*room_length
	i.base_pos = i.global_position
	i.cur_pos = i.global_position
	i.moves = moves
