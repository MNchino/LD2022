extends KinematicBody2D

var active : bool = false

var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var input_speed : Vector2 = Vector2(100,100)
var max_velocity : Vector2 = Vector2(400,400)
var knocked_back : bool = false
var knock_back_dir : Vector2 = Vector2(0,0)
var knock_back_speed : float = 300

func _ready():
	GameState.connect("player_spawned", self, "start_player_follow")
	
func _physics_process(delta):
	
	#TODO Convert to NavMesh Later
	if active:
		if knocked_back:
			motion_velocity = knock_back_speed * knock_back_dir
		else:
			var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
				
			motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
			motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
			
			motion_velocity.x = clamp(motion_velocity.x, -max_velocity.x, max_velocity.x)
			motion_velocity.y = clamp(motion_velocity.y, -max_velocity.y, max_velocity.y)
			
		move_and_slide(motion_velocity)
	
func start_player_follow(player : Player):
	active = true

func knock_back(away_from_position : Vector2):
	if !knocked_back:
		knocked_back = true
		knock_back_dir = (global_position - away_from_position).normalized()
		$KnockbackTime.start()

func _on_KnockbackTime_timeout():
	knocked_back = false


func _on_Hurtbox_area_entered(area):
	knock_back(area.global_position)
	area.queue_free()
