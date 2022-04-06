extends Control

var blink_range = Vector2(.05, .3)
var blink_range_hide = Vector2(.1, 2.2)

var death_messages = [
	"Do you have the resolve to go on?",
	"Are you determined to find out the end?",
	"Would you like to get the chance to see them one final time?",
	"They miss you dearly, is it worth to see them again?",
	"The journey is more worth it when you work hard to see the top.",
	"Let their hopes keep you going.",
	"Now is not the time to perish.",
	"Remember them, and let them fuel you forward.",
	"Ena...",
	"The children... I have to tell them...",
	"No, not like this...",
	"It's just an imagination. I can't fall like this.",
	"Please, remember me.",
	"Please, I just want to talk to you, one last time.",
	"So close.. please give me the chance.",
	
	"It is hard to go through all of this.\n\nWhat's important is you get to the end.",
	"Keep your senses sharp, and you'd get to the end.",
	"Slow and steady wins the race.",
	"The reward is better when you go through the effort.",
	"It's hard, but don't let that stop you.",
	"Determination is key to victory.",
	"The reward feels different compared\n\nsimply watching it online.",
	"With time, your resolve can harden and you go through it all",
	"Relax. Head in. You'll get through this.",
	"It may be long, but your patience will be rewarded.",
	"Be cautious, and you'll get there.",
	
	"When the entity gives you lemons,\n\nyou may want to stay away.",
	"Watch out for nooks.\n\nYou don't want to be there.",
	"Take note of what they do,\n\nand use them for next time.",
	"Each failure is a learning experience\n\nif you let it be one.",
	"Throw your torch, and light a way.",
	"Keep in mind what you experienced, and you will get there.",
	"If there are no paths, a second look may be needed.",
	"Sometimes it's better to move past than engage head on.",
	
	"A word of advice:\n\nhugging the walls is usually not a good idea.",
	"A word of advice: your torch does not affect\n\nthe Entity, but it shows your path.",
	"A word of advice: glowberries are a thing.",
	"A word of advice:\n\nyou can actually dash through the Entity.",
	
	"Patience has its own rewards.\n\n- Antechamber, 2013",
	"Failing to succeed does not mean failing to progress.\n\n- Antechamber, 2013",
	"Moving forward may require making the most of what you've got.\n\n- Antechamber, 2013",
	"There are multiple ways to approach a situation.\n\n- Antechamber, 2013",
	"How we perceive a problem can change every time we see it.\n\n- Antechamber, 2013",
	"Rushing through a problem won't always give the right results.\n\n- Antechamber, 2013",
	"If you never stop trying, you will get there eventually.\n\n- Antechamber, 2013",
	"Small steps can take you great distances.\n\n- Antechamber, 2013",
	"Falling down teaches us how to get up and try again.\n\n- Antechamber, 2013",
]

var drown_messages = [
	"Alo, rise up.",
	"Stand up.",
	"Now is not the time to rest in the calm waves.",
	"Let's that stress ripple out. Be calm.",
	"A wave of calmess will get you through.",
	"Time it right, and you'll get through this.",
	
	"The Entity has control over the water.",
	"It's not if you can swim, it's just the Entity.",
	"The drowning is not by your own volition.",
	"The Entity carries the waves.",
	"The Entity is only doing their job.",
	"The Entity knows your hardships.",
	"The Entity does not hate you.",
	"The Entity has to.",
	"The Entity doesn't want to.",
	"The Entity wants you to succeed.",
	
	"We all know it's an accident. Let's try once more.",
	"Surprisingly, we're actually really forgiving with water\n\ndespite its harshness.",
	"Don't get too eager, for rushing will not help anyone mentally.",
	
	"A word of advice:\n\na 2-tile gap, is safe. 4 is not.",
	"A word of advice:\n\na dash can save you from prickly flowers.",
]

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died_gui", self, 'show_after_death')

func show_after_death():
	visible = true
	$AnimationPlayer.play("RESET")
	
	if GameState.intro_started:
		$Control/Percent.visible = false
		if GameState.intro_done:
			$Control/Title.modulate = Color("#ff00ed")
			$Control/Title.text = "The Entity comes to take you away."
			$Control/Retry.text = "[R]ise up.\n\nFind her. Tell her one last time."
		else:
			$Control/Title.visible = false
			$Control/Retry.text = "[R]each the shore.."
	elif GameState.finished:
		$Control/Percent.self_modulate = Color("#ff00ed")
		$Control/Percent.text = "%d" % GameState.time_taken
		$Control/Title.visible = false
		$Control/Retry.text = "[R]est in peace."
	else:
		if GameState.drowned:
			$Control/Title.text = drown_messages[randi() % drown_messages.size()]
		else:
			$Control/Title.text = death_messages[randi() % death_messages.size()]
		show_progress()

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if visible:
			if GameState.intro_started:
				GameState.reset()
				if GameState.intro_done:
					GameState.intro_started = false
					GameState.intro_done = false
					# warning-ignore:return_value_discarded
					get_tree().change_scene("res://Playspace.tscn")
				else:
					# warning-ignore:return_value_discarded
					get_tree().reload_current_scene()
			elif GameState.finished:
				if $PassTimer.is_stopped():
					$PassTimer.start()
					visible = false
					GameState.camera.target.get_node("PlayerSprite").visible = false
			else:
				GameState.reset()
				# warning-ignore:return_value_discarded
				get_tree().reload_current_scene()
	if Input.is_action_just_pressed("xcy_mode") && GameState.finished:
		GameState.reset()
		get_tree().change_scene("res://XcyMode/XcyPlayspace2.tscn")

func show_progress():
	var messing_around = rand_range(-0.025, 0.025)
	var frac = 1 - float(GameState.travelled_rooms)/GameState.num_rooms + messing_around
	$Control/Percent.text = str(round(clamp(frac,0,1)*100.0))

func _on_PassTimer_timeout():
	get_tree().quit()
