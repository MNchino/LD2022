extends KinematicBody2D
class_name Player

var shoot_template = preload('res://Player/Lighterang/LighterangThrower.tscn')
var attack_template = preload("res://Player/Attack/Attack.tscn")

var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var motion_frict : float = .4
var input_speed : float = 10
var max_velocity : float = 100
var dash_speed : float = 4*max_velocity
var knock_back_speed = 600
var dir : Vector2 = Vector2(1,0) 
var knock_back_dir : Vector2 = Vector2(0,0)
var is_dashing : bool = false
var is_dashing_cd : bool = false
var is_shooting_cd : bool = false
var is_attacking_cd : bool = false
var is_knocking_back : bool = false
var invincible : bool = false
var is_slowed : bool = false
var slowed_max_velocity = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.set_player(self);
	GInput.connect("attack_pressed", self, "attack")
	GInput.connect("shoot_pressed", self, "shoot")
	GInput.connect("dash_pressed", self, "dash")
	GameState.connect("player_won", self, 'set_win_state')
	$AnimatedSprite.animation = "WalkDown"

func _physics_process(delta):
	if is_knocking_back:
		motion_velocity = knock_back_dir*knock_back_speed
	elif is_dashing:
		motion_velocity = motion_velocity.normalized()*dash_speed
	else:
		if GInput.dir.x != 0:
			dir.x = GInput.dir.x
			update_sprite_xflip(dir.x)
			motion_velocity.x += ( dir.x * input_speed ) * motion_accel
		else:
			motion_velocity.x = lerp(motion_velocity.x, 0, motion_frict)
			
		if GInput.dir.y != 0:
			dir.y = GInput.dir.y
			motion_velocity.y += ( dir.y * input_speed ) * motion_accel
		else:
			motion_velocity.y = lerp(motion_velocity.y, 0, motion_frict)
	
		if is_slowed:
			motion_velocity.x = clamp(motion_velocity.x, -slowed_max_velocity, slowed_max_velocity)
			motion_velocity.y = clamp(motion_velocity.y, -slowed_max_velocity, slowed_max_velocity)
		else:
			motion_velocity.x = clamp(motion_velocity.x, -max_velocity, max_velocity)
			motion_velocity.y = clamp(motion_velocity.y, -max_velocity, max_velocity)
	
	move_and_slide(motion_velocity)
	$AnimatedSprite.playing = motion_velocity.length() > 0
	
func _process(delta):
	if is_dashing:
		$AnimatedSprite.animation = "DashUp" if dir.y < 0 else "DashDown"
	elif GInput.dir.y != 0 ||  GInput.dir.x != 0:
		$AnimatedSprite.animation = "WalkUp" if dir.y < 0 else "WalkDown"
	else:
		$AnimatedSprite.animation = "default"
		
func update_sprite_xflip(dir : int):
	$AnimatedSprite.flip_h = dir < 0
	
func shoot():
	if is_shooting_cd:
		return
	var target_position = get_global_mouse_position()
	var i = shoot_template.instance()
	add_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	i.rotation = target_position.angle_to_point(global_position)
	is_shooting_cd = true
	$ShootCoolDown.start()
	
func attack():
	if is_attacking_cd:
		return
	var i = attack_template.instance()
	add_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	$AttackCoolDown.start()
	is_attacking_cd = true
	
	
func knock_back():
	if is_knocking_back:
		return
	
	knock_back_dir = -motion_velocity.normalized()
	is_knocking_back = true
	$KnockBackTime.start()

func dash():
	if !is_dashing && !is_dashing_cd && GameState.can_use_dash():
		is_dashing = true
		GameState.use_dash()
		$DashTime.start()
		set_collision_mask_bit(8, false)
		set_collision_mask_bit(9, false)
		
func slow_down():
	is_slowed = true
	
func stop_slow_down():
	is_slowed = false
	
func insta_kill():
	if invincible:
		return
	GameState.unset_player(self)
	queue_free()
	
func set_win_state(player : Player):
	invincible = true
		
func _on_DashTime_timeout():
	is_dashing = false
	is_dashing_cd = true
	set_collision_mask_bit(8, true)
	$DashCoolDown.start()

func _on_DashCoolDown_timeout():
	is_dashing_cd = false

func _on_ShootCoolDown_timeout():
	is_shooting_cd = false

func _on_AttackCoolDown_timeout():
	is_attacking_cd = false

func _on_KnockBackTime_timeout():
	is_knocking_back = false

func _on_Hurtbox_area_entered(area):
	insta_kill()

func _on_Player_tree_exiting():
	pass
