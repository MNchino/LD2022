extends KinematicBody2D
class_name Entity

var bullet_template = preload("res://Entity/Bullet/Bullet.tscn")
var homing_bullet_template = preload("res://Entity/Bullet/HomingBullet.tscn")

var active : bool = false
var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var input_speed : Vector2 = Vector2(90,90)
var max_velocity : Vector2 = Vector2(90,90)
var drift_const : float = 50
var knocked_back : bool = false
var knock_back_dir : Vector2 = Vector2(0,0)
var knock_back_speed : float = 300
var is_shooting : bool = false
var is_shooting_cd : bool = true
var bullet_speed : float = 120 
var homing_bullet_speed : float = 100
var homing_angle : float = 120
var starting_move : bool = true
var starting_speed : Vector2 = Vector2(30,30)
var shoot_delay_min : float = 1
var shoot_delay_max : float = 3

func _ready():
	GameState.set_entity(self)
	GameState.connect("player_spawned", self, "start_player_follow")
	GameState.connect("player_died", self, "stop_player_follow")
	GameState.connect("player_won", self, "stop_player_follow")
	$EntitySprite.play("Idle")
	
func _physics_process(_delta):
	#TODO Convert to NavMesh Later
	if active:
		if starting_move:
			var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
				
			motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
			motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
			
			motion_velocity.x = clamp(motion_velocity.x, -starting_speed.x, starting_speed.x)
			motion_velocity.y = clamp(motion_velocity.y, -starting_speed.y, starting_speed.y)
		elif knocked_back:
			motion_velocity = knock_back_speed * knock_back_dir
		elif is_shooting:
			# TODO: Movement logic when big meanie fires pew pew
			var direction = -position.direction_to(GameState.cur_player.position)
			motion_velocity = direction * drift_const
		else:
			var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
				
			motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
			motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
			
			motion_velocity.x = clamp(motion_velocity.x, -max_velocity.x, max_velocity.x)
			motion_velocity.y = clamp(motion_velocity.y, -max_velocity.y, max_velocity.y)
		# warning-ignore:return_value_discarded
		move_and_slide(motion_velocity)
		
func _process(_delta):
	if active:
		if !is_shooting && !is_shooting_cd:
			start_shoot()
			
		$EntitySprite.flip_h = GameState.cur_player.global_position.x - global_position.x < 0
			
func start_shoot():
	$EntitySprite.play("AttackPrep")
	$ShootingWindUp.start()
	is_shooting = true
	
func fire_shot():
	if !active:
		return
	var target_position = GameState.cur_player.global_position
	var angle_to_travel = (target_position - global_position).normalized()
	var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) +homing_angle))
	var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) -homing_angle))
	fire_bullet(bullet_template,angle_to_travel,bullet_speed)
	fire_bullet(homing_bullet_template,bullet_dir_1,homing_bullet_speed)
	fire_bullet(homing_bullet_template,bullet_dir_2,homing_bullet_speed)
	
func fire_bullet(template, angle_to_travel, speed):
	var i = template.instance()
	add_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	i.dir = angle_to_travel
	i.speed = speed
	
func start_player_follow(_player : Player):
	active = true

func stop_player_follow(_player : Player):
	active = false
	queue_free()

func knock_back(away_from_position : Vector2):
	if !knocked_back:
		knocked_back = true
		knock_back_dir = (global_position - away_from_position).normalized()
		$KnockbackTime.start()
		$HitParticle.restart()
		$HitParticle.emitting = true

func _on_KnockbackTime_timeout():
	knocked_back = false

func _on_Hurtbox_area_entered(area):
	knock_back(area.global_position)
	if area.name != "Attack":
		area.queue_free()
	elif starting_move:
		starting_move = false
		if $ShootingCoolDown.time_left > 0.5:
			$ShootingCoolDown.start(0.25)

func _on_ShootingWindUp_timeout():
	$EntitySprite.play("AttackShoot")
	$ShootingWindDown.start()
	fire_shot()
	
func _on_ShootingWindDown_timeout():
	$EntitySprite.play("Idle")
	$ShootingCoolDown.wait_time = rand_range(shoot_delay_min, shoot_delay_max)
	$ShootingCoolDown.start()
	is_shooting = false
	is_shooting_cd = true

func _on_ShootingCoolDown_timeout():
	is_shooting_cd = false
	starting_move = false
