extends KinematicBody2D
class_name Entity

var bullet_template = preload("res://Entity/Bullet/Bullet.tscn")
var homing_bullet_template = preload("res://Entity/Bullet/HomingBullet.tscn")
var curving_bullet_template = preload("res://Entity/Bullet/CurvingBullet.tscn")
var circle_bullet_template = preload("res://Entity/Bullet/TriangleBulletPath.tscn")
var bullet_container_template = preload("res://Entity/Bullet/BulletContainer.tscn")

var active : bool = false
var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var input_speed : Vector2 = Vector2(90,90)
var max_velocity : Vector2 = Vector2(90,90)
var drift_const : float = 50
var knocked_back : bool = false
var knock_back_dir : Vector2 = Vector2(0,0)
var knock_back_speed : float = 400
var is_shooting : bool = false
var is_shooting_cd : bool = true
var bullet_speed : float = 120 
var homing_bullet_speed : float = 60
var starting_move : bool = true
var starting_speed : Vector2 = Vector2(30,30)
var shoot_delay_min : float = 1
var shoot_delay_max : float = 3
var repos_delay_min : float = 5
var repos_delay_max : float = 8
var spawn_distance : float = 250
var repos_distance : float = 150
var knock_back_damage : float = 0
var homing_bullets_to_spawn : int = 2
var tight_homing_bullets_to_spawn : int = 0
var wave_bullets_to_spawn : int = 1
var alternating_wave_homing : bool = false
var alternate_to_home_next : bool = false
var alternating_wave_bullets_to_spawn = 0
var alternating_homing_bullets_to_spawn = 0
var curving_bullets_to_spawn = [0,0,0,0]
var time_between_curving_bullet_spawns = 0.1
var circle_bullets_to_spawn = 0
var circle_bullet_speed = 80
var bullet_container = null

func _ready():
	GameState.set_entity(self)
	# warning-ignore:return_value_discarded
	GameState.connect("player_spawned", self, "start_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "stop_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, "stop_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("phase_changed", self, "react_to_phase_change")
	$EntitySprite.play("Idle")
	
func _physics_process(_delta):
	#TODO Convert to NavMesh Later
	
	if starting_move:
		if active:
			if is_instance_valid(GameState.cur_player):
				var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
					
				motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
				motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
				
				motion_velocity.x = clamp(motion_velocity.x, -starting_speed.x, starting_speed.x)
				motion_velocity.y = clamp(motion_velocity.y, -starting_speed.y, starting_speed.y)
		else:
			motion_velocity = Vector2.ZERO
		
	elif knocked_back:
		motion_velocity = knock_back_speed * knock_back_dir
	elif is_shooting:
		if active:
			var direction = -position.direction_to(GameState.cur_player.position)
			motion_velocity = direction * drift_const
		else:
			motion_velocity = Vector2.ZERO
	else:
		if active:
			var dir_to_player = (GameState.cur_player.global_position - global_position).normalized()
				
			motion_velocity.x += ( dir_to_player.x * input_speed.x ) * motion_accel
			motion_velocity.y += ( dir_to_player.y * input_speed.y ) * motion_accel
			
			motion_velocity.x = clamp(motion_velocity.x, -max_velocity.x, max_velocity.x)
			motion_velocity.y = clamp(motion_velocity.y, -max_velocity.y, max_velocity.y)
		else:
			motion_velocity = Vector2.ZERO
			
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
	$Audio/WaveCharge.pitch_scale = rand_range(0.9,1.1)
	$Audio/WaveCharge.play()
	is_shooting = true
	
func fire_shot():
	if !active:
		return
	var target_position = GameState.cur_player.global_position
	var angle_to_travel = (target_position - global_position).normalized()
	if alternating_wave_homing:
		if alternate_to_home_next:
			homing_bullets_to_spawn = alternating_homing_bullets_to_spawn
			wave_bullets_to_spawn = 0	
		else:
			homing_bullets_to_spawn = 0
			wave_bullets_to_spawn = alternating_wave_bullets_to_spawn
		alternate_to_home_next = !alternate_to_home_next
	var used_angle = randi()%360
	for k in range(circle_bullets_to_spawn):
		var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) + 360.0*(float(k + 0.5)/circle_bullets_to_spawn)))
		fire_bullet(circle_bullet_template,bullet_dir,circle_bullet_speed,0,used_angle,0,0.2)
	for m in range(curving_bullets_to_spawn.size()):
		for k in range(curving_bullets_to_spawn[m]):
			var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) + 360.0*(float(k + 0.5)/curving_bullets_to_spawn[m])))
			fire_bullet(curving_bullet_template,bullet_dir,homing_bullet_speed, time_between_curving_bullet_spawns*m, used_angle)
	for k in range(homing_bullets_to_spawn):
		var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) + 360.0*(float(k + 0.5)/homing_bullets_to_spawn)))
		fire_bullet(homing_bullet_template,bullet_dir,homing_bullet_speed)
	if tight_homing_bullets_to_spawn == 2:
		var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) +15))
		var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) -15))
		fire_bullet(homing_bullet_template,bullet_dir_1,homing_bullet_speed)
		fire_bullet(homing_bullet_template,bullet_dir_2,homing_bullet_speed)
	if wave_bullets_to_spawn == 1:
		fire_bullet(bullet_template,angle_to_travel,bullet_speed)
	elif wave_bullets_to_spawn == 2:
		var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) +30))
		var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) -30))
		fire_bullet(bullet_template,bullet_dir_1,bullet_speed)
		fire_bullet(bullet_template,bullet_dir_2,bullet_speed)
	elif wave_bullets_to_spawn == 3:
		var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) +30))
		var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) -30))
		fire_bullet(bullet_template,bullet_dir_1,bullet_speed)
		fire_bullet(bullet_template,bullet_dir_2,bullet_speed)
		fire_bullet(bullet_template,angle_to_travel,bullet_speed)
	else:
		if wave_bullets_to_spawn != 0:
			for k in range(wave_bullets_to_spawn):
				var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) + 360.0*(float(k + 0.5)/wave_bullets_to_spawn)))
				fire_bullet(bullet_template,bullet_dir,homing_bullet_speed)
	
func fire_bullet(template, angle_to_travel, speed, time_before_spawn = 0, base_angle = 0, min_h = 0, max_h = 1):
	if time_before_spawn:
		yield(get_tree().create_timer(time_before_spawn), "timeout")
	if !active:
		return
	var i = template.instance()
	add_bullet_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	i.dir = angle_to_travel
	i.speed = speed
	if base_angle != 0:
		i.set_base_angle(base_angle, min_h, max_h)
	
func add_bullet_child(bullet):
	if !bullet_container:
		var cont = bullet_container_template.instance()
		add_child(cont)
		bullet_container = cont
	bullet_container.add_child(bullet)
	
func start_player_follow(_player : Player):
	active = true
	reposition(spawn_distance)

func stop_player_follow(_player : Player):
	active = false
	queue_free()
	
func reposition(distance : float):
	if is_instance_valid(GameState.cur_player):
		if GameState.cur_player.is_inside_tree():
			global_position = GameState.cur_player.global_position + (Vector2.UP * distance).rotated(deg2rad(rand_range(0,360)))

func knock_back(away_from_position : Vector2):
	if !knocked_back:
		knocked_back = true
		knock_back_dir = (global_position - away_from_position).normalized()
		$KnockbackTime.start()
		$HitParticle.restart()
		$HitParticle.emitting = true
	if GameState.is_snow_mode:
		GameState.entity_health -= knock_back_damage

func _on_KnockbackTime_timeout():
	knocked_back = false

func _on_Hurtbox_area_entered(area):
	knock_back(area.global_position)
	$Audio/ParryKnockback.pitch_scale = rand_range(0.95,1.05)
	$Audio/ParryKnockback.play()
	if area.name != "Attack":
		area.queue_free()
	elif starting_move:
		starting_move = false
		$TeleportTimer.start()
		if $ShootingCoolDown.time_left > 0.5:
			$ShootingCoolDown.start(0.25)

func _on_ShootingWindUp_timeout():
	$EntitySprite.play("AttackShoot")
	$Audio/WaveAttack.pitch_scale = rand_range(0.95,1.05)
	$Audio/WaveAttack.play()
	$ShootingWindDown.start()
	fire_shot()
	
func _on_ShootingWindDown_timeout():
	$EntitySprite.play("Idle")
	$ShootingCoolDown.wait_time = rand_range(shoot_delay_min, shoot_delay_max)
	$ShootingCoolDown.start()
	is_shooting = false
	is_shooting_cd = true

func _on_ShootingCoolDown_timeout():
	if active:
		is_shooting_cd = false
		if starting_move:
			starting_move = false
			$TeleportTimer.start()
	else:
		$ShootingCoolDown.start(.1)

func _on_VisibilityNotifier2D_screen_exited():
	active = false
	reposition(repos_distance)
	$AnimationPlayer.play("FadeIn")
	$TeleportTimer.stop()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		if active:
			active = false
			reposition(repos_distance)
			$AnimationPlayer.play("FadeIn")
	elif anim_name == "FadeIn":
		if is_instance_valid(GameState.cur_player):
			active = true
			$TeleportTimer.wait_time = rand_range(repos_delay_min, repos_delay_max)
			$TeleportTimer.start()

func _on_TeleportTimer_timeout():
	if active:
		if is_shooting:
			$TeleportTimer.wait_time = rand_range(repos_delay_min, repos_delay_max)
			$TeleportTimer.start()
		else:
			$AnimationPlayer.play("FadeOut")
	else:
		$TeleportTimer.wait_time = rand_range(repos_delay_min, repos_delay_max)
		$TeleportTimer.start()
		
func react_to_phase_change(new_phase):
	match(new_phase):
		0:
			wave_bullets_to_spawn = 1
			homing_bullets_to_spawn = 0
		1:
			alternating_wave_bullets_to_spawn = 1
			alternating_homing_bullets_to_spawn = 2
			alternating_wave_homing = true
			wave_bullets_to_spawn = 0
			homing_bullets_to_spawn = 0
		2:
			alternating_wave_homing = false
			wave_bullets_to_spawn = 1
			homing_bullets_to_spawn = 2
		3:
			homing_bullets_to_spawn = 4
			wave_bullets_to_spawn = 3

func start_fever():
	repos_delay_max = repos_delay_min
	shoot_delay_max = shoot_delay_min
