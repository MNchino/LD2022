extends KinematicBody2D

var speed : float  = 0
var dir : Vector2  = Vector2(0,0)
var parried : bool = false
var parried_location : Vector2 = Vector2(0,0)
var direction_once_parried : Vector2 = Vector2(0,0)
var percent_traveled = 0.00
var parried_speed = 0

func _physics_process(delta):
	if parried:
		move_and_slide(direction_once_parried*parried_speed)
	else:
		move_and_slide(dir*speed)

func _process(delta):
	if parried:
		$Sprite.rotation_degrees = rad2deg(direction_once_parried.angle())
	else:
		$Sprite.rotation_degrees = rad2deg(dir.angle())

func _on_ParrySwitcher_area_entered(area):
	parried = true
	parried_speed = 2*speed	
	parried_location = global_position;
	direction_once_parried = (get_parent().global_position - parried_location).normalized()
	$ParryHitbox/CollisionShape2D.set_deferred("disabled", false)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Sprite.self_modulate = "#ffffff"

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_ParryHitbox_tree_exiting():
	queue_free()
