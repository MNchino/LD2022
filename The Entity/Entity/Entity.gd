extends KinematicBody2D
class_name Entity

var bullet_template = preload("res://Entity/Bullet/Bullet.tscn")
var homing_bullet_template = preload("res://Entity/Bullet/HomingBullet.tscn")
var curving_bullet_template = preload("res://Entity/Bullet/CurvingBullet.tscn")
var circle_bullet_template = preload("res://Entity/Bullet/CircleBulletPath.tscn")
var triangle_bullet_template = preload("res://Entity/Bullet/TriangleBulletPath.tscn")
var star_bullet_template = preload("res://Entity/Bullet/StarBulletPath.tscn")
var bullet_container_template = preload("res://Entity/Bullet/BulletContainer.tscn")
var straight_bullet_template = preload("res://Entity/Bullet/StraightBullet.tscn")
var chino_bullet_templates = [preload("res://Entity/Bullet/OBulletPath.tscn"), preload("res://Entity/Bullet/NBulletPath.tscn"), preload("res://Entity/Bullet/IBulletPath.tscn"), preload("res://Entity/Bullet/HBulletPath.tscn"), preload("res://Entity/Bullet/CbulletPath.tscn")]

signal shooting_pattern_ended()

var active : bool = false
var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var input_speed : Vector2 = Vector2(90,90)
var max_velocity : Vector2 = Vector2(90,90)
var drift_const : float = 50
var knocked_back : bool = false
var knock_back_dir : Vector2 = Vector2(0,0)
var knocK_back_speed_normal : float = 400
var knock_back_speed_under_attack : float = 400
var knock_back_speed : float = knocK_back_speed_normal
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
var knock_back_autobullet_damage : float = 0
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
var shape_bullet_speed = 80
var letter_bullet_speed = 240
var bullet_container = null
var current_bullet_pattern = "chino"
var awaiting_teleport_in = false
var hiding = false
var following_player = false

func _ready():
	GameState.set_entity(self)
	
	if GameState.is_snow_mode && GameState.is_player_in_final_room:
		visible = false
		hiding = true
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	# warning-ignore:return_value_discarded
	GameState.connect("player_spawned", self, "start_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "stop_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, "stop_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("phase_changed", self, "react_to_phase_change")
	# only in snow mode
	GameState.connect("player_reached_last_room", self, 'teleport_out_until_player_restart')
	
	$EntitySprite.play("Idle")
	
func _physics_process(_delta):
	
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
		$ShootingWindDown.start()
		return
	else:
		fire_bullet_pattern(current_bullet_pattern)
	
func fire_bullet(template, angle_to_travel, speed, time_before_spawn = 0, base_angle = 0, min_h = 0, max_h = 1):
	if time_before_spawn:
		yield(get_tree().create_timer(time_before_spawn), "timeout")
	if !can_fire():
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
	# Don't spawn entity in final room in snow mode
	if GameState.is_snow_mode :
		if GameState.is_player_in_final_room:
			teleport_out_until_player_restart()
			return
		else:
			visible = true
			hiding = false
			$Hitbox/CollisionShape2D.set_deferred("disabled", false)
		
	active = true
	following_player = true
	reposition(spawn_distance)

func stop_player_follow(_player : Player):
	active = false
	awaiting_teleport_in = false
	following_player = false
	queue_free()
	
func reposition(distance : float):
	if is_instance_valid(GameState.cur_player):
		if GameState.cur_player.is_inside_tree():
			global_position = GameState.cur_player.global_position + (Vector2.UP * distance).rotated(deg2rad(rand_range(0,360)))

func knock_back(away_from_position : Vector2, is_autobullet : bool = false):
	if GameState.is_snow_mode:
		if hiding || !following_player || !active:
			return
		GameState.entity_health -= knock_back_damage if !is_autobullet else knock_back_autobullet_damage
		
	if !knocked_back:
		#determine speed
		if GameState.is_snow_mode:
			if is_shooting:
				knock_back_speed = knock_back_speed_under_attack
			else:
				knock_back_speed = knocK_back_speed_normal
			#No knockback for autobullets
			if is_autobullet:
				return
		
		knocked_back = true
		knock_back_dir = (global_position - away_from_position).normalized()
		$KnockbackTime.start()
		$HitParticle.restart()
		$HitParticle.emitting = true

func _on_KnockbackTime_timeout():
	knocked_back = false

func _on_Hurtbox_area_entered(area : Area2D):
	var is_autobullet = area.is_in_group('enemy_homer')
	knock_back(area.global_position, is_autobullet)
	if !is_autobullet:
		$Audio/ParryKnockback.pitch_scale = rand_range(0.95,1.05)
		$Audio/ParryKnockback.play()
	if area.name != "Attack":
		# Don't delete when inactive in snow mode
		if GameState.is_snow_mode && !active:
			pass
		else:
			area.queue_free()
	elif starting_move:
		starting_move = false
		$TeleportTimer.start()
		if $ShootingCoolDown.time_left > 0.5:
			$ShootingCoolDown.start(0.25)

func _on_ShootingWindUp_timeout():
	$EntitySprite.play("AttackShoot")
	fire_shot()
	
func _on_ShootingWindDown_timeout():
	$EntitySprite.play("Idle")
	$ShootingCoolDown.wait_time = rand_range(shoot_delay_min, shoot_delay_max)
	$ShootingCoolDown.start()
	is_shooting = false
	is_shooting_cd = true
	if GameState.is_snow_mode && awaiting_teleport_in && !GameState.is_player_in_final_room :
		awaiting_teleport_in = false
		teleport_in()

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
	#Snow mode requires a lot of bullets to fire, and has long bullet patterns
	#Therefore, we wait until the pattern is finished before teleporting
	if GameState.is_snow_mode:
		if GameState.is_player_in_final_room:
			awaiting_teleport_in = false
		elif is_shooting:
			awaiting_teleport_in = true
		else:
			teleport_in()
	else:
		teleport_in()
	
## Assert entity is already off screen	
func teleport_in():
	reposition(repos_distance)
	$AnimationPlayer.play("FadeIn")
	$TeleportTimer.stop()
	
func teleport_out():
	$AnimationPlayer.play("FadeOut")
	
	
func teleport_out_until_player_restart():
	active = false
	teleport_out()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		if GameState.is_snow_mode && GameState.is_player_in_final_room:
			#This will stop the enemy until you warp back to the spawn
			active = false
		elif active:
			active = false
			reposition(repos_distance)
			$AnimationPlayer.play("FadeIn")
	elif anim_name == "FadeIn":
		if is_instance_valid(GameState.cur_player):
			active = true
			reset_and_start_teleport_timer()
			
func reset_and_start_teleport_timer():
	$TeleportTimer.wait_time = rand_range(repos_delay_min, repos_delay_max)
	$TeleportTimer.start()

func _on_TeleportTimer_timeout():
	if active:
		if is_shooting:
			reset_and_start_teleport_timer()
		else:
			teleport_out()
	else:
		reset_and_start_teleport_timer()
		
func fire_bullet_pattern(_pattern_name):
	var target_position = GameState.cur_player.global_position
	var angle_to_travel = (target_position - global_position).normalized()
	var used_angle = randi()%360
	match(_pattern_name):
		"default":
			#Only one shot sound plays
			$Audio/WaveAttack.pitch_scale = rand_range(0.95,1.05)
			$Audio/WaveAttack.play()
			$ShootingWindDown.start()
			
			if alternating_wave_homing:
				if alternate_to_home_next:
					homing_bullets_to_spawn = alternating_homing_bullets_to_spawn
					wave_bullets_to_spawn = 0	
				else:
					homing_bullets_to_spawn = 0
					wave_bullets_to_spawn = alternating_wave_bullets_to_spawn
				alternate_to_home_next = !alternate_to_home_next
			fire_shaped_bullets('circle', circle_bullets_to_spawn, angle_to_travel, shape_bullet_speed, 0, used_angle)
			for m in range(curving_bullets_to_spawn.size()):
				fire_curving_bullets(curving_bullets_to_spawn[m], angle_to_travel, homing_bullet_speed, time_between_curving_bullet_spawns*m, used_angle)
			fire_homing_bullets(homing_bullets_to_spawn,angle_to_travel,homing_bullet_speed)
			fire_tight_homing_bullets(tight_homing_bullets_to_spawn,angle_to_travel,homing_bullet_speed)
			fire_wave_bullets(wave_bullets_to_spawn, angle_to_travel, bullet_speed)
		"shapes":
			var total_duration = .7
			play_fire_sound()
			fire_shaped_bullets('circle', 8, angle_to_travel, shape_bullet_speed, 0, used_angle)
			yield(get_tree().create_timer(total_duration), "timeout")
			$Audio/WaveAttack.pitch_scale = rand_range(0.95,1.05)
			$Audio/WaveAttack.play()
			emit_signal("shooting_pattern_ended")
			fire_shaped_bullets('triangle', 6, angle_to_travel, shape_bullet_speed, 0, used_angle)
		"chino":
			var time = 0.3
			play_fire_sound()
			fire_straight_bullets(10, angle_to_travel,homing_bullet_speed,0,used_angle)
#			fire_shaped_bullets('o', 1, angle_to_travel, letter_bullet_speed, 0, used_angle)
#			yield(get_tree().create_timer(time), "timeout")
#			play_fire_sound()
#			fire_shaped_bullets('n', 1, angle_to_travel, letter_bullet_speed, 0, used_angle)
#			yield(get_tree().create_timer(time), "timeout")
#			play_fire_sound()
#			fire_shaped_bullets('i', 1, angle_to_travel, letter_bullet_speed, 0, used_angle)
#			yield(get_tree().create_timer(time), "timeout")
#			play_fire_sound()
#			fire_shaped_bullets('h', 1, angle_to_travel, letter_bullet_speed, 0, used_angle)
#			yield(get_tree().create_timer(time), "timeout")
#			play_fire_sound()
#			fire_shaped_bullets('c', 1, angle_to_travel, letter_bullet_speed, 0, used_angle)
			$ShootingWindDown.start()
			
func wait(time: float):
	yield(get_tree().create_timer(time), "timeout")
			
func play_fire_sound():
	if can_fire():
		$Audio/WaveAttack.pitch_scale = rand_range(0.95,1.05)
		$Audio/WaveAttack.play()
	
func can_fire():
	if !active:
		if !GameState.is_snow_mode:
			return false
		else:
			# We can continue firing as long as we are awaiting teleport or not dead
			# In snow mode only
			if !is_instance_valid(GameState.cur_player):
				return false
			elif !awaiting_teleport_in:
				return false
			else:
				return true
	return true
			
func fire_shaped_bullets(shape: String, num : int, angle : Vector2, speed : float, delay : float, angle_seed : int):
	var template_to_spawn
	var min_h
	var max_h
	match(shape):
		'circle':
			template_to_spawn = circle_bullet_template
			min_h = 0.2
			max_h = 0.4
		'triangle':
			template_to_spawn = triangle_bullet_template
			min_h = 0.0
			max_h = 0.2
		'star':
			template_to_spawn = star_bullet_template
			min_h = 0.4
			max_h = 0.6
		'o':
			template_to_spawn = chino_bullet_templates[0]
			min_h = .9
			max_h = 1
		'n':
			template_to_spawn = chino_bullet_templates[1]
			min_h = .8
			max_h = .9
		'i':
			template_to_spawn = chino_bullet_templates[2]
			min_h = .7
			max_h = .8
		'h':
			template_to_spawn = chino_bullet_templates[3]
			min_h = .6
			max_h = .7
		'c':
			template_to_spawn = chino_bullet_templates[4]
			min_h = .5
			max_h = .6
	for k in range(num):
		var angle_to_use = angle.angle() if num == 1 else deg2rad(rad2deg(angle.angle()) + 360.0*(float(k + 0.5)/num))
		var bullet_dir = Vector2(1,0).rotated(angle_to_use)
		fire_bullet(template_to_spawn,bullet_dir,speed,delay,angle_seed,min_h,max_h)
		
			
func fire_curving_bullets(num : int, angle : Vector2, speed : float, delay : float, angle_seed : int):
	for k in range(num):
		var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) + 360.0*(float(k + 0.5)/num)))
		fire_bullet(curving_bullet_template,bullet_dir,speed, delay, angle_seed)
		
func fire_straight_bullets(num : int, angle : Vector2, speed : float, delay : float, angle_seed : int):
	for k in range(num):
		var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) + 360.0*(float(k + 0.5)/num)))
		fire_bullet(straight_bullet_template,bullet_dir,speed, delay, angle_seed)
			
func fire_homing_bullets(num : int, angle : Vector2, speed : float):
	for k in range(num):
		var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) + 360.0*(float(k + 0.5)/num)))
		fire_bullet(homing_bullet_template,bullet_dir,speed)

func fire_tight_homing_bullets(num : int, angle : Vector2, speed : float):
	if num == 2:
		var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) +15))
		var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) -15))
		fire_bullet(homing_bullet_template,bullet_dir_1,speed)
		fire_bullet(homing_bullet_template,bullet_dir_2,speed)
				
func fire_wave_bullets(num : int, angle : Vector2, speed : float):
	if num == 1:
		fire_bullet(bullet_template,angle,speed)
	elif num == 2:
		var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) +30))
		var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) -30))
		fire_bullet(bullet_template,bullet_dir_1,speed)
		fire_bullet(bullet_template,bullet_dir_2,speed)
	elif num == 3:
		var bullet_dir_1 = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) +30))
		var bullet_dir_2 = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) -30))
		fire_bullet(bullet_template,bullet_dir_1,speed)
		fire_bullet(bullet_template,bullet_dir_2,speed)
		fire_bullet(bullet_template,angle,speed)
	else:
		if num != 0:
			for k in range(num):
				var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle.angle()) + 360.0*(float(k + 0.5)/num)))
				fire_bullet(bullet_template,bullet_dir,speed)
		
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


func _on_Entity_shooting_pattern_ended():
	$ShootingWindDown.start()


func _on_VisibilityNotifier2D_screen_entered():
	#If entity is about to teleport into screen, but comes back into screen manually
	#just stop it
	if awaiting_teleport_in:
		awaiting_teleport_in = false
