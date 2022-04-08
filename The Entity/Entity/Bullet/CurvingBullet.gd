extends Node2D
class_name EfficientBullet

export(float) var speed : float  = 0
export(Vector2) var dir : Vector2  = Vector2(0,0)
var parried : bool = false
var parried_location : Vector2 = Vector2(0,0)
var direction_once_parried : Vector2 = Vector2(0,0)
export(float) var turn_strength = 100
var amount_to_turn = 3
var amount_to_turn_remaining = amount_to_turn
var parried_speed = 160
var hue_range = Vector2(0.0,1.0)
	
func _physics_process(_delta):
	if parried:
		# warning-ignore:return_value_discarded
		position += direction_once_parried*parried_speed*_delta
	else:
		dir = Vector2(1,0).rotated(deg2rad(rad2deg(dir.angle()) +turn_strength*_delta*max(amount_to_turn_remaining, 0)/amount_to_turn))
		amount_to_turn_remaining -= _delta
		position += dir*speed*_delta

func _process(_delta):
	if parried:
		rotation_degrees = rad2deg(direction_once_parried.angle())
	else:
		rotation_degrees = rad2deg(dir.angle())

func set_base_angle(base_angle, min_h = 0, max_h = 0):
	hue_range = Vector2(min_h, max_h)
	var angel : int =  (rad2deg(dir.angle()) + base_angle)
	var clamp_angle = fposmod(angel, 360)
	var color_hue = (clamp_angle/360.0)*(hue_range.y -hue_range.x) + hue_range.x
	$TinyBulletSprite.self_modulate = GameState.hsv_to_rgb(color_hue, 1, 1, modulate.a)


func _on_Hitbox_area_entered(area):
	if parried:
		return
		
	if area.is_in_group('attack'):
		var temp_pos = global_position;
		set_as_toplevel(true)
		global_position = temp_pos
		parried = true
		parried_speed = 2*speed if 2*speed > 0 else parried_speed
		parried_location = global_position;
		if is_in_group('path_following_bullet'):
			direction_once_parried = (get_parent().get_parent().get_parent().global_position - parried_location).normalized()
		else:
			direction_once_parried = (get_parent().global_position - parried_location).normalized()
		$Hitbox.set_collision_mask_bit(3, false)
		$Hitbox.set_collision_mask_bit(4, false)
		$Hitbox.set_collision_layer_bit(10, true)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Hitbox_tree_exiting():
	queue_free()
