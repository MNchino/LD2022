extends KinematicBody2D

var active : bool = false

var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var input_speed : Vector2 = Vector2(100,100)
var max_velocity : Vector2 = Vector2(400,400)

func _ready():
	GameState.connect("player_spawned", self, "start_player_follow")
	
func _physics_process(delta):
	
	#TODO Convert to NavMesh Later
	if active:
		var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
			
		motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
		motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
		
		motion_velocity.x = clamp(motion_velocity.x, -max_velocity.x, max_velocity.x)
		motion_velocity.y = clamp(motion_velocity.y, -max_velocity.y, max_velocity.y)
		print("moving", motion_velocity)
		
		move_and_slide(motion_velocity)
	
func start_player_follow(player : Player):
	active = true
