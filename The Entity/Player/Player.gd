extends KinematicBody2D
class_name Player

var shoot_template = preload('res://Player/Lighterang/LighterangThrower.tscn')
var attack_template = preload("res://Player/Attack/Attack.tscn")
var snow_attack_template = preload("res://SnowMode/SnowAttack.tscn")
var dead_template = preload("res://Player/DeadPlaceholder.tscn")
var xcy_frames = preload("res://Sprite/Player/XcyFrames.tres")
var auto_shooter_template = preload("res://SnowMode/AutoShooter.tscn")

var motion_velocity : Vector2  = Vector2(0,0)
var motion_accel : float = .4
var motion_frict : float = .2
var input_speed : float = 10
var max_velocity : float = 100
var dash_speed : float = 4*max_velocity
var knock_back_speed = 300
var dir : Vector2 = Vector2(1,0) 
var knock_back_dir : Vector2 = Vector2(0,0)
var attack_knock_back_time : float = 0.05
var is_dashing : bool = false
var is_dashing_cd : bool = false
var is_shooting : bool = false
var is_shooting_cd : bool = false
var is_attacking : bool = false
var is_attacking_cd : bool = false
var is_knocking_back : bool = false
var invincible : bool = false
var is_slowed : bool = false
var water_bodies : Array = []
var is_in_water : bool = false
var is_facing_up : bool = false
var slowed_max_velocity = 150
var shoot_object_path : NodePath = ""
var is_drowned : bool = false
var active : bool = true
var autoshooter = null


func is_xcy_mode():
	return GameState.is_xcy_mode
	
func is_snow_mode():
	return GameState.is_snow_mode
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	GInput.connect("attack_pressed", self, "attack")
	# warning-ignore:return_value_discarded
	GInput.connect("shoot_pressed", self, "shoot")
	# warning-ignore:return_value_discarded
	GInput.connect("dash_pressed", self, "dash")
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, 'set_win_state')
	# warning-ignore:return_value_discarded
	GameState.connect("dashes_changed", self, '_on_GameState_dashes_changed')
	# warning-ignore:return_value_discarded
	GameState.connect("parried", self, '_on_GameState_parried')
	# warning-ignore:return_value_discarded
	GameState.connect("phase_changed", self, '_on_GameState_phase_changed')
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, '_on_GameState_player_won')
	$AnimatedSprite.animation = "WalkDown"
	motion_velocity = Vector2.ZERO
	
	if is_xcy_mode():
		$AnimatedSprite.frames = xcy_frames
		
	if is_snow_mode():
		$AnimatedSprite/DashIndicator.frame = 0
		$Timers/DashCoolDown.wait_time = .25
		$Timers/AttackCoolDown.wait_time = .5
		max_velocity = 150
		input_speed = 15
		$Timers/ShootCoolDown.wait_time = 1
		configure_autoshoot()

func _physics_process(delta):
	if !active:
		return
	if is_knocking_back:
		# warning-ignore:return_value_discarded
		move_and_slide(knock_back_dir*knock_back_speed)
		return
	elif is_dashing:
		motion_velocity = motion_velocity.normalized()*dash_speed
	else:
		if !(is_attacking || is_shooting):
			
			if GInput.dir.x != 0 || GInput.dir.y != 0:
				if $Timers/StepTimer.time_left == 0:
					$Timers/StepTimer.start()
					play_step()
			else:
				$Timers/StepTimer.stop()
			
			if GInput.dir.x != 0:
				dir.x = GInput.dir.x
				update_sprite_xflip(int(dir.x))
				motion_velocity.x += ( dir.x * input_speed ) * motion_accel
			else:
				motion_velocity.x = lerp(motion_velocity.x, 0, motion_frict)
				
			if GInput.dir.y != 0:
				dir.y = GInput.dir.y
				motion_velocity.y += ( dir.y * input_speed ) * motion_accel
				is_facing_up = motion_velocity.y < 0
			else:
				motion_velocity.y = lerp(motion_velocity.y, 0, motion_frict)
		else:
			motion_velocity.x = lerp(motion_velocity.x, 0, motion_frict)
			motion_velocity.y = lerp(motion_velocity.y, 0, motion_frict)
			
		if is_slowed:
			motion_velocity.x = clamp(motion_velocity.x, -slowed_max_velocity, slowed_max_velocity)
			motion_velocity.y = clamp(motion_velocity.y, -slowed_max_velocity, slowed_max_velocity)
		else:
			motion_velocity.x = clamp(motion_velocity.x, -max_velocity, max_velocity)
			motion_velocity.y = clamp(motion_velocity.y, -max_velocity, max_velocity)
	
	if is_dashing:
		var collider = move_and_collide(motion_velocity * delta)
		if collider != null:
			$Timers/DashTime.stop()
			_on_DashTime_timeout()
	else:
		# warning-ignore:return_value_discarded
		move_and_slide(motion_velocity)
		var collision = get_last_slide_collision( )
		if collision:
			knock_back_from_collider(collision)
	
func _process(_delta):
	if !active:
		return
	update_animations()
	
	var shoot_node = get_node_or_null(shoot_object_path)
	$LighterangParticles.emitting = is_instance_valid(shoot_node)
	
	if is_instance_valid(shoot_node):
		var shoot_object = shoot_node
		var lighterang : Node2D = shoot_object.get_node_or_null("Lighterang")
		if is_instance_valid(lighterang):
			$LighterangParticles.position = to_local(lighterang.global_position)
		
func update_sprite_xflip(xdir : int):
	$AnimatedSprite.flip_h = xdir < 0
	
func update_animations():
	if is_attacking:
		$AnimatedSprite.animation = "AttackUp" if is_facing_up else "AttackDown"
	elif is_shooting:
		$AnimatedSprite.animation = "Throw"
	elif is_dashing:
		$AnimatedSprite.animation = "DashUp" if is_facing_up else "DashDown"
	else:
		if motion_velocity.length() > 1:
			$AnimatedSprite.playing = true
		else:
			$AnimatedSprite.playing = false
			$AnimatedSprite.frame = 0
			
		$AnimatedSprite.animation = "WalkUp" if is_facing_up else "WalkDown"

func shoot():
	if !active:
		return
	if is_shooting_cd || is_shooting || is_attacking:
		return
	
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0
	$Timers/ShootPrep.start()
	is_shooting_cd = true
	is_shooting = true
	
	$Audio/Prep.pitch_scale = rand_range(0.95,1.05)
	$Audio/Prep.play()
	
	var target_position = get_global_mouse_position()
	update_sprite_xflip(-1 if target_position.x < global_position.x else 1)

func configure_autoshoot():
	if !autoshooter:
		var i = auto_shooter_template.instance()
		add_child(i)
		i.global_position = global_position
		autoshooter = i
		autoshooter.configure(GameState.player_shooting_amount, GameState.player_shooting_speed)
		autoshooter.activate()
	else:
		autoshooter.configure(GameState.player_shooting_amount, GameState.player_shooting_speed)
	
func attack():
	if !active:
		return
	if is_attacking_cd || is_attacking || is_shooting:
		return
	
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0
	$Timers/AttackPrep.start()
	
	is_attacking_cd = true
	is_attacking = true
	
	$Audio/Prep.pitch_scale = rand_range(0.95,1.05)
	$Audio/Prep.play()
	invincible = true
	
#	if is_instance_valid(GameState.cur_entity):
#		is_facing_up = GameState.cur_entity.position.y < position.y
#		update_sprite_xflip(-1 if GameState.cur_entity.position.x < position.x else 1)
#	else:
	var maus = get_global_mouse_position()
	is_facing_up = maus.y < global_position.y
	update_sprite_xflip(-1 if maus.x < global_position.x else 1)
		
func knock_back_from_collider(collision : KinematicCollision2D):
	if is_dashing:
		return
	
	if collision.collider.is_class('Node'):
		var collider : Node = collision.collider
		if collider.is_in_group('water'):
			return
			
	knock_back(Vector2(0,0), collision.normal)
	
func knock_back(knock_dir = Vector2(0,0), normal = Vector2(0,0)):
	if !active:
		return
	if is_knocking_back || is_dashing_cd:
		return
	
	if knock_dir:
		knock_back_dir = knock_dir
	elif normal:
		var d = motion_velocity.normalized()
		var n = normal
		knock_back_dir = d.bounce(n).normalized()
	else:
		knock_back_dir = -motion_velocity.normalized()
	motion_velocity = Vector2(0,0)
	is_knocking_back = true
	$Audio/Prep.play()
	$Audio/Prep.pitch_scale = rand_range(0.95,1.05)
	$Timers/KnockBackTime.start()

func dash():
	if !active:
		return
	if !is_dashing && !is_dashing_cd && (GameState.can_use_dash() || is_snow_mode()):
		if motion_velocity.length() < 1:
			return
			
		is_dashing = true
		$DashParticles.emitting = true
		GameState.use_dash()
		$Timers/DashTime.start()
		set_collision_mask_bit(8, false)
		set_collision_mask_bit(9, false)
		$Audio/Dash.pitch_scale = rand_range(0.95,1.05)
		$Audio/Dash.play()
		
func slow_down():
	is_slowed = true
	
func stop_slow_down():
	is_slowed = false
	
func insta_kill():
	if invincible:
		return
	GameState.unset_player(self)
	queue_free()
	
func set_win_state(_player : Player):
	invincible = true
		
func _on_DashTime_timeout():
	is_dashing = false
	is_dashing_cd = true
	
	set_collision_mask_bit(9, true) # Bramble handling
	$DashParticles.emitting = false
	$Timers/WateryTime.start()
	$Timers/DashCoolDown.start()

func _on_DashCoolDown_timeout():
	is_dashing_cd = false

func _on_ShootPrep_timeout():
	var target_position = get_global_mouse_position()
	var i = shoot_template.instance()
	add_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	i.rotation = target_position.angle_to_point(global_position)
	
	shoot_object_path = i.get_path()
	
	update_sprite_xflip(-1 if target_position.x < position.x else 1)
	$Audio/Shoot.pitch_scale = rand_range(0.95,1.05)
	$Audio/Shoot.play()
	$AnimatedSprite.playing = true
	$Timers/ShootTime.start()

func _on_ShootTime_timeout():
	is_shooting_cd = true
	is_shooting = false
	$Timers/ShootCoolDown.start()

func _on_ShootCoolDown_timeout():
	is_shooting_cd = false

func _on_AttackPrep_timeout():
	invincible = false
	
	var k = attack_template.instance() # if !is_snow_mode() else snow_attack_template.instance()
	add_child(k)
	k.set_as_toplevel(true)
	k.global_position = global_position
	
	$Audio/Attack.pitch_scale = rand_range(0.95,1.05)
	$Audio/Attack.play()
	$AnimatedSprite.playing = true
	$Timers/AttackTime.start()

func _on_AttackTime_timeout():
	is_attacking_cd = true
	is_attacking = false
	$Timers/AttackCoolDown.start()

func _on_AttackCoolDown_timeout():
	is_attacking_cd = false
	
func _on_KnockBackTime_timeout():
	is_knocking_back = false

func _on_Hurtbox_area_entered(_area):
	if !is_dashing:
		insta_kill()

func _on_Player_tree_exiting():
	var i = dead_template.instance()
	i.set_xflip($AnimatedSprite.flip_h)
	if is_drowned:
		GameState.drowned = true
		i.drown_sprite()
	else:
		GameState.hit_particle(position)
	
	get_parent().call_deferred("add_child", i)
	i.global_position = global_position

func _on_GameState_dashes_changed(count:int):
	if !is_snow_mode():
		$AnimatedSprite/DashIndicator.frame = count
	
func _on_GameState_parried(direction:float):
	knock_back_dir = -Vector2.RIGHT.rotated(direction)
#	if is_snow_mode():
#		knock_back_dir = Vector2(0,0)
	is_knocking_back = true
	var orig_wait_time = $Timers/KnockBackTime.wait_time
	$Timers/KnockBackTime.wait_time = attack_knock_back_time
	$Timers/KnockBackTime.start()
	$Timers/KnockBackTime.wait_time = orig_wait_time
 
func _on_WaterDetector_body_entered(body):
	if !water_bodies.has(body):
		water_bodies.push_back(body)
		is_in_water = true
		
func _on_WaterDetector_body_exited(body):
	if water_bodies.has(body):
		water_bodies.erase(body)
		if water_bodies.size() == 0:
			is_in_water = false

func _on_WateryTime_timeout():
	set_collision_mask_bit(8, true)
	
	if is_in_water:
		insta_kill()
		is_drowned = true

func play_step():
	$Audio/Step.pitch_scale = rand_range(0.8, 1.2)
	$Audio/Step.play()
	
func _on_GameState_phase_changed(phase):
	if phase == 3:
		if !$Audio/Heartbeat.playing:
			$Audio/Heartbeat.play()

func _on_GameState_player_won(_player):
	$Audio/Heartbeat.stop()
