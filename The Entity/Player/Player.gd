extends KinematicBody2D
class_name Player

var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var motion_frict : float = .4
var input_speed : Vector2 = Vector2(100,100)
var max_velocity : Vector2 = Vector2(400,400)
var dir : Vector2 = Vector2(1,0) 

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.set_player(self);

func _physics_process(delta):
	if GInput.dir.x != 0:
		dir.x = GInput.dir.x
		motion_velocity.x += ( dir.x * input_speed.x ) * motion_accel
	else:
		motion_velocity.x = lerp(motion_velocity.x, 0, motion_frict)
		
	if GInput.dir.y != 0:
		dir.y = GInput.dir.y
		motion_velocity.y += ( dir.y * input_speed.y ) * motion_accel
	else:
		motion_velocity.y = lerp(motion_velocity.y, 0, motion_frict)
	
	motion_velocity.x = clamp(motion_velocity.x, -max_velocity.x, max_velocity.x)
	motion_velocity.y = clamp(motion_velocity.y, -max_velocity.y, max_velocity.y)
	
	move_and_slide(motion_velocity)

