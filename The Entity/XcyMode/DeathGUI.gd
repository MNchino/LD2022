extends "res://UI/DeathGUI.gd"

var item_unlock_sequence_enabled = false

func _ready():
	death_messages = [
		"this is a real bruh moment",
		"please enter your credit card number to continue",
		"Have you or a loved one been diagnosed with mesothelioma?",
		"I want your kidneys",
		"Kai, this mode may have been a mistake...",
		"Mitochondria is the powerhouse of the cell",
		"guess what",
		"it's almost 3 AM, help me, I have work in the morning",
		"why do you hate yourself",
		"Kidnapping is illegal in all 49 states of the USA",
		"DEFAULT_TEXT",
		"pls vtuber senpai stream our game and make us super famous",
		"Did you know a closet can hide approximately 49,147 rubber ducks if you fit it right",
		"potassium",
		"remember to wash your cat",
		
		"I don't have problems.  You have problems",
		"why are you still playing",
		"invest in chinocoin -- not legal investment advice",
		"hey guess who had too much caffeine todayyyyyy",
		"Step 1: Cover yourself in Oil.  Step 2: r u n",
		"your stubbornness is beyond me",
		"ngl i didn't put any effort into making this mode",
		"at least the entity will never give you up, never let you down.",
		"Error 69: nice.",
		"This is why you don't leave chino unsupervised",
		
		"betcha can't drown 3 times in a row",
		"whatever you do, don't drown a lot. water is expensive",
		"9 out of 10 doctors reccomend drowning 3 times a day"
	]

	drown_messages = death_messages
	
	GameState.connect('unlocked_item', self, 'start_item_unlock_sequence')
	$GeneralDialogUI.connect("dialog_ended", self, "resume_after_item_unlock")

func start_item_unlock_sequence():
	item_unlock_sequence_enabled = true
	
func restart_game():
	if item_unlock_sequence_enabled:
		play_item_unlock_sequence()
	else:
		.restart_game()
		
func play_item_unlock_sequence():
	input_disabled = true
	$GeneralDialogUI.dialog_lines = [
		"So you've chosen death.",
		"You're really getting tired of this, aren't you?",
		"You know what, I give up.",
		"Have this.",
		"[ITEM_DROP]", 
		"You better get to the end now, ok???",
		"I'm counting on you."
	]
	$GeneralDialogUI.start()
	
func resume_after_item_unlock():
	.restart_game()
	
func show_after_death():
	.show_after_death()
	if !GameState.intro_started:
		if GameState.drowned:
			GameState.times_drowned_in_a_row += 1
		else:
			GameState.times_drowned_in_a_row = 0
	
