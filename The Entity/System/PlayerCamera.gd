extends Camera2D

var following : bool = false
var target : Node2D = GameState.cur_player

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_spawned", self, "start_player_follow")
	# warning-ignore:return_value_discarded
	#GameState.connect("player_died", self, "stop_player_follow")
	# warning-ignore:return_value_discarded
	#GameState.connect("player_won", self, "stop_player_follow")
	
func _physics_process(_delta):
	if following:
		if is_instance_valid(target):
			global_position = lerp(global_position, target.global_position, 0.12)

func start_player_follow(_player):
	target = GameState.cur_player
	following = true
	
func stop_player_follow(_player):
	following = false
