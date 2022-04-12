extends Control

var dialog_index = 0
var dialog_lines = []
var input_disabled = true
var use_white = false

signal dialog_ended()

func start():
	$AnimationPlayer.play("FadeInScene")

func _input(event):
	if !input_disabled:
		if event.is_action_pressed("game_restart"):
			play_next_dialog_line()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'FadeInScene':
		play_next_dialog_line()
	elif anim_name == 'FadeInDialog' || anim_name == 'ShowItem' || anim_name == 'ShowItemInMiddle' || anim_name == 'StartItemSpin':
		enable_input()
	elif anim_name == 'FadeOutScene' || anim_name == 'FadeOutWhite':
		emit_signal('dialog_ended')
		
func set_and_play_line(line : String):
	$Dialog.text = line
	$AnimationPlayer.play("FadeInDialog")
		
func play_next_dialog_line():
	if dialog_index < dialog_lines.size():
		disable_input()
		if dialog_lines[dialog_index] == "[ITEM_DROP]":
			$AnimationPlayer.play("ShowItem")
		elif dialog_lines[dialog_index] == "[ITEM_APPEAR]":
			$AnimationPlayer.play("ShowItemInMiddle")
		elif dialog_lines[dialog_index] == "[ITEM_SPIN]":
			$AnimationPlayer.play("StartItemSpin")
		else:
			set_and_play_line(dialog_lines[dialog_index])
		dialog_index += 1
	else:
		if use_white:
			$AnimationPlayer.play("FadeOutWhite")
		else:
			$AnimationPlayer.play("FadeOutScene")
		
func disable_input():
	input_disabled = true
	
func enable_input():
	input_disabled = false
	
func start_item_float():
	$ItemAnimator.play("Float")
	
func start_item_spin():
	$ItemAnimator.play("Spin")
