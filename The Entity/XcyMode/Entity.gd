extends "res://Entity/Entity.gd"

func _init():
	shoot_delay_min = .5
	shoot_delay_max = .75
	repos_delay_min = 2
	repos_delay_max = 4

func react_to_phase_change(new_phase):
	match(new_phase):
		0:
			homing_bullets_to_spawn = 8
			wave_bullets_to_spawn = 4
		1:
			homing_bullets_to_spawn = 12
			wave_bullets_to_spawn = 8
		2:
			homing_bullets_to_spawn = 16
			wave_bullets_to_spawn = 12
		3:
			homing_bullets_to_spawn = 50
			wave_bullets_to_spawn = 20
