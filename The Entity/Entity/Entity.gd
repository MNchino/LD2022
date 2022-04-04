extends KinematicBody2D
class_name Entity

var bullet_template = preload("res://Entity/Bullet/Bullet.tscn")

var active : bool = false
var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var input_speed : Vector2 = Vector2(100,100)
var max_velocity : Vector2 = Vector2(100,100)
var drift_velocity : Vector2 = Vector2()
var drift_divisor : float = 2
var knocked_back : bool = false
var knock_back_dir : Vector2 = Vector2(0,0)
var knock_back_speed : float = 200
var is_shooting : bool = false
var is_shooting_cd : bool = false
var bullet_speed : float = 200

func _ready():
	GameState.set_entity(self)
	GameState.connect("player_spawned", self, "start_player_follow")
	GameState.connect("player_died", self, "stop_player_follow")
	GameState.connect("player_won", self, "stop_player_follow")
	
func _physics_process(delta):
	
	#TODO Convert to NavMesh Later
	if active:
		if knocked_back:
			motion_velocity = knock_back_speed * knock_back_dir
		elif is_shooting:
			# TODO: Movement logic when big meanie fires pew pew
			motion_velocity = drift_velocity
			pass
		else:
			var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
				
			motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
			motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
			
			motion_velocity.x = clamp(motion_velocity.x, -max_velocity.x, max_velocity.x)
			motion_velocity.y = clamp(motion_velocity.y, -max_velocity.y, max_velocity.y)
			
		move_and_slide(motion_velocity)
		
func _process(delta):
	if active:
		if !is_shooting && !is_shooting_cd:
			start_shoot()
			
		$EntitySprite.flip_h = GameState.cur_player.global_position.x - global_position.x < 0
			
func start_shoot():
	$AnimationPlayer.play("Shoot")
	is_shooting = true
	drift_velocity = motion_velocity / drift_divisor
	
	
func fire_shot():
	if !active:
		return
	var target_position = GameState.cur_player.global_position
	var angle_to_travel = (target_position - global_position).normalized()
	var i = bullet_template.instance()
	add_child(i)
	i.global_position = global_position 
	i.dir = angle_to_travel
	i.speed = bullet_speed
	
func start_player_follow(player : Player):
	active = true

func stop_player_follow(player : Player):
	active = false

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


func _on_ShootingCoolDown_timeout():
	is_shooting_cd = false


func _on_AnimationPlayer_animation_finished(anim_name):
	$ShootingCoolDown.start()
	is_shooting = false
	is_shooting_cd = true
