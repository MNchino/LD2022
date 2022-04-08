extends "res://Entity/Entity.gd"

func _init():
	shoot_delay_min = .25
	shoot_delay_max = .5
	repos_delay_min = 1
	repos_delay_max = 2

func react_to_phase_change(new_phase):
	match(new_phase):
		0:
			curving_bullets_to_spawn = [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4]
#			circle_bullets_to_spawn = 6
			homing_bullets_to_spawn = 0
			wave_bullets_to_spawn = 0
		1:
			homing_bullets_to_spawn = 12
			wave_bullets_to_spawn = 8
		2:
			homing_bullets_to_spawn = 16
			wave_bullets_to_spawn = 12
		3:
			homing_bullets_to_spawn = 50
			wave_bullets_to_spawn = 20
