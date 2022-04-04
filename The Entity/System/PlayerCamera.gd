extends Camera2D

var following : bool = false

func _ready():
	GameState.connect("player_spawned", self, "start_player_follow")
	GameState.connect("player_died", self, "stop_player_follow")
	GameState.connect("player_won", self, "stop_player_follow")
	
func _physics_process(delta):
	if following:
		global_position = lerp(global_position, GameState.cur_player.global_position, 0.12)

func start_player_follow(player):
	following = true
	
func stop_player_follow(player):
	following = false