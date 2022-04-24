extends Node2D

var moves = [] setget set_moves
var moves_left = moves
var time_to_move : float = 10
var time_left_to_move : float = time_to_move
var cur_pos = Vector2(0,0)
var base_pos = Vector2(0,0)
var moving_dir = Vector2(0,0)
var active = false

func _ready():
	GameState.connect("player_spawned", self, "start_chasing")
	GameState.connect("player_died", self, "stop_chasing")
	GameState.connect("entity_died", self, "stop_chasing", [null])
	GameState.cur_chaser = self
#	$AnimationPlayer.play("Pulse")
	
func restart():
	active = true
	cur_pos = base_pos
	moving_dir = Vector2(0,0)
	position = cur_pos
	print("restarting")
	reset()
	
func start_chasing(player):
	active = true

func stop_chasing(player):
	active = false

func set_moves(new_moves):
	moves = new_moves
	moves_left = moves.duplicate()

func _physics_process(delta):
	if active && moves_left.size():
		var percent_to_move = 1 - time_left_to_move/time_to_move
		moving_dir = moves_left.front().normalized()
		position = lerp(cur_pos, cur_pos + moves_left.front(), percent_to_move)
		
		if percent_to_move >= 1:
			cur_pos += moves_left.pop_front()
			time_left_to_move = time_to_move
		
		time_left_to_move -= delta

func reset():
	moves_left = moves.duplicate()
	time_left_to_move = time_to_move
