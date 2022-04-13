extends "res://Level/SquareRandomRoom/DrunkardWalkGenerator.gd"

var chaser_template = preload("res://WallChaser/WallChaser.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_chaser()

func spawn_chaser():
	var i = chaser_template.instance()
	add_child(i)
	
	var initial_move = (tiles_to_visit[1] - tiles_to_visit[0])*room_length
	var moves = [initial_move]
	for k in range(dirs_to_use.size() - 1):
		moves.push_back(room_length*enum_to_vector(dirs_to_use[k]))
	
	i.global_position = global_position + (tiles_to_visit[0] - tiles_to_visit[1] + tiles_to_visit[0])*room_length
	i.cur_pos = i.global_position
	i.moves = moves
	print(i.moves)
	print(dirs_to_use)
