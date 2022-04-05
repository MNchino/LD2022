extends AudioStreamPlayer

func stop_timer():
	$Timer.stop()

func start_sound():
	if !$Timer.is_stopped():
		step_sound()
		$Timer.start()
	
func step_sound():
	pitch_scale = rand_range(0.8, 1.2)
	play()

func _on_Timer_timeout():
	step_sound()
	$Timer.start()
