extends Control

func _ready():
	GameState.connect("dashes_changed", self, 'update_dashes')
	
func update_dashes(new_num : int):
	match new_num:
		0:
			$DashCounter/Container/HBoxContainer/Dash1.modulate = "#404040"
			$DashCounter/Container/HBoxContainer/Dash2.modulate = "#404040"
		1:
			$DashCounter/Container/HBoxContainer/Dash1.modulate = "#ffffff"
			$DashCounter/Container/HBoxContainer/Dash2.modulate = "#404040"
		2:
			$DashCounter/Container/HBoxContainer/Dash1.modulate = "#ffffff"
			$DashCounter/Container/HBoxContainer/Dash2.modulate = "#ffffff"
