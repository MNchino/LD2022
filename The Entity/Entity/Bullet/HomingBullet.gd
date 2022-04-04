extends Bullet

var homing : bool = true
var turning_speed = 45
var distance_before_stop_homing = 100
var minimum_angle_before_stop_homing = 30

func _ready():
	GameState.connect("player_died", self, "stop_player_follow")

func _physics_process(_delta):
	if parried:
		# warning-ignore:return_value_discarded
		move_and_slide(direction_once_parried*parried_speed)
	else:
		if homing:
			var player_pos = GameState.cur_player.global_position
			var distance_to_player = (player_pos - global_position).length()
			var angle_to_player = (player_pos - global_position).normalized()
			var angle_difference = angle_to_player.angle() - dir.angle()
			if distance_to_player < distance_before_stop_homing && abs(rad2deg(angle_difference)) < minimum_angle_before_stop_homing:
				homing = false
			else:
				#dir = dir.rotated(angle_difference)
				dir = lerp(dir, angle_to_player, 0.02)
				
		# warning-ignore:return_value_discarded
		move_and_slide(dir*speed)

func stop_player_follow(_player):
	homing = false
