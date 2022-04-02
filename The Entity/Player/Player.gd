extends KinematicBody2D
class_name Player

var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var motion_frict : float = .4
var input_speed : float = 100
var max_velocity : float = 400
var dash_speed : float = 3*max_velocity
var dir : Vector2 = Vector2(1,0) 
var is_dashing : bool = false
var is_dashing_cd : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.set_player(self);
	GInput.connect("attack_pressed", self, "attack")
	GInput.connect("shoot_pressed", self, "shoot")
	GInput.connect("dash_pressed", self, "dash")

func _physics_process(delta):
	if is_dashing:
		motion_velocity = motion_velocity.normalized()*dash_speed
		
	else:
		if GInput.dir.x != 0:
			dir.x = GInput.dir.x
			motion_velocity.x += ( dir.x * input_speed ) * motion_accel
		else:
			motion_velocity.x = lerp(motion_velocity.x, 0, motion_frict)
			
		if GInput.dir.y != 0:
			dir.y = GInput.dir.y
			motion_velocity.y += ( dir.y * input_speed ) * motion_accel
		else:
			motion_velocity.y = lerp(motion_velocity.y, 0, motion_frict)
	
		motion_velocity.x = clamp(motion_velocity.x, -max_velocity, max_velocity)
		motion_velocity.y = clamp(motion_velocity.y, -max_velocity, max_velocity)
		
	move_and_slide(motion_velocity)
	
func shoot():
	pass
	
func attack():
	pass

func dash():
	if !is_dashing && !is_dashing_cd:
		is_dashing = true
		$DashTime.start()
		
func _on_DashTime_timeout():
	is_dashing = false
	is_dashing_cd = true
	$DashCoolDown.start()

func _on_DashCoolDown_timeout():
	is_dashing_cd = false


